# 代理服务器搭建与运维指南

AWS Lightsail + Xray Reality 主入口 + Shadowsocks 链式备用入口 + Cloudflare WARP

**标签：** AWS Lightsail · Xray VLESS-XHTTP-Reality · Shadowsocks AES-256-GCM 链式备用 · Cloudflare WARP · 住宅 IP · V2rayN / V2rayNG

## 目录

1. [整体架构方案](#arch)
2. [Lightsail 注册与购买](#lightsail)
3. [Xray VLESS-XHTTP-Reality 搭建（一键脚本）](#xray)
4. [Cloudflare WARP 出口配置](#warp)
5. [Xray 分流路由配置](#routing)
6. [Oregon Shadowsocks 链式备用入口](#ss-chain)
7. [本地客户端配置（V2rayN / V2rayNG）](#client)
8. [住宅 IP 代理方案（可选）](#residential)
9. [安全与风控注意事项](#security)

<a id="arch"></a>

## 1. 整体架构方案

```text
本地客户端  (V2rayN macOS / V2rayNG Android)
    │
    ├── 直连主入口：VLESS-XHTTP-Reality / TCP 443（抗 DPI）
    │
    └── 链式备用：香港机场前置 → SS AES-256-GCM / TCP 18443
    ▼
AWS Lightsail  ($5/月, Ubuntu 24.04)
    │
    ├── 普通流量 ──→ 直连出站
    │
    └── Claude / OpenAI ──→ WARP (socks5://127.0.0.1:40000)
                              │
                              ▼
                        Cloudflare 网络  (AS 13335, IP 信誉优于 AWS)
                              │
                              ▼
                     claude.ai / openai.com
```

### 为什么选这个架构

| 维度 | 说明 |
| --- | --- |
| 协议层 | VLESS-XHTTP-Reality / 443 始终是抗 DPI 主入口；SS AES-256-GCM / 18443 仅在本地直连 Oregon 不稳定时，作为香港前置后的链式备用入口 |
| 出口层 | WARP 将 Claude/OpenAI 流量从 AWS IP 转为 Cloudflare IP，降低风控风险 |
| 成本 | Lightsail $5/月 + WARP 免费 = **$5/月** |
| IP 信誉 | Cloudflare 承载数千万正常用户，IP 信誉远优于 AWS 数据中心段 |

### IP 信誉对比

|  | 裸 Lightsail | \+ WARP | \+ 住宅 IP |
| --- | --- | --- | --- |
| AS 归属 | AS 16509 (Amazon) | AS 13335 (Cloudflare) | 当地 ISP |
| IP 性质 | 数据中心 | 数据中心 + 大量正常用户 | 住宅 |
| 被标记风险 | 高 | 中等 | 低 |
| 额外成本 | $0 | $0 | $2-5/月 |

> [!NOTE]
> 推荐策略
>
> 先用 WARP 跑一两周观察。如果稳定则无需加住宅 IP；如果被风控，再叠加 ISP 静态住宅代理作为 fallback 出口。

> [!TIP]
> 为什么选 XHTTP 而非 Vision
>
> Vision 使用 TCP 长连接，DPI 容易识别出"一条 TLS 连接持续传输大量数据"的代理特征并干扰握手。实测 Tokyo 节点 Vision 握手成功率仅 1.4%（7846 次失败 / 109 次成功）。
>
> XHTTP 将流量封装为标准 HTTP 请求/响应，和普通 HTTPS 网页浏览行为一致，DPI 无法区分。同一 IP 切换到 XHTTP 后握手成功率恢复 100%，确认之前的干扰是 DPI 针对 Vision 流量特征，而非链路丢包。

<a id="lightsail"></a>

## 2. Lightsail 注册与购买

### 注册 AWS 账号

1. 访问 **aws.amazon.com**，点击「Create an AWS Account」
2. **邮箱**：使用 Gmail 等国际邮箱，不用国内邮箱
3. **账号类型**：选 Personal（个人）
4. **地址信息**：填写美国地址，优先选免税州（Oregon / Delaware）
5. **绑定信用卡**：需要 Visa / Mastercard
    - 国内双币信用卡可以用，AWS 对卡限制宽松
    - 也可使用 WildCard / Wise 虚拟卡
    - 注册时预扣 $1 验证，之后退回
6. **手机验证**：+86 国内手机号可以接码
7. **支持计划**：选 Basic Support（免费）

> [!TIP]
> 好消息
>
> AWS 注册对中国用户友好度远高于 Anthropic，国内信用卡和手机号都没问题，不需要伪装。

### 创建 Lightsail 实例

登录 AWS 后，搜索栏搜「Lightsail」或直接访问 lightsail.aws.amazon.com。

| 配置项 | 推荐选择 | 说明 |
| --- | --- | --- |
| Region | `us-west-2` (Oregon) | 国内直连 ~150-180ms，美东 Virginia ~220-260ms；AI 服务（Anthropic/OpenAI）主部署在美西，Oregon 出站延迟极低；Oregon 是免税州，AWS 账单不额外加税 |
| Availability Zone | `us-west-2b` 或 `us-west-2c` | 同 Region 内各 AZ 延迟/价格无差异。默认 2a 选的人最多，IP 段被滥用/被墙的概率略高，换一个避开从众效应 |
| Platform | Linux/Unix |  |
| Blueprint | **OS Only** → Ubuntu 24.04 LTS | 选「Operating System only」标签页，不选「Apps + OS」。预装应用（WordPress、Node.js 等）用不上，占资源且增加攻击面 |
| Network Type | **Dual-stack** | IPv4 + IPv6，无额外费用，多一个 IPv6 地址偶尔能用上 |
| Plan Type | **General purpose** | Memory-optimized / Compute-optimized 用于数据库和批处理，代理服务器用不上 |
| Plan | **$5/月** | 1 vCPU, 1GB RAM, 2TB 流量 |
| SSH Key | 默认创建即可 → **下载私钥** | 务必保存好，丢失无法恢复 |
| Launch Script | 不用填 | 后面手动 SSH 安装 |
| Automatic Snapshots | 不用开 | 配置稳定后手动打一个快照即可，自动快照按量收费 |
| Instance Name | 随意，如 `proxy-oregon` | 自己认得出来就行，保持默认也无所谓 |
| Tags | 不用加 | 单台实例不需要标签分类 |

> [!NOTE]
> $5 够用吗？为什么不选 $7
>
> Xray + WARP 本质是转发流量，实测资源占用很低：CPU 日常 <5%，Xray ~30MB + WARP ~50MB 内存，1GB 完全够用。即使兼做日常代理（YouTube 1080p ~5GB/小时），2TB/月流量也很难超。$7 档（2 vCPU / 2GB RAM）多出来的资源在代理场景下基本闲置。

### 后期升配

如果以后发现资源不够（比如还想在上面跑其他服务），Lightsail 支持通过快照升配：

1. **创建快照**：Instances → 实例 → Snapshots → Create snapshot
2. **从快照创建新实例**：选择更高配置（如 $7 / $10），Xray/WARP 配置完整保留
3. **迁移静态 IP**：把静态 IP 从旧实例移到新实例（免费，IP 地址不变，客户端不用改配置）
4. **删除旧实例**：删掉即停止计费，从升级那一刻起按新档价格计费，无补差价

整个过程约 10-15 分钟，期间代理短暂中断。所以先买 $5 完全没问题，有需要再升，没有惩罚性费用。

### 分配静态 IP

默认 IP 重启会变，必须绑定静态 IP：**Networking → Static IP → Create**，关联到实例。绑定后 IP 地址可能会变成一个新的，需要同步更新客户端配置（重新扫码添加节点）。之后 IP 就固定不变了。

> [!NOTE]
> 计费说明
>
> 静态 IP 绑定到运行中的实例是**免费**的。只有分配了静态 IP 但未关联到任何实例时才收费（$0.005/小时，约 $3.6/月）。正常使用不用担心。

### 配置防火墙

路径：Instances → 实例 → Networking → IPv4 Firewall。**新实例默认只开 22 和 80，443 必须手动添加，否则客户端连不上 Reality 主入口。**只有启用第 6 章的链式备用入口时，才额外开放 18443。

```bash
# 保留
SSH     TCP   22    ✓

# 删除（不需要）
HTTP    TCP   80    ✗

# 添加（Reality 主入口，必须手动添加）
Custom  TCP   443   ✓

# 可选：仅启用 SS AES-256-GCM 链式备用入口时添加；来源范围按第 6 章设置
Custom  TCP   18443 ✓
```

如果选了 Dual-stack，同时检查下方的 **IPv6 Firewall**：主入口添加 `Custom TCP 443`；确实需要通过 IPv6 访问链式入口时再添加 `Custom TCP 18443`。

### SSH 连接

```bash
# 设置私钥权限
chmod 400 ~/path/to/LightsailDefaultKey.pem

# 连接
ssh -i ~/path/to/LightsailDefaultKey.pem ubuntu@<你的静态IP>
```

### Google Cloud Compute Engine 适配

第 3～6 章及后续运维步骤也已在 Google Cloud Oregon 的 Ubuntu 24.04 小规格实例上验证。除云防火墙、实例代理服务和公网 IP 管理外，Xray、host WARP、Swap 与 BBR 的配置和 Lightsail 相同。

```bash
ssh -i ~/.ssh/<GCP_PRIVATE_KEY> <GCP_USER>@<GCP_EXTERNAL_IP>
```

在 **VPC 网络 → 防火墙**中按需允许 TCP 22、443，以及启用 Shadowsocks 链式备用入口时的 18443。SSH 建议限制来源地址；1Panel 等管理端口不要直接暴露公网，见第 9 章。

> [!IMPORTANT]
> GCP 不要照搬 AWS 服务清单
>
> `amazon-ssm-agent` 只属于 AWS，在 GCP 上直接跳过。应保留实例实际依赖的 `google-guest-agent`、OS Config、`google-cloud-ops-agent`；安装了 1Panel 时也应保留其服务。先检查再决定：
>
> ```bash
> systemctl list-units --type=service --all | grep -Ei 'google|ops-agent|1panel'
> ```
>
> 不要仅因名称不熟悉就禁用 `google-*` 或 `1panel` 服务。

### 内存优化（$5 实例必做）

$5 plan 只有 1GB 内存（实际可用约 414MB）。Xray ~12MB + WARP ~77MB 本身不大，但 Ubuntu 默认运行的系统服务会额外占用 ~200MB，极易触发 **OOM（Out of Memory）**导致 DNS 崩溃、Xray 连接全断。

> [!CAUTION]
> 实测踩坑：OOM 导致代理全部断连
>
> `fwupd`（固件更新守护进程）启动时吃掉 130MB+，触发内核 OOM Killer → 系统 DNS 解析器（systemd-resolved）连带崩溃 → Xray Reality 无法解析 `www.microsoft.com` → 所有连接失败。日志表现为大量 `REALITY: failed to dial dest: server misbehaving`。

#### 第一步：禁用不必要的系统服务

```bash
# 固件更新（云服务器不需要，OOM 元凶）
sudo systemctl disable --now fwupd.service fwupd-refresh.timer

# Snap 包管理器（代理服务器用不上）
sudo systemctl disable --now snapd.service snapd.socket snapd.seeded.service

# AWS SSM Agent（你用 SSH 管理，不需要）
sudo systemctl disable --now snap.amazon-ssm-agent.amazon-ssm-agent.service

# 多路径存储（没有多路径设备）
sudo systemctl disable --now multipathd.service

# 自动更新（可选，手动 apt upgrade 更可控）
sudo systemctl disable --now unattended-upgrades.service
```

| 服务 | 释放内存 | 为什么不需要 |
| --- | --- | --- |
| fwupd | ~130MB | 固件更新对云服务器无意义，且是 OOM 主因 |
| snapd | ~25MB | 代理服务器不需要 Snap 应用 |
| amazon-ssm-agent | ~18MB | SSH 管理即可，不需要 AWS 的远程管理代理 |
| multipathd | ~27MB | 没有多路径存储设备 |
| unattended-upgrades | ~18MB | 自动更新可能重启服务导致中断 |

> [!NOTE]
> 不同镜像未必安装了上述所有 unit，出现 `Unit ... not found` 表示该项可跳过。先用 `systemctl list-unit-files` 确认存在，并只禁用你明确不需要的服务；云厂商代理和管理面板按上一节说明保留。

#### 第二步：添加 Swap 防止 OOM

```bash
# 仅在尚无 /swapfile 时创建，避免重复格式化正在使用的 swap
if [ ! -f /swapfile ]; then
  sudo fallocate -l 512M /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
fi
sudo swapon --show=NAME | grep -qx /swapfile || sudo swapon /swapfile

# 开机自动挂载；重复执行不会向 fstab 追加重复行
grep -qF '/swapfile none swap sw 0 0' /etc/fstab || \
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# 验证
swapon --show
free -h
```

> [!NOTE]
> 优化后的内存对比
>
> |  | 优化前 | 优化后 |
> | --- | --- | --- |
> | 内存可用 | ~136MB | ~200MB（+47%） |
> | Swap | 无 | 512MB（OOM 兜底） |
>
> 优化后 $5 实例跑 Xray + WARP 完全稳定，不需要升配到 $7。

### 开启 BBR 加速

BBR（Bottleneck Bandwidth and Round-trip propagation time）是 Google 开发的 TCP 拥塞控制算法。Ubuntu 默认使用 `cubic`，在高延迟和丢包链路上表现保守——遇到丢包就大幅降速。BBR 不依赖丢包信号，能更好地维持吞吐量。

| 场景 | cubic（默认） | BBR |
| --- | --- | --- |
| 高延迟链路（200ms+） | 吞吐量受限 | 明显提升 |
| 丢包链路（5-40%） | 遇丢包大幅降速 | 不因丢包降速 |
| YouTube 视频 | 缓冲慢，易卡顿 | 缓冲更快 |

```bash
# 使用独立配置文件，重复执行不会污染 /etc/sysctl.conf
sudo tee /etc/sysctl.d/99-proxy-bbr.conf > /dev/null <<'EOF'
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF
sudo sysctl --system

# 验证
sysctl net.core.default_qdisc net.ipv4.tcp_congestion_control
# 应分别输出 fq 和 bbr
```

> [!NOTE]
> BBR 无副作用
>
> BBR 是内核内置模块，不需要额外安装，两行配置即可。对服务器资源几乎无额外开销，重启后永久生效。建议所有实例都开启。

### 计费注意

- 新实例 **前 3 个月免费**（$5 以下 plan），按实例独立计算——同时创建 2 台 $5 实例，两台都各自有 3 个月免费
- 超出流量按 $0.09/GB 计费，2TB 代理用很难超
- 停止实例仍计费，只有 **删除** 才停止
- IP 被墙时，删掉静态 IP 重新分配即可（免费）

<a id="xray"></a>

## 3. Xray VLESS-XHTTP-Reality 搭建（一键脚本）

使用 [Xray-script](https://github.com/zxcvos/Xray-script) 一键安装 XHTTP Reality。脚本自动完成 Xray 安装、密钥生成、配置写入和服务启动。

### 一键安装

```bash
# 下载安装脚本
sudo wget -O /root/Xray-script.sh \
  https://raw.githubusercontent.com/zxcvos/Xray-script/main/install.sh
sha256sum /root/Xray-script.sh

# 快速安装 XHTTP 配置（自动生成密钥、UUID、shortId）
sudo bash /root/Xray-script.sh --lang=zh --xhttp
```

> [!CAUTION]
> 既有 Xray 不等于全新安装
>
> `command -v xray` 已能找到 Xray 时，Xray-script 会跳过 Xray-core 和 systemd 单元安装，但仍会重建并覆盖 `/usr/local/etc/xray/config.json`；原服务单元的 `User=` 和权限限制会继续保留。首次显式传入 `--lang=zh` 可避免非交互 SSH 停在语言选择。
>
> ```bash
> command -v xray
> sudo systemctl cat xray
> sudo systemctl show xray -p User
> ```
>
> 实测在 `User=xray` 的旧服务上，root 的 `umask 077` 会令新下载的 geodata 变成 `600`，导致 Xray 启动时报 `permission denied`。安装后应固定为所有者可写、服务用户可读，并执行配置测试：
>
> ```bash
> sudo chown root:root /usr/local/share/xray/geoip.dat \
>   /usr/local/share/xray/geosite.dat
> sudo chmod 0644 /usr/local/share/xray/geoip.dat \
>   /usr/local/share/xray/geosite.dat
>
> XRAY_USER="$(systemctl show xray -p User --value)"
> XRAY_USER="${XRAY_USER:-root}"
> sudo -u "$XRAY_USER" test -r /usr/local/share/xray/geoip.dat
> sudo -u "$XRAY_USER" test -r /usr/local/share/xray/geosite.dat
> sudo xray run -test -config /usr/local/etc/xray/config.json
> ```
>
> 另外，从 `main` 下载的 bootstrap 脚本还会继续从仓库 `main` 拉取项目文件；仅保存一份 `install.sh` 并不等于锁定完整安装版本。生产环境执行前应先审阅当前提交。

安装完成后脚本输出三样东西：

- **客户端配置参数**：address、port、uuid、PublicKey、ShortId、path 等
- **分享链接**：`vless://...` 格式，可复制导入客户端
- **终端二维码**：手机 / 电脑可直接扫码添加节点

> [!NOTE]
> 保存好输出信息
>
> 安装输出的参数后续添加客户端节点时需要用到。如果忘了，可以随时重新查看（见下方管理菜单）。

### 管理菜单

安装完成后，随时可以通过管理菜单查看配置、重启服务：

```bash
# 启动管理菜单；-H 让脚本稳定使用 root 的状态目录
sudo -H bash /root/Xray-script.sh --lang=zh

# 菜单选项：
# 4. 启动
# 5. 停止
# 6. 重启
# 7. 分享链接与二维码  ← 重新显示节点信息
# 8. 信息统计
# 9. 管理配置
```

### 验证安装

```bash
# 检查 Xray 状态
sudo systemctl status xray

# 确认 443 端口监听
sudo ss -tlnp | grep 443

# 查看日志
sudo tail -20 /var/log/xray/error.log
```

> [!TIP]
> 不进菜单直接重新显示 VLESS 链接
>
> ```bash
> sudo -H bash /usr/local/xray-script/core/share.sh 2>&1 | grep '^vless://'
> ```
>
> 分享链接和二维码包含完整凭据，只能在受信任终端查看，不要提交到 Git、聊天、截图或工单。

> [!CAUTION]
> Xray-script 会把主配置当作生成文件
>
> 再次执行 `--xhttp`，或通过菜单修改协议、端口、Reality 参数和路由时，脚本可能重建 `/usr/local/etc/xray/config.json`。手工加入的 host WARP 出站、`ai-services` 规则和 `ss-chain` 入站不在脚本状态中，会被删除。
>
> 菜单中的启动、停止、重启、分享和信息查看通常不改配置；使用配置管理功能后，应重新应用第 5、6 章的 overlay，并再次做配置测试。

<a id="warp"></a>

## 4. Cloudflare WARP 出口配置

### 在 Lightsail 上安装 WARP

```bash
# 添加 Cloudflare 仓库
curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg \
  | sudo gpg --dearmor -o /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] \
  https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/cloudflare-client.list

# 安装
sudo apt update && sudo apt install -y cloudflare-warp

# 注册并配置代理模式；已有注册时跳过 registration new
sudo warp-cli --accept-tos registration new
sudo warp-cli --accept-tos mode proxy          # SOCKS5 代理模式，不接管全局路由
sudo warp-cli --accept-tos proxy port 40000    # 监听端口
sudo warp-cli --accept-tos connect

# 验证 DNS 也经 SOCKS5 解析，并确认输出 warp=on
sudo warp-cli --accept-tos status
curl --socks5-hostname 127.0.0.1:40000 \
  https://cloudflare.com/cdn-cgi/trace
```

> [!NOTE]
> WARP 模式说明
>
> 必须使用 `proxy` 模式（本地 SOCKS5），不要用默认的 `warp` 模式（会接管全局路由，导致 SSH 断连）。

> [!WARNING]
> host WARP 与脚本 Docker WARP 二选一
>
> `--xhttp` 不会自动启用 WARP，但 Xray-script 菜单可以另行部署 Docker WARP。本文使用宿主机 `cloudflare-warp`，Xray 连接 `127.0.0.1:40000`；脚本方案连接容器 IP 的 `40001`。不要混用两套实现，也不要因脚本菜单显示 WARP 未开启，就误判 host `warp-svc` 未工作。

<a id="routing"></a>

## 5. Xray 分流路由配置

Xray-script 生成的配置只有 `direct` 和 `block` 两个出站，需要手动添加 WARP 出站和 AI 服务分流规则。使用 `jq` 修改配置文件：

```bash
CONFIG=/usr/local/etc/xray/config.json
BACKUP="${CONFIG}.bak.$(date +%Y%m%d-%H%M%S)"
NEW="${CONFIG}.new"
sudo cp -a "$CONFIG" "$BACKUP"

# 先移除同 tag/ruleTag 项再添加，重复执行不会生成重复规则
sudo jq '
  .log.loglevel = "info" |
  .outbounds |= map(select(.tag != "warp")) |
  .outbounds += [{
    "tag": "warp",
    "protocol": "socks",
    "settings": {
      "servers": [{"address": "127.0.0.1", "port": 40000}]
    }
  }] |
  .routing.rules |= map(select(.ruleTag != "ai-services")) |
  .routing.rules = [
    .routing.rules[0],
    {
      "ruleTag": "ai-services",
      "domain": [
        "anthropic.com", "claude.ai", "claude.com",
        "clau.de", "claudeusercontent.com",
        "claudemcpclient.com", "claudemcpcontent.com",
        "servd-anthropic-website.b-cdn.net",
        "openai.com", "chatgpt.com",
        "oaiusercontent.com", "oaistatic.com",
        "auth0.com", "arkoselabs.com", "azureedge.net",
        "featuregates.org", "intercom.io", "intercomcdn.com",
        "sentry.io", "statsigapi.net", "stripe.com"
      ],
      "outboundTag": "warp"
    }
  ] + .routing.rules[1:]
' "$CONFIG" | sudo tee "$NEW" > /dev/null

# 保留原配置的属主和权限，验证成功后再替换
sudo chown --reference="$CONFIG" "$NEW"
sudo chmod --reference="$CONFIG" "$NEW"
sudo xray run -test -config "$NEW"
sudo mv "$NEW" "$CONFIG"
sudo systemctl restart xray
sudo systemctl is-active --quiet xray
```

这段命令做了三件事：

1. 日志级别改为 `info`（方便排障，默认 `warning` 看不到路由决策）
2. 添加 WARP SOCKS5 出站（`127.0.0.1:40000`）
3. 在脚本原有的 api 规则之后插入 AI 服务分流规则，匹配的域名走 WARP 出口

### 验证分流生效

```bash
# 确认出站标签
sudo jq '.outbounds[].tag' /usr/local/etc/xray/config.json
# 应输出: "direct" "block" "warp"

# 确认路由规则
sudo jq '.routing.rules[].ruleTag' /usr/local/etc/xray/config.json
# 应输出: "api" "ai-services" "bt" "private-ip" "cn-ip" "ad-domain"

# 查看某条规则的完整域名列表（如 ai-services）
sudo jq '.routing.rules[] | select(.ruleTag=="ai-services") | {ruleTag, domain, outboundTag}' \
  /usr/local/etc/xray/config.json

# 查看所有走 WARP 的域名规则
sudo jq '.routing.rules[] | select(.outboundTag=="warp") | {ruleTag, domain}' \
  /usr/local/etc/xray/config.json
```

> [!NOTE]
> AI 服务域名列表说明（21 个域名）
>
> 当前 ai-services 规则仅覆盖 AI 服务及其依赖，Google 域名由 `toggle-google-warp.sh` 独立管理（见下方）：
>
> - **Claude / Anthropic**（8 个）：`anthropic.com` `claude.ai` `claude.com` `clau.de` `claudeusercontent.com` `claudemcpclient.com` `claudemcpcontent.com` `servd-anthropic-website.b-cdn.net`
> - **OpenAI / ChatGPT**（5 个）：`openai.com` `chatgpt.com` `oaiusercontent.com` `oaistatic.com` `azureedge.net`
> - **通用依赖**（8 个）：`auth0.com` `arkoselabs.com` `featuregates.org` `intercom.io` `intercomcdn.com` `sentry.io` `statsigapi.net` `stripe.com`
>
> Claude 域名参考：[MetaCubeX/meta-rules-dat anthropic.yaml](https://github.com/MetaCubeX/meta-rules-dat/blob/meta/geo/geosite/anthropic.yaml)（社区持续维护）<br>
> AI 通用域名参考：[sarices/ai.list](https://gist.github.com/sarices/017da597ae6b28063bbdd52693d78385)

> [!WARNING]
> 域名补充
>
> 上面列出了核心域名。实际使用中如果发现某些资源加载失败，可通过浏览器开发者工具或 `sudo tail -f /var/log/xray/access.log` 查看被直连的域名，添加到分流规则中。

### Google 全家桶 WARP 分流开关脚本

Google 域名不在 `ai-services` 规则中，而是由专用开关脚本 `/usr/local/bin/toggle-google-warp.sh` 独立管理。Google 的域名体系庞大（搜索、YouTube、Play Store、Firebase、Blogger、广告系统等，共 46 个域名），按需一键开启/关闭走 WARP：

```bash
# 查看当前状态
sudo toggle-google-warp.sh status

# 开启 Google 流量走 WARP（插入 google-warp 规则，自动备份 + 重启 Xray）
sudo toggle-google-warp.sh on

# 关闭（删除 google-warp 规则，恢复直连）
sudo toggle-google-warp.sh off
```

> [!NOTE]
> 脚本工作原理
>
> - **on**：用 `jq` 在 `routing.rules` 最前面插入一条 `ruleTag: "google-warp"` 的规则（最高优先级），覆盖 46 个 Google 域名，出站指向 WARP
> - **off**：用 `jq` 删除 `ruleTag == "google-warp"` 的规则
> - **status**：检查规则是否存在，列出当前覆盖的域名和 WARP 出站配置
> - 每次操作前自动备份配置到 `/usr/local/etc/xray/backups/`，操作后自动重启 Xray

脚本已部署到两台服务器：

| 服务器 | 路径 | 当前状态 |
| --- | --- | --- |
| Oregon（`<OREGON_SERVER_IP>`） | `/usr/local/bin/toggle-google-warp.sh` | 已部署，未开启 |
| Tokyo（`<TOKYO_SERVER_IP>`） | `/usr/local/bin/toggle-google-warp.sh` | 已部署，未开启 |

<a id="ss-chain"></a>

## 6. Oregon Shadowsocks 链式备用入口（可选）

当中国移动宽带或蜂窝网络直连 Oregon 不稳定时，可以保留 **VLESS + XHTTP + Reality / TCP 443** 主入口，同时在同一台 Oregon Xray 上增加 **Shadowsocks AES-256-GCM / TCP 18443** 入站，专供香港机场前置后的第二跳使用。Android 端完整配置见 [V2rayNG 链式代理章节](v2ray_proxy_guide.md#android-chain)。

```text
中国本地网络
    │
    ▼
香港机场前置  （外层协议由机场节点决定）
    │
    │  连接 <OREGON_SERVER_IP>:18443，内层为 SS AES-256-GCM
    ▼
Oregon Xray / ss-chain
    │
    ├── 普通网站 ──→ direct
    │
    └── Claude / Anthropic ──→ WARP
    ▼
目标站点
```

> [!WARNING]
> 兼容性备用，不替代 Reality 主入口
>
> 实际使用的 Xray `26.3.27` 已对 Shadowsocks 输出 `deprecated` 警告。当前 18443 入口虽已验证可用，但传统 `aes-256-gcm` 不具备 SS2022 的完整重放保护和主动探测缓解能力，也存在后续移除或兼容性变化风险。因此它只定位为客户端兼容性更好的**链式备用入口**；443 Reality 主入口必须保留，升级 Xray 后也要重新做配置测试和端到端验证。

### 加密边界

| 链路部分 | 能确认什么 | 不能误解成什么 |
| --- | --- | --- |
| 机场的长入口域名 | 用于寻址、调度或智能入口选择 | 域名本身不是“加密协议”，长度也不代表加密强度 |
| 本地 → 香港前置 | 是否加密、如何伪装取决于机场节点实际使用的协议 | 不能只凭入口域名推断 TLS、Reality、Trojan 或其他协议 |
| 客户端 → Oregon SS AEAD | `aes-256-gcm` 使用密码派生密钥，加密并认证内层负载 | 它不会隐藏 Oregon IP、18443 端口、连接时序或流量大小，也不能等同于 SS2022 的重放防护 |
| 香港前置可见范围 | 可以看到 Oregon 地址、端口和流量特征 | 在终端与密码未失陷、实现正常的前提下，不能直接读取 SS AEAD 明文 |

### 部署前备份

```bash
# 为本次变更创建带时间戳的备份；备份同样含已有 Reality 凭据，禁止上传
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="/usr/local/etc/xray/config.json.bak-ss-chain-${STAMP}"
sudo cp -a /usr/local/etc/xray/config.json "$BACKUP"
sudo chmod 600 "$BACKUP"
printf 'Backup: %s\n' "$BACKUP"
```

> [!CAUTION]
> 凭据只在本机生成和保存
>
> 传统 `aes-256-gcm` 接受任意字符串密码；Xray 官方建议至少 16 个字符。可在受信任终端运行 `openssl rand -base64 24` 生成高熵密码并立即存入密码管理器；不要把输出粘贴到文档、聊天、截图、Git、订阅示例或工单中。本文统一使用 `<SHADOWSOCKS_PASSWORD>` 占位。

### 添加 `ss-chain` 入站

用 `sudoedit /usr/local/etc/xray/config.json` 编辑现有配置，在 `inbounds` 数组中追加下面的对象；把密码占位符替换为刚生成的密钥。不要删除原有 443 Reality 入站，也不要复制真实 Reality 参数到本文。

```json
{
  "listen": "0.0.0.0",
  "port": 18443,
  "protocol": "shadowsocks",
  "settings": {
    "network": "tcp",
    "method": "aes-256-gcm",
    "password": "<SHADOWSOCKS_PASSWORD>"
  },
  "sniffing": {
    "enabled": true,
    "destOverride": ["http", "tls"]
  },
  "tag": "ss-chain"
}
```

`sniffing` 让既有 `ai-services` 域名规则继续识别 Claude / Anthropic 流量；SS 入站与 443 Reality 入站共用第 5 章的 `direct`、`warp` 和路由规则，不需要复制第二套出站配置。为保留来源证据，在现有 `log` 对象中确认或补充 `"access": "/var/log/xray/access.log"`，并把 `"loglevel"` 设为 `"info"`（或更详细的 `"debug"`）。如果不设置 `access` 路径，访问日志可能只进入服务标准输出；设为 `none` 则会关闭访问日志，后面的文件验证将无日志可读。字段语义见 [Xray 日志官方文档](https://xtls.github.io/en/config/log.md)。

可用方法与传统 AEAD 密码要求可对照 [Xray Shadowsocks inbound 官方文档](https://xtls.github.io/en/config/inbounds/shadowsocks.md)。不要把 AES 密钥长度“256”误解为必须手工提供 32 字节密码；Xray 会从密码派生加密密钥。

### 配置校验与重启

下面是一段 fail-closed 部署检查：把 `<BACKUP_FILE_FROM_DEPLOYMENT_STEP>` 换成上一步实际打印的备份路径后整体执行。任何语法、字段、密钥、二进制或端口预检失败都会在重启前退出，当前运行中的 443 主入口不受影响；只有全部预检通过才会重启。

```bash
set -euo pipefail
CONFIG="/usr/local/etc/xray/config.json"
BACKUP="<BACKUP_FILE_FROM_DEPLOYMENT_STEP>"
sudo test -r "$BACKUP"

# 1. JSON 语法与关键字段（不会打印密码）
sudo jq empty "$CONFIG"
sudo jq -e '
  ([.inbounds[] | select(.tag == "ss-chain")] | length) == 1 and
  any(.inbounds[];
    .tag == "ss-chain" and .port == 18443 and .protocol == "shadowsocks" and
    .settings.method == "aes-256-gcm" and .settings.network == "tcp" and
    (.settings.password | type == "string" and length >= 16)) and
  .log.access == "/var/log/xray/access.log" and
  (.log.loglevel == "info" or .log.loglevel == "debug")
' "$CONFIG" >/dev/null

# 2. 确认二进制存在，并排除其他程序占用 18443
XRAY_BIN="$(command -v xray || true)"
test -n "$XRAY_BIN"
if sudo ss -ltnp 'sport = :18443' | grep -q LISTEN && \
   ! sudo ss -ltnp 'sport = :18443' | grep -q xray; then
  echo 'TCP 18443 is already used by another process' >&2
  exit 1
fi
sudo "$XRAY_BIN" run -test -config "$CONFIG"

# 3. 只有前两项都通过才重启；最多等待 15 秒让两个监听就绪
READY=0
if sudo systemctl restart xray; then
  for _ in $(seq 1 30); do
    if sudo systemctl is-active --quiet xray && \
       sudo ss -ltnp | grep -q ':443 ' && \
       sudo ss -ltnp | grep -q ':18443 '; then
      READY=1
      break
    fi
    sleep 0.5
  done
fi
if test "$READY" -ne 1; then
  echo 'Deployment failed; restoring the recorded backup' >&2
  sudo cp -a "$BACKUP" "$CONFIG"
  sudo "$XRAY_BIN" run -test -config "$CONFIG"
  sudo systemctl restart xray
  exit 1
fi
sudo systemctl --no-pager --full status xray
sudo ss -ltnp | grep -E ':443 |:18443 '
```

### 遗失节点配置时生成恢复链接

服务器已把仓库中的 `scripts/generate-ss-chain-link.sh` 安装为 `/usr/local/sbin/generate-ss-chain-link`，所有者为 `root:root`、权限为 `700`。脚本会直接读取当前 Xray 配置中的方法、密码和端口，且不会在脚本里复制第二份密码。AWS Lightsail 可通过 IMDS 自动检测公网 IP；GCP 不使用 AWS IMDS，必须显式传入当前外部地址。

```bash
# AWS Lightsail：默认从 IMDS 读取公网 IP
sudo /usr/local/sbin/generate-ss-chain-link

# GCP 或 AWS IMDS 不可用：必须显式传入当前外部地址
sudo /usr/local/sbin/generate-ss-chain-link <GCP_EXTERNAL_IP>
```

> [!CAUTION]
> 恢复链接本身就是完整凭据
>
> 只在受信任终端中运行并直接导入客户端；不要把输出粘贴到聊天、命令日志、截图、Git 或工单。脚本源文件不含真实密码，真实密码只从权限受限的 Xray 配置中读取。

链接格式遵循 [Shadowsocks SIP002 URI Scheme](https://github.com/shadowsocks/shadowsocks-org/wiki/SIP002-URI-Scheme)；传统 AEAD 使用 Base64URL 编码的 `method:password` 作为 userinfo。

### Lightsail 防火墙

1. 进入 **Lightsail → Instances → Oregon 实例 → Networking → IPv4 Firewall**。
2. 新增 **Custom / TCP / 18443**；443 规则保持不变，不要把主入口改到 18443。
3. 如果香港前置的实际出口 IP 固定，可在**同一条 18443 规则**上启用来源限制并填写 `<HK_FRONT_EGRESS_IP>/32`。如果之前已建 allow-all 规则，应编辑或删除它，不能同时保留 allow-all 与 `/32` 两条规则，否则较宽的规则会使限制失效。操作方式可对照 [Lightsail 防火墙官方说明](https://docs.aws.amazon.com/lightsail/latest/userguide/understanding-firewall-and-port-mappings-in-amazon-lightsail.md)。
4. 智能入口或 IEPL 的 NAT 出口可能变化，限制来源前先以服务端日志确认，否则会误封。
5. 只在确实使用 IPv6 链式连接时同步开放 IPv6 TCP 18443。

### 验证链路与出口

```bash
# Android 发起请求时，在 Oregon 观察 ss-chain 入站；示例值全部脱敏
sudo tail -f /var/log/xray/access.log | grep 'ss-chain'

# 预期形态（不要把真实日志提交到仓库）
<TIMESTAMP> from <HK_FRONT_EGRESS_IP>:<SOURCE_PORT> accepted ... [ss-chain -> direct]
<TIMESTAMP> from <HK_FRONT_EGRESS_IP>:<SOURCE_PORT> accepted ... [ss-chain -> warp]
```

| 证据 | 证明力 |
| --- | --- |
| 普通网站检测到的公网 IP 与 `<OREGON_SERVER_IP>` 完全一致（或与独立确认的 Oregon `direct` NAT 出口一致），Claude / Anthropic 显示 WARP 出口 | 证明 Oregon 服务端的 direct/WARP 出站符合预期；**不能单独证明经过香港前置** |
| v2rayNG 生成配置中 Oregon outbound 的 `dialerProxy` 引用香港 outbound | 证明客户端生成了链式拨号意图，但仍属于配置证据 |
| Oregon 日志中 `ss-chain` 的来源是前置中转网络 | **前置实际生效的关键运行证据**；建议记录时间窗口并做关闭/开启前置的 A/B 对照 |

> [!NOTE]
> 不要只靠 IP 地理库判断“是不是香港”
>
> 智能入口或 IEPL 的入口 DNS、节点物理位置、连接 Oregon 时使用的出口 NAT IP 可能分别属于不同网络。服务端看到的来源未必被 GeoIP 标成香港；应结合 `dialerProxy`、同一时间窗口的 `ss-chain` 日志和前置开关 A/B 对照判断。同理，IP 检测页如果只显示“美国”或“Oregon”地区标签，只能说明地理库对出口的分类，不能证明它就是这台 Oregon 服务器。

> [!TIP]
> 已完成的实测闭环
>
> - Oregon SS AES-256-GCM / TCP 18443 可以连接；
> - 普通网站从 Oregon `direct` 出站；
> - Claude / Anthropic 命中服务端 WARP 分流；
> - v2rayNG 使用香港前置后，页面访问和美国出口正常；
> - Oregon 日志确认请求来自前置网络并进入 `ss-chain`。

### 回滚

```bash
# 使用部署前记录的实际备份路径；不要原样使用占位符
BACKUP="<BACKUP_FILE_FROM_DEPLOYMENT_STEP>"
sudo cp -a "$BACKUP" /usr/local/etc/xray/config.json

XRAY_BIN="$(command -v xray)"
sudo "$XRAY_BIN" run -test -config /usr/local/etc/xray/config.json
sudo systemctl restart xray
sudo systemctl --no-pager --full status xray

# 最后在 Lightsail 控制台删除 Custom TCP 18443 规则
```

回滚后确认 443 Reality 仍监听并可连接，再删除包含旧凭据的临时副本。带凭据的正式备份应保持 `600` 权限、只存于服务器，不上传 Git 或云盘。

<a id="client"></a>

## 7. 本地客户端配置（V2rayN / V2rayNG）

服务端搭好后，本地需要安装代理客户端连接。macOS 使用 **V2rayN**，Android 使用 **V2rayNG**，底层都是 Xray-core 内核，原生支持 XHTTP Reality 协议。

> [!NOTE]
> Android 链式配置已拆到客户端机制文档
>
> 本章保留 Reality 直连的通用安装和排障；香港机场前置 → Oregon SS AES-256-GCM 的 `dialerProxy`、加密边界和证据判断见 [V2rayNG Android 链式代理](v2ray_proxy_guide.md#android-chain)。

### 安装客户端

| 平台 | 客户端 | 下载 |
| --- | --- | --- |
| macOS (Apple Silicon) | **V2rayN** | GitHub Releases 下载 `v2rayN-macos-arm64.dmg` |
| macOS (Intel) | **V2rayN** | GitHub Releases 下载 `v2rayN-macos-64.dmg` |
| Android | **V2rayNG** | Google Play 或 GitHub Releases |

### 添加节点（推荐：终端二维码扫码）

1. **SSH 连接服务器**

    ```bash
    ssh -i ~/path/to/LightsailKey.pem ubuntu@<服务器IP>
    ```

2. **启动管理菜单，选 7 显示二维码**

    ```bash
    sudo bash /root/Xray-script.sh
    # 输入 7 → 终端显示分享链接和二维码
    ```

3. **扫码添加**
    - **V2rayN (Mac)**：菜单栏 → 扫描屏幕二维码（或复制分享链接 → 从剪贴板导入）
    - **V2rayNG (Android)**：右上角 `+` → 扫描二维码（对着电脑终端扫）

> [!NOTE]
> 为什么推荐扫码而不是分享链接
>
> 实测发现分享链接导入时，部分客户端版本会错误映射 Reality 的 `publicKey` 和 `password` 字段，导致连接报错 `invalid "password"`。扫码走不同的解析路径，不存在这个问题。

### 路由模式设置

| 客户端 | 操作 | 效果 |
| --- | --- | --- |
| V2rayN (Mac) | 底部状态栏 → 路由 → 选「绕过大陆」 | 国内直连，海外走代理 |
| V2rayNG (Android) | 左侧菜单 → 设置 → 预定义规则 → 选「绕过局域网及大陆地址」 | 同上 |

选择「绕过大陆」后，ChatGPT、Claude、YouTube、Google、Telegram 等海外服务自动走代理，不需要手动添加域名规则。

### 连接不通排查

| 检查项 | 命令 / 操作 | 说明 |
| --- | --- | --- |
| **1\. Lightsail 防火墙** | 控制台 → 实例 → Networking → IPv4 Firewall | Reality 主入口必须有 `Custom TCP 443`；启用链式备用时还要有 `Custom TCP 18443` |
| 2\. Xray 是否运行 | `sudo systemctl status xray` | 确认 Active: active (running) |
| 3\. 端口是否监听 | `sudo ss -tlnp \| grep -E ':443 \|:18443 '` | 443 必须监听；启用 SS 链式备用时 18443 也必须监听 |
| 4\. 服务端日志 | `sudo tail -30 /var/log/xray/error.log` | 检查是否有连接记录或错误 |
| 5\. WARP 状态 | `warp-cli --accept-tos status` | 应显示 Connected, healthy |

### 网络链路质量问题

国内到不同 Region 的实际延迟和稳定性取决于运营商国际出口：

| 现象 | 原因 | 应对 |
| --- | --- | --- |
| 连接超时、频繁断开 | 运营商国际出口拥堵或 DPI 干扰 | 换时段（晚高峰最差）、换 Region |
| SSH 输入卡顿 | 高延迟 + 丢包 | 用 Lightsail 自带浏览器终端，或安装 `mosh` |
| 持续严重丢包 | IP 段或线路被针对 | 快照 → 新建实例换 IP（免费） |

> [!NOTE]
> mosh 安装（替代 SSH，可选）
>
> mosh 对高延迟和丢包的容忍度远优于 SSH，推荐在链路质量差时使用：<br>
> 服务器：`sudo apt install -y mosh`（Lightsail 防火墙需开放 UDP 60000-61000）<br>
> macOS：`brew install mosh`<br>
> 连接：`mosh --ssh="ssh -i ~/path/to/key.pem" ubuntu@<IP>`

### IP 被墙后的恢复操作

GFW 的 DPI 可能将你的 Lightsail 静态 IP 加入黑名单，表现为：客户端突然无法连接，测试延迟显示超时或 `io: read/write on closed pipe`，但服务端 Xray 和 WARP 状态正常。

> [!CAUTION]
> 如何判断 IP 被墙
>
> - 客户端（V2rayN / V2rayNG）连接超时或测速失败
> - Lightsail 浏览器终端能正常 SSH（说明服务器本身没问题）
> - 本地终端 `ssh -i key.pem ubuntu@<IP>` 也超时（说明 IP 被墙，不只是 443 端口）
> - 同一节点在其他国家/地区的网络下能正常连接

#### 恢复步骤（约 2 分钟）

1. **Lightsail 控制台释放旧静态 IP**<br>
    Networking → Static IPs → 选中被墙的 IP → Detach → Delete
2. **分配新静态 IP**<br>
    Static IPs → Create → 关联到同一实例 → 记下新 IP 地址<br>
    *免费操作，不额外收费*
3. **更新客户端节点**：二选一
    - **快速方式**：直接编辑客户端节点配置，把 `address` 改成新 IP，其他参数（UUID、密钥、path、SNI）不变
    - **稳妥方式**：SSH 到服务器（用新 IP）→ `sudo bash /root/Xray-script.sh` → 选 7 显示新二维码 → 删掉旧节点，扫码添加新节点

> [!NOTE]
> 为什么服务端不用改任何配置
>
> Xray 主入口监听 `0.0.0.0:443`；启用链式备用时还监听 `0.0.0.0:18443`。配置文件中不含服务器自身公网 IP。换 IP 后 Xray、WARP、分流路由全部自动生效，但 Reality 和 SS AES-256-GCM 两个客户端节点的 Oregon 地址都要同步更新。

> [!WARNING]
> 降低被墙概率
>
> - **选 XHTTP 而非 Vision**：Vision 使用 TCP 长连接，DPI 容易识别并干扰握手（实测 Tokyo Vision 握手成功率仅 1.4%）。XHTTP 伪装为普通 HTTP 请求，DPI 无法区分
> - **避开高风险线路**：中日线路是 GFW 重点监控路线（日本是代理用户首选目的地），中美线路 DPI 力度相对较轻
> - **不同网络表现不同**：同一节点在家宽 WiFi 下可能正常，移动数据下可能被拦截（运营商移动网络的国际出口 DPI 更集中）
> - **换 AZ**：同 Region 内不同可用区（如 `us-west-2b` vs `2c`）的 IP 段不同，被墙概率也不同

<a id="residential"></a>

## 8. 住宅 IP 代理方案（可选）

### 什么时候需要住宅 IP

当 WARP 出口仍被 Claude 风控时才需要。WARP 本质还是 Cloudflare 数据中心 IP（AS 13335），如果被标记，需要叠加一层**真实住宅 IP** 作为最终出口。住宅 IP 来自美国家庭宽带运营商（Comcast、AT&T、Verizon 等），平台几乎无法将其与正常美国用户区分。

> [!NOTE]
> 先试 WARP，不行再加
>
> 住宅 IP 是备选方案，不是必须。大多数情况下 WARP 已经足够。先跑一两周观察，确认被风控后再购买住宅 IP，避免不必要的开支。

### 选择 ISP 静态住宅代理

代理市场产品很多，但适合你场景的只有一种：

| 类型 | 说明 | 适合吗 |
| --- | --- | --- |
| 动态住宅代理（按流量） | IP 每次请求轮换，按 GB 计费 | 不适合 Claude 需要固定 IP |
| **ISP 静态住宅代理（按 IP 包月）** | 固定一个住宅 IP，长期不变 | 最适合 稳定不触发风控 |
| 数据中心代理 | 机房 IP，便宜但信誉差 | 不适合 和裸 Lightsail 一样 |

### 服务商推荐

只需要 **1 个美国静态住宅 IP**，按性价比排列：

| 服务商 | 价格 | 流量 | 协议 | 特点 |
| --- | --- | --- | --- | --- |
| **Proxy-Cheap** | ~$3/月（年付） | 需搭配流量包 | HTTP/SOCKS5 | 性价比最高，700万+ IP 池，Claude 用户口碑好 |
| **IPRoyal** | ~$4-5/月 | 无限流量（部分套餐） | HTTP/SOCKS5 | 简单易用，195 国覆盖 |
| **922S5** | ~$5/月 | 无限流量 | HTTP/SOCKS5 | 支持支付宝，中文友好 |
| Oxylabs | ~$1.6-3.2/IP/月 | 无限带宽（高级） | HTTP/SOCKS5 | 企业级品质，10 IP 起购 |
| Bright Data | ~$1.8/IP/月 | 按量另计 | HTTP/SOCKS5 | 行业标杆，但贵且复杂 |

> [!TIP]
> 推荐：Proxy-Cheap 或 IPRoyal
>
> 一个美国静态住宅 IP 月费 $3-5。加上 Lightsail $5，总代理成本 $8-10/月。922S5 支持支付宝付款，如果不想折腾外币支付可以优先考虑。

### 架构变化

叠加住宅 IP 后，Xray 出站链路从 WARP 替换为住宅代理：

```text
本地客户端
    │  VLESS-XHTTP-Reality
    ▼
AWS Lightsail
    │
    ├── 普通流量 ──→ 直连出站
    │
    └── Claude / OpenAI ──→ 住宅代理 (SOCKS5)  ← 替换 WARP
                                  │
                                  ▼
                        美国家庭宽带 IP  (Comcast / AT&T / Verizon)
                                  │
                                  ▼
                         claude.ai / openai.com
```

### Xray 配置变更

把 WARP 出站替换为住宅代理出站，路由规则中 `"outboundTag": "warp"` 改为 `"outboundTag": "residential"`：

```json
{
  "outbounds": [
    {
      "tag": "direct",
      "protocol": "freedom"
    },
    {
      "tag": "residential",
      "protocol": "socks",
      "settings": {
        "servers": [
          {
            "address": "代理商提供的地址",
            "port": 代理商提供的端口. ,
            "users": [
              {
                "user": "你的用户名",
                "pass": "你的密码"
              }
            ]
          }
        ]
      }
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "domain": [
          "anthropic.com",
          "claude.ai",
          "openai.com",
          "chatgpt.com"
        ],
        "outboundTag": "residential"
      },
      {
        "type": "field",
        "network": "tcp,udp",
        "outboundTag": "direct"
      }
    ]
  }
}
```

### 购买前验证 IP 质量

拿到 IP 后，**先用以下工具检测，确认质量合格后再绑定 Claude 账号**：

| 工具 | 检测内容 | 合格标准 |
| --- | --- | --- |
| `ipinfo.io` | IP 类型 | 显示为 `isp` 或 `residential`（不是 `hosting`） |
| `scamalytics.com` | 欺诈风险评分 | 分数 < 10（满分 100，越低越好） |
| `whoer.net` | 匿名度 + DNS 泄露 | 匿名度 > 90%，无 DNS 泄露 |
| `ping0.cc` | 原生 vs 广播 IP | 优先选原生 IP（native），广播 IP 质量稍差 |

> [!WARNING]
> 避免踩坑
>
> - 部分低价服务商用数据中心 IP 冒充住宅 IP，务必用上述工具验证
> - 买之前确认支持**美国地区**且可以**指定州/城市**
> - 选择和 Lightsail 同区域（Oregon / 美西）的住宅 IP，减少延迟
> - 一个 IP 只绑定一个 Claude 账号，不要多账号共用

### 总成本对比

| 方案 | 代理月费 | IP 信誉 | 适用场景 |
| --- | --- | --- | --- |
| Lightsail 裸 IP | $5 | 低 | 临时使用、非敏感服务 |
| Lightsail + WARP | $5 | 中等 | 默认方案，大多数情况够用 |
| Lightsail + 住宅 IP | $8-10 | 高 | WARP 被风控后的终极方案 |

<a id="security"></a>

## 9. 安全与风控注意事项

### 服务器安全

- SSH 私钥本地加密保存，不传到任何云服务
- 系统安装后立即 `sudo apt update && sudo apt upgrade`
- 建议创建非 root 用户，禁用密码登录，仅密钥认证
- 防火墙最小化：默认只开 22（SSH）+ 443（Reality）；仅在使用链式备用时开放 18443，并在可行时限制前置出口来源
- SSH 考虑换端口或限制来源 IP
- 云厂商管理代理只在确认不用时禁用：AWS 的 SSM 与 GCP 的 Guest Agent / OS Config / Ops Agent 不是同一套服务

> [!TIP]
> 1Panel 通过 SSH 隧道访问
>
> 不要在云防火墙中长期向公网开放 1Panel 端口。关闭公网规则后，在本机建立隧道，再访问面板原有安全入口：
>
> ```bash
> ssh -L 31900:127.0.0.1:31900 -i ~/.ssh/<GCP_PRIVATE_KEY> \
>   <GCP_USER>@<GCP_EXTERNAL_IP>
> # 浏览器访问 http://127.0.0.1:31900/<原安全入口>
> ```

### 账号风控

| 注意事项 | 说明 |
| --- | --- |
| 注册邮箱 | 使用 Gmail 等国际邮箱，不用国内邮箱 |
| 账号信息 | 名字和个人资料用英文，不要绑定中国手机号 |
| IP 一致性 | 注册时就走代理，后续保持同一出口 IP |
| 固定 Claude 出口 | Claude 流量始终走同一个节点的 WARP 出口，不要今天美国明天日本。日常浏览可以用另一个节点 |
| 一 IP 一账号 | 同一个 WARP 出口 IP 不要登录多个 Claude 账号，多账号共用 IP 最容易触发关联封禁 |
| 地区一致性 | 付款地址、IP 所在地保持逻辑一致 |
| 设备稳定 | 不要频繁切换设备和 IP |
| 浏览器语言 | `chrome://settings/languages` 把 English (US) 调到第一位，避免 `Accept-Language: zh-CN` 和美国 IP 矛盾 |

> [!CAUTION]
> 高风险组合（避免）
>
> 新注册账号 + 频繁切换 IP + 支付信息地区不一致 — 这种组合最容易触发封号。

> [!NOTE]
> 关于"付款地址尼日利亚 vs 使用 IP 美国"是否矛盾
>
> **尼日利亚在 Anthropic 官方支持的国家列表中**（见 [anthropic.com/supported-countries](https://www.anthropic.com/supported-countries)），理论上用尼日利亚 IP 访问 Claude 是被允许的。
>
> 曾考虑过购买尼日利亚拉各斯 VPS 作为 Claude 出口，让付款地址（Timon 卡）和使用 IP 地区完全一致。调研结论：**性价比不高，放弃。**
>
> | 方案 | 价格 | 结论 |
> | --- | --- | --- |
> | zhaomu.com 拉各斯 O 区 VPS | ¥79/月 | 最靠谱的选项，支持退款，但额外增加 ¥79/月成本 |
> | IPRoyal Residential（Nigeria） | ~$1.75/GB | 需确认是否有尼日利亚 IP 库存（联系客服确认） |
> | IPRoyal ISP 静态（Nigeria） | — | 已无库存 |
> | SurferCloud 拉各斯 | ~$5.9/月（首月） | 不推荐——三次换壳历史、稳定性差、退款困难、信用卡被盗刷投诉 |
>
> **实际结论：不需要尼日利亚 IP。**Claude 账号没有区域概念——订阅通过 App Store，Claude 只知道你是 Pro 用户，不知道你付了多少钱。大量国内用户用美国/日本 IP + 尼区 App Store 订阅长期正常使用。封号更可能是 IP 信誉、行为模式等因素导致，不是"付款尼日利亚 + 使用美国"这种地区不一致。继续用 **Lightsail + WARP 美国出口**即可。

### 代理出口质量检测

配置完成后，开着代理逐一访问以下网站，确认出口 IP 的健康度和有无信息泄露：

#### 1. 确认 Claude 流量走了 WARP

普通网站（如 ipinfo.io）走的是 Xray 直连出站，看到的是 Lightsail IP，不代表 Claude 的实际出口。需要用终端测试 Claude 域名：

```bash
# 测试 Claude 域名的实际出口（端口按你的客户端配置）
curl --proxy http://127.0.0.1:10809 https://api.anthropic.com/cdn-cgi/trace

# 确认输出中：
# warp=on     ← 走了 WARP
# ip=104.x.x.x ← Cloudflare IP，不是 AWS IP
```

#### 2. IP 风险评分

拿到上面的 Cloudflare 出口 IP 后，访问 `https://scamalytics.com/ip/<你的IP>` 查看风险评分：

| 评分 | 等级 | 说明 |
| --- | --- | --- |
| 0-14 | 优秀 | 正常 Cloudflare IP 通常在此区间 |
| 15-30 | 正常 | 低风险，可放心使用 |
| 30-60 | 注意 | 有一定风险标记，观察使用 |
| 60+ | 危险 | 高风险，考虑换出口方案 |

同时关注页面下方的 **External Blacklists**（Firehol / Spamhaus 等），全部应为 `No`。

#### 3. 防泄露检查

开着代理在浏览器中逐一访问：

| 检测地址 | 检查什么 | 合格标准 |
| --- | --- | --- |
| `https://browserleaks.com/dns` | DNS 泄露 | DNS 服务器应为 Cloudflare / Google / Alidns，不应出现中国 ISP 的 DNS（如运营商 DNS） |
| `https://browserleaks.com/webrtc` | WebRTC 泄露 | 不应显示你的真实内网/公网 IP。建议安装 Chrome 扩展 `WebRTC Leak Shield`（选择 Disable non-proxied UDP 模式，不影响视频通话） |
| `https://whoer.net` | 综合匿名度 | 匿名度 >90%，时区/语言/IP 地区应一致 |

> [!NOTE]
> 实测参考值（WARP 出口）
>
> | 指标 | 实测值 |
> | --- | --- |
> | Scamalytics 评分 | 14/100（Low Risk） |
> | ISP 归属 | Cloudflare, Inc.（AS 13335） |
> | VPN / Tor / 公共代理检测 | 全部 No |
> | 外部黑名单 | 全部 No |
>
> WARP 出口 IP 质量整体良好，远优于裸 Lightsail IP。

### 线路稳定性

- Oregon 区域偶尔有线路波动，可尝试不同可用区（`us-west-2a` / `2b`）
- 备选区域：`ap-northeast-1`（Tokyo），延迟更低（~70ms vs ~240ms），线路更稳定，但日本 IP 对部分美区服务可能有限制
- 建议多区域部署（如 Oregon + Tokyo），前 3 个月免费额度按实例独立计算，测完保留效果好的
- 如果 IP 被墙，删掉静态 IP 重新分配即可（免费操作）
- 配置稳定后做一个快照（Snapshot）留底，方便快速恢复

### geodata.dat 自动更新踩坑与修复

> [!CAUTION]
> 实测踩坑：Xray-script 自带的 geodata 更新脚本会搞崩 Xray
>
> **现象**：某天突然所有客户端连不上,服务器 443 端口显示 `Connection refused`,Xray 状态为 failed,错误信息：
>
> ```text
> Failed to start: infra/conf: code not found in geoip.dat: PRIVATE
> ```
>
> **根因**：Xray-script 安装时在 root crontab 注册了一个定时任务：
>
> ```text
> 30 6 * * * /usr/local/xray-script/tool/geodata.sh
> ```
>
> 每天 06:30 UTC 自动从 GitHub 下载最新的 `geoip.dat` 和 `geosite.dat`。**原始脚本的致命缺陷**：curl 遇到 GitHub 限流/网络抖动时可能返回成功退出码但文件不完整（实测只拿到 20 字节），脚本不校验文件大小就直接 `rm` 旧文件 + `mv` 覆盖 → Xray 重启时读到损坏文件 → crash。
>
> **为什么 Tokyo 比 Oregon 更容易出事**：Tokyo 到 GitHub CDN（美国）经过太平洋海底光缆，偶尔丢包/限流导致下载中断；Oregon 在美国本土，到 GitHub 的链路天然更稳定。

#### 修复方案：安全更新脚本

替换 `/usr/local/xray-script/tool/geodata.sh` 为以下版本（两台服务器都需要）：

```bash
#!/usr/bin/env bash

set -Eeuo pipefail
umask 077

XRAY_DIR="/usr/local/share/xray"
CONFIG="/usr/local/etc/xray/config.json"
LOG_FILE="/var/log/geodata-update.log"
MIN_SIZE=1048576  # 1 MiB；正常文件远大于此值

GEOIP_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
GEOSITE_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"

# 临时文件和备份放在目标文件系统内，后续 mv 才是原子替换
TMP_DIR="$(mktemp -d "$XRAY_DIR/.geodata-update.XXXXXX")"
BACKUP_DIR="$(mktemp -d "$XRAY_DIR/.geodata-backup.XXXXXX")"
cleanup() { rm -rf -- "$TMP_DIR" "$BACKUP_DIR"; }
trap cleanup EXIT

log() { printf '[%s] %s\n' "$(date)" "$*" >> "$LOG_FILE"; }

download() {
  curl -fsSL --connect-timeout 15 --max-time 120 \
    --retry 3 --retry-all-errors -o "$2" "$1"
}

if ! download "$GEOIP_URL" "$TMP_DIR/geoip.dat"; then
  log "ERROR: failed to download geoip.dat"
  exit 1
fi
if ! download "$GEOSITE_URL" "$TMP_DIR/geosite.dat"; then
  log "ERROR: failed to download geosite.dat"
  exit 1
fi

for name in geoip.dat geosite.dat; do
  size="$(stat -c%s "$TMP_DIR/$name" 2>/dev/null || printf 0)"
  if [ "$size" -lt "$MIN_SIZE" ]; then
    log "ERROR: $name too small (${size} bytes), aborting"
    exit 1
  fi
  cp -a "$XRAY_DIR/$name" "$BACKUP_DIR/$name"
  install -o root -g root -m 0644 \
    "$TMP_DIR/$name" "$XRAY_DIR/.$name.new"
  mv -f "$XRAY_DIR/.$name.new" "$XRAY_DIR/$name"
done

XRAY_BIN="$(command -v xray)"
XRAY_USER="$(systemctl show xray -p User --value)"
XRAY_USER="${XRAY_USER:-root}"

validate_xray() {
  if [ "$XRAY_USER" = root ]; then
    "$XRAY_BIN" run -test -config "$CONFIG"
  else
    runuser -u "$XRAY_USER" -- \
      "$XRAY_BIN" run -test -config "$CONFIG"
  fi
}

rollback_geodata() {
  for name in geoip.dat geosite.dat; do
    cp -a "$BACKUP_DIR/$name" "$XRAY_DIR/.$name.rollback"
    mv -f "$XRAY_DIR/.$name.rollback" "$XRAY_DIR/$name"
  done
}

if ! validate_xray; then
  rollback_geodata
  log "ERROR: Xray validation failed; geodata rolled back"
  exit 1
fi

if systemctl --quiet is-active xray; then
  if ! systemctl restart xray || ! systemctl --quiet is-active xray; then
    rollback_geodata
    validate_xray
    systemctl restart xray
    log "ERROR: Xray restart failed; geodata rolled back"
    exit 1
  fi
fi

geoip_size="$(stat -c%s "$XRAY_DIR/geoip.dat")"
geosite_size="$(stat -c%s "$XRAY_DIR/geosite.dat")"
log "OK: geoip=${geoip_size} geosite=${geosite_size}"
```

#### 新旧脚本对比

| 维度 | 旧脚本（Xray-script 默认） | 新脚本 |
| --- | --- | --- |
| 下载位置 | 直接下载到目标目录 | 在目标文件系统创建隐藏临时目录 |
| 下载校验 | 只依赖 curl 结果 | `curl -f`、超时、重试，并要求每个文件 ≥ 1 MiB |
| 文件权限 | 受 root `umask` 影响 | 固定为 `root:root 0644`，`User=xray` 可读 |
| 替换方式 | 删除旧文件后覆盖 | 同一文件系统内 `mv` 原子替换 |
| Xray 校验 | 无 | 以 systemd 的 `User=` 运行 `xray run -test` |
| 失败处理 | 旧文件可能已丢失 | 配置测试或重启失败时恢复两份旧文件 |
| 日志 | 输出被丢弃 | 写入 `/var/log/geodata-update.log` |
| 临时文件清理 | 手动处理 | `trap cleanup EXIT` 自动清理 |

#### 部署步骤（两台服务器都要做）

```bash
# 备份旧脚本
sudo cp /usr/local/xray-script/tool/geodata.sh /usr/local/xray-script/tool/geodata.sh.bak

# 粘贴新脚本内容覆盖（或 scp 上传）
sudo nano /usr/local/xray-script/tool/geodata.sh

# 固定所有者和权限，避免 updater 被非 root 用户修改
sudo chown root:root /usr/local/xray-script/tool/geodata.sh
sudo chmod 0700 /usr/local/xray-script/tool/geodata.sh

# 确认 cron 只有一条，再手动跑一次验证
sudo crontab -l | grep -F '/usr/local/xray-script/tool/geodata.sh'
sudo /usr/local/xray-script/tool/geodata.sh
sudo tail -5 /var/log/geodata-update.log
sudo stat -c '%a %U:%G %n' /usr/local/share/xray/geoip.dat \
  /usr/local/share/xray/geosite.dat
# 日志应显示 OK，两个 dat 文件应为 644 root:root
```

#### 如果已经崩了,紧急恢复

```bash
# 重新下载正确的 geoip.dat（18MB+）
sudo wget -O /usr/local/share/xray/geoip.dat \
  https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat

# 重新下载 geosite.dat（10MB+）
sudo wget -O /usr/local/share/xray/geosite.dat \
  https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat

# 验证大小（geoip 应 >5MB, geosite 应 >3MB）
ls -lh /usr/local/share/xray/geo*.dat

# 重启 Xray
sudo systemctl restart xray
sudo ss -tlnp | grep 443
```

> [!NOTE]
> 日常监控
>
> 部署新脚本后,偶尔看一眼日志确认每天的自动更新是否正常:
>
> ```bash
> tail -5 /var/log/geodata-update.log
> ```
>
> 正常输出形如: `[Fri Jun 27 06:30:01 UTC 2026] OK: geoip=18612345 geosite=10234567`<br>
> 异常输出会说明是下载、校验还是重启失败；安全脚本会保留或恢复旧文件。
>
> [!WARNING]
> Xray-script 自身更新可能覆盖这个 updater；更新脚本后要重新核对文件内容、`0700` 权限、cron 是否只有一条，并手动执行一次。它也可能重建 Xray 主配置，因此同时复查 `warp`、`ai-services` 与 `ss-chain`。

整理于 2026 年 6 月 · GCP 实战补充于 2026 年 7 月 · 仅供个人学习与技术参考

本文档从 [海外 AI 服务订阅指南](ai_subscription_guide.md) 拆分而来，订阅/支付/eSIM 相关内容请参阅原文档。

客户端链式代理、`dialerProxy` 与 Android 验证见 [V2rayN / V2rayNG 代理机制详解](v2ray_proxy_guide.md#android-chain)。
