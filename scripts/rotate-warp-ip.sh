#!/usr/bin/env bash
# rotate-warp-ip.sh — 更换 Cloudflare WARP 出口 IP
#
# 通过删除旧注册、重新注册来获取新的 WARP 出口 IP。
# 支持重试机制：如果新 IP 和旧 IP 相同，会自动重试。
#
# 用法:
#   sudo /usr/local/bin/rotate-warp-ip.sh           # 默认最多重试 3 次
#   sudo /usr/local/bin/rotate-warp-ip.sh 5         # 自定义重试次数
#   sudo /usr/local/bin/rotate-warp-ip.sh --force   # 无限重试直到 IP 变化

set -Eeuo pipefail

# ============ 配置 ============
MAX_RETRIES="${1:-3}"          # 默认 3 次重试
FORCE=false
if [ "${1:-}" = "--force" ]; then
  MAX_RETRIES=20
  FORCE=true
fi

SOCKS_PROXY="127.0.0.1:40000"
WARP_CLI="sudo warp-cli --accept-tos"
LOG_TAG="rotate-warp-ip"

# ============ 函数 ============

log() {
  printf '[%s] [%s] %s\n' "$(date "+%Y-%m-%d %H:%M:%S")" "$LOG_TAG" "$*"
}

get_current_ip() {
  curl -s --max-time 5 --socks5-hostname "$SOCKS_PROXY" \
    https://cloudflare.com/cdn-cgi/trace 2>/dev/null \
    | grep "^ip=" | cut -d= -f2
}

get_current_colo() {
  curl -s --max-time 5 --socks5-hostname "$SOCKS_PROXY" \
    https://cloudflare.com/cdn-cgi/trace 2>/dev/null \
    | grep "^colo=" | cut -d= -f2
}

check_warp_ok() {
  # 确认 WARP 已连接且 SOCKS5 可用
  if ! $WARP_CLI status 2>/dev/null | grep -q "Connected"; then
    return 1
  fi
  local ip
  ip="$(get_current_ip)"
  [ -n "$ip" ]
}

do_rotate() {
  # 断开 → 删除注册 → 重新注册 → 恢复代理模式 → 连接
  $WARP_CLI disconnect >/dev/null 2>&1 || true
  sleep 1
  $WARP_CLI registration delete >/dev/null 2>&1 || true
  sleep 1
  $WARP_CLI registration new >/dev/null 2>&1
  $WARP_CLI mode proxy >/dev/null 2>&1
  $WARP_CLI proxy port 40000 >/dev/null 2>&1
  $WARP_CLI connect >/dev/null 2>&1
  sleep 3
}

# ============ 主流程 ============

log "开始 WARP IP 更换..."

# 检查当前状态
if ! check_warp_ok; then
  log "WARP 当前不可用，尝试恢复连接..."
  $WARP_CLI mode proxy >/dev/null 2>&1 || true
  $WARP_CLI proxy port 40000 >/dev/null 2>&1 || true
  $WARP_CLI connect >/dev/null 2>&1 || true
  sleep 3
  if ! check_warp_ok; then
    log "错误：WARP 无法连接，放弃"
    exit 1
  fi
  log "WARP 已恢复连接"
fi

OLD_IP="$(get_current_ip)"
OLD_COLO="$(get_current_colo)"
log "旧 IP: ${OLD_IP:-未知}  (节点: ${OLD_COLO:-未知})"

# 检查 Xray 是否依赖此 WARP 出口
XRAY_WAS_RUNNING=false
if systemctl is-active --quiet xray 2>/dev/null; then
  XRAY_WAS_RUNNING=true
fi

CHANGED=false
for ((i = 1; i <= MAX_RETRIES; i++)); do
  log "第 $i/$MAX_RETRIES 次尝试..."

  do_rotate

  NEW_IP="$(get_current_ip)"
  NEW_COLO="$(get_current_colo)"

  if [ -z "$NEW_IP" ]; then
    log "警告：无法获取新 IP，等待后重试..."
    sleep 2
    continue
  fi

  log "本轮 IP: $NEW_IP  (节点: ${NEW_COLO:-未知})"

  if [ "$OLD_IP" != "$NEW_IP" ]; then
    log "✅ IP 已更换！$OLD_IP → $NEW_IP"
    CHANGED=true
    break
  else
    log "IP 未变化（节点 $NEW_COLO 的 IP 池可能只有一个地址）"
  fi
done

# 结束状态
echo ""
echo "=========================================="
echo "  WARP IP 更换结果"
echo "=========================================="
echo "  旧 IP : ${OLD_IP:-未知}"
echo "  新 IP : $(get_current_ip)"
echo "  节 点 : $(get_current_colo)"
echo "  重 试 : $MAX_RETRIES 次"
if $CHANGED; then
  echo "  结 果 : ✅ 成功更换"
else
  echo "  结 果 : ⚠️  IP 未变化"
  echo "  原 因 : 当前边缘节点的 WARP IP 池可能只有一个地址"
fi
echo "=========================================="

# 如果 Xray 之前在运行，确认它现在正常工作
if $XRAY_WAS_RUNNING; then
  if ! systemctl is-active --quiet xray; then
    log "警告：Xray 在 WARP 更换后未运行，正在启动..."
    sudo systemctl restart xray
    sleep 2
    if systemctl is-active --quiet xray; then
      log "Xray 已恢复运行"
    else
      log "错误：Xray 启动失败，请检查！"
      sudo systemctl status xray --no-pager
      exit 1
    fi
  fi
  # 验证 WARP 出站仍然可达
  if curl -s --max-time 5 --socks5-hostname "$SOCKS_PROXY" \
    https://cloudflare.com/cdn-cgi/trace >/dev/null 2>&1; then
    log "WARP SOCKS5 出站验证正常"
  else
    log "警告：WARP SOCKS5 出站可能异常"
  fi
fi

exit 0
