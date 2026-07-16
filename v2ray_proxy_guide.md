# V2rayN / V2rayNG 代理机制详解

Tun、系统代理、路由规则与 Android 链式代理，以及流量在客户端和 Oregon 服务端的完整路径

## 目录

1. [核心概念：流量怎么被代理](#overview)
2. [桌面端（V2rayN macOS / Windows）](#desktop)
3. [移动端（V2rayNG Android）](#mobile)
4. [Android：香港前置 → Oregon SS AES-256-GCM](#android-chain)
5. [路由规则详解](#routing)
6. [终端程序的代理配置](#terminal)
7. [常见场景配置推荐](#scenarios)

<a id="overview"></a>

## 1. 核心概念：流量怎么被代理

代理的本质是**拦截流量 → 判断去向 → 转发或直连**。V2rayN/V2rayNG 把这个过程分成三个独立的层次，理解这三层是搞清楚所有配置的关键。

### 三层过滤模型

流量经过三层逐层筛选，可以理解为漏斗：

```text
应用发出流量
    │
    ▼
┌─────────────────────────────┐
│ 第 1 层：流量捕获             │  ← 决定哪些流量进入代理管道
│ (Tun / 系统代理 / VPN API)   │     不同平台机制不同
└─────────────────────────────┘
    │ (进入管道的流量)
    ▼
┌─────────────────────────────┐
│ 第 2 层：路由规则             │  ← 对进入管道的流量按域名/IP 分流
│ (绕过大陆 / 全局 / 黑名单)   │     决定 direct / proxy / block
└─────────────────────────────┘
    │
    ▼
┌─────────────────────────────┐
│ 第 3 层：出站代理节点         │  ← 需要代理的流量走哪个服务器
│ (Reality 443 主入口 /       │
│  SS AES-256-GCM 18443 备用) │
└─────────────────────────────┘
```

> [!NOTE]
> 关键认知
>
> 三层是**独立配置、逐层生效**的。第 1 层决定"能不能捕获到"，第 2 层决定"走不走代理"，第 3 层决定"走哪个代理"。任何一层配错，流量就不会按预期走。

<a id="desktop"></a>

## 2. 桌面端（V2rayN macOS / Windows）

### 第 1 层：流量捕获方式

桌面端有**两种**捕获流量的方式，二选一：

| 方式 | 原理 | 捕获范围 | 适用场景 |
| --- | --- | --- | --- |
| **系统代理** | V2rayN 在本地监听 HTTP/SOCKS5 端口（默认 `10809` / `10808`），并告诉操作系统"所有 HTTP 流量走这个端口" | 仅 HTTP/HTTPS——只有遵守系统代理设置的程序才走代理（浏览器、部分 App） | 日常浏览、网页访问 |
| **Tun 模式** | V2rayN 创建一个虚拟网卡（TUN 设备），操作系统的**所有网络流量**都被路由到这个虚拟网卡 | 全部流量——TCP/UDP/ICMP 全捕获，包括不走系统代理的程序（终端命令行、游戏、SSH 等） | 需要全局代理、终端工具、游戏加速 |

```text
系统代理模式：

  浏览器 ──→ 读取系统代理设置 ──→ HTTP 127.0.0.1:10809 ──→ V2rayN ──→ 路由规则
  终端 curl ──→ 不走代理（除非手动设 HTTPS_PROXY）
  SSH ──→ 不走代理

Tun 模式：

  浏览器 ──→ 虚拟网卡 ──→ V2rayN ──→ 路由规则
  终端 curl ──→ 虚拟网卡 ──→ V2rayN ──→ 路由规则
  SSH ──→ 虚拟网卡 ──→ V2rayN ──→ 路由规则
  （所有流量无差别捕获）
```

### 系统代理 vs Tun 对比

| 维度 | 系统代理 | Tun 模式 |
| --- | --- | --- |
| 捕获范围 | 仅遵守系统代理的程序 | **全部程序** |
| 终端命令行 | 需手动设 `HTTPS_PROXY` | **自动走代理** |
| UDP 流量（游戏、DNS） | 不捕获 | **捕获** |
| 性能开销 | 低 | 略高（虚拟网卡转发） |
| 权限要求 | 无 | 需管理员/Root 权限 |
| Claude Code | 需 `export HTTPS_PROXY` | **自动走代理，无需配置** |

> [!WARNING]
> 两种方式不要同时开
>
> 系统代理和 Tun 模式同时开可能导致流量回环（流量被捕获两次）。V2rayN 通常会自动处理，但如果遇到网络异常，检查是否两个都开了。

### V2rayN 操作位置

| 操作 | macOS | Windows |
| --- | --- | --- |
| 开启/关闭系统代理 | 菜单栏图标 → 系统代理 → 自动配置 / 不改变 | 右下角托盘 → 系统代理 → 自动配置 / 不改变 |
| 开启/关闭 Tun 模式 | 菜单栏图标 → Tun 模式 → 开启/关闭 | 右下角托盘 → Tun 模式 → 开启/关闭 |
| 选择路由规则 | 底部状态栏 → 路由 → 绕过大陆 / 全局 / 黑名单 | 底部状态栏 → 路由 → 绕过大陆 / 全局 / 黑名单 |
| 查看本地端口 | 设置 → Core 基础设置 → 本地端口 | 设置 → 参数设置 → 本地端口 |

<a id="mobile"></a>

## 3. 移动端（V2rayNG Android）

### Android 上的核心区别

本文的 Android 配置以 **Android VPN API** 模式为准（类似桌面端的 Tun）。连接后系统通知栏会显示 VPN 钥匙图标；部分新版本另有 Proxy-only Mode，但不属于本章链式方案的验证基线。

> [!NOTE]
> 本文使用 VPN 模式
>
> 点击连接按钮后，由 Android VPN API 捕获所选应用的流量，不需要像桌面端那样配置系统 HTTP 代理。本章不依赖版本较新的 Proxy-only Mode。

### 三层过滤模型（Android）

```text
应用发出流量
    │
    ▼
┌──────────────────────────────────┐
│ 第 1 层：分应用路由               │  ← 决定哪些 APP 的流量进入 VPN 隧道
│ (分应用代理 / 分应用直连)         │     V2rayNG 独有功能
└──────────────────────────────────┘
    │ (进入隧道的流量)
    ▼
┌──────────────────────────────────┐
│ 第 2 层：路由规则                 │  ← 对进入隧道的流量按域名/IP 分流
│ (绕过大陆 / 全局 / 黑名单)        │     direct / proxy / block
└──────────────────────────────────┘
    │
    ▼
┌──────────────────────────────────┐
│ 第 3 层：出站代理节点             │  ← 需要代理的流量走哪个服务器
└──────────────────────────────────┘
```

### 分应用路由（第 1 层，Android 独有）

V2rayNG 允许你精确控制哪些 App 走 VPN、哪些不走。这是 Android VPN API 的能力，桌面端没有这个功能。

| 模式 | 说明 | 适用场景 |
| --- | --- | --- |
| **分应用代理**（白名单） | 只有勾选的 App 走 VPN，其他直连 | 只想代理浏览器和特定 App，国内 App 不受影响 |
| **分应用直连**（黑名单） | 勾选的 App 不走 VPN，其他全走 | 大部分流量需要代理，但个别 App（如银行、支付宝）必须直连 |
| **不配置**（默认） | 所有 App 的流量都进入 VPN | 配合路由规则"绕过大陆"使用 |

**操作位置**：V2rayNG → 左侧菜单 → 设置 → 分应用代理 → 勾选需要的 App

> [!NOTE]
> 分应用路由 vs 路由规则的关系
>
> 分应用路由是**第 1 层过滤**，在流量进入 VPN 之前就决定了去留。路由规则是**第 2 层过滤**，只对已经进入 VPN 的流量生效。两层可以叠加使用：
>
> - 分应用代理选了 Chrome → Chrome 的流量进入 VPN → 路由规则再按域名分流（国内直连、国外代理）
> - 微信没被选中 → 微信的流量**完全不经过 VPN**，路由规则对它无效

<a id="android-chain"></a>

## 4. Android 链式代理：香港前置 → Oregon SS AES-256-GCM

这个方案用于中国本地网络直连 Oregon 不稳定的场景。Oregon 服务端的 **VLESS + XHTTP + Reality / TCP 443** 仍是主入口；**Shadowsocks AES-256-GCM / TCP 18443** 只是经香港机场前置拨号的兼容性备用入口。服务端部署、备份和回滚见 [Oregon Shadowsocks 链式备用入口](proxy_server_guide.md#ss-chain)。

```text
中国本地网络
    │
    ▼
v2rayNG / Android VPN
    │
    │  先通过 香港机场 outbound 建立连接
    ▼
香港机场前置
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
> Xray 26.3.27 已提示 deprecated
>
> 18443 已使用 `aes-256-gcm` 完成服务端握手实测，但 Xray `26.3.27` 对 Shadowsocks 输出了弃用警告。传统 AEAD 也不具备 SS2022 的完整重放保护和主动探测缓解能力，因此它只能作为客户端兼容性备用，不能替代 443 Reality 主入口。

### v2rayNG 配置步骤

1. **先确认两个节点各自可用。**香港机场节点应能正常访问外网；Oregon SS 节点填写 `<OREGON_SERVER_IP>`、TCP `18443`、`aes-256-gcm` 和保存在密码管理器中的真实密码。若节点配置已遗失，在 Oregon 运行 `sudo /usr/local/sbin/generate-ss-chain-link` 可重新生成完整 `ss://` 导入链接。
2. **新建链式配置。**在已验证版本 v2rayNG `2.2.6` 中选择 **\+ → Add \[Proxy chain\]**，成员按实际路径依次加入“香港机场前置 → Oregon SS”。其他版本的菜单名称可能不同，但最终意图必须是：*Oregon Shadowsocks outbound 的拨号通过香港 outbound*。
3. **保存并选中新建的链式配置。**把这条 Proxy chain 设为当前配置；不要误选 Oregon 单节点，也不要把两个节点放入自动选择组后期待客户端自行形成链路。
4. **启动 Android VPN 并测试。**先访问普通网站，再访问 Claude / Anthropic；同时在 Oregon 观察 `ss-chain` 日志。

> [!NOTE]
> 订阅组的 previous proxy 是另一条配置路径
>
> 如果使用订阅组设置中的 `Previous proxy config remarks`，它是**组级设置**，并不等同于上面的独立 Proxy chain。被引用的香港节点 remarks 必须存在且唯一，修改后仍要检查生成配置中的 `dialerProxy`。不确定时优先使用上面已验证的 **Add \[Proxy chain\]** 流程。

> [!CAUTION]
> 不要分享完整订阅或生成配置
>
> 客户端配置可能包含 Shadowsocks 密码、机场订阅专属域名、节点别名、Reality 参数和真实服务器地址。排障时只截取下方所示的脱敏字段；不要粘贴完整 JSON、`ss://` / `vless://` 链接、二维码或订阅 URL。

### 检查生成配置中的 `dialerProxy`

在 v2rayNG 的“查看配置 / 导出运行配置 / 诊断”入口中定位 Oregon Shadowsocks outbound。菜单名称随版本变化，**不要手改临时生成的 JSON**；应回到 UI 调整前置节点，然后重新生成。下面只是保留链式关系的脱敏字段摘录，不是可直接运行的完整 outbound；不同客户端和核心版本的其他 `settings` 字段可能不同：

```json
{
  "tag": "<OREGON_SS_OUTBOUND_TAG>",
  "protocol": "shadowsocks",
  "streamSettings": {
    "sockopt": {
      "dialerProxy": "<HK_FRONT_OUTBOUND_TAG>"
    }
  }
}

{
  "tag": "<HK_FRONT_OUTBOUND_TAG>",
  "protocol": "<AIRPORT_NODE_PROTOCOL>"
}
```

- `dialerProxy` 必须非空，并且与实际存在的香港 outbound `tag` 完全一致；
- Oregon outbound 不能引用自己，香港 outbound 也不能反向依赖 Oregon，否则会形成循环；
- 不要同时用旧式 `proxySettings.tag` 表达同一链路；Xray 官方说明它与 `sockopt.dialerProxy` 不兼容；
- 节点别名和自动生成的 tag 会随版本变化，不要硬编码教程中的名字。

字段语义可对照 [Xray Sockopt 官方文档](https://xtls.github.io/en/config/transports/sockopt.md)：非空 `dialerProxy` 会使用指定 outbound 建立连接，并且与 `ProxySettingsObject.Tag` 不兼容。

### 验证：出口证据与链路证据分开看

| 观察结果 | 可以证明 | 不能单独证明 |
| --- | --- | --- |
| 普通 IP 检测页得到的公网 IP 与 `<OREGON_SERVER_IP>` 完全一致，或与独立确认的 Oregon `direct` NAT 出口一致 | 普通站点经这台 Oregon 的 `direct` 出站 | 不能证明客户端到 Oregon 经过了香港 |
| 检测页只显示“美国”或“Oregon”地区标签 | 只说明地理库把当前出口归到该地区 | 不能证明是这台 Oregon，更不能证明经过香港前置 |
| Claude / Anthropic 可访问并显示美国出口 | 目标域名可达；若命中规则，最终可能是 WARP 出口 | 不能据此反推香港前置或 Oregon 原生 IP |
| Oregon outbound 有 `dialerProxy = <HK_FRONT_OUTBOUND_TAG>` | 生成配置表达了正确的链式拨号计划 | 不能证明这次请求在运行时一定成功走过前置 |
| Oregon `ss-chain` 入站日志来源属于前置中转网络 | **香港前置实际生效的关键运行证据** | 来源 IP 的 GeoIP 标签不必等于“香港” |

如果本地可以直连 Oregon SS，推荐做同一时间窗口的 A/B 对照：关闭香港前置发起一次请求，再开启前置发起一次；记录 Oregon 日志的时间戳、入站 tag 和脱敏后的来源网络变化，同时保持最终 Oregon direct / WARP 出口逻辑不变。如果关闭前置后 Oregon SS 本来就无法直连，“没有日志”不能形成来源 IP 对照，此时应组合使用生成配置中的 `dialerProxy` 与开启前置后的 `ss-chain` 来源日志。服务端命令：

```bash
sudo tail -f /var/log/xray/access.log | grep 'ss-chain'

# 脱敏示例；真实来源 IP、端口和目标地址不得提交
<TIMESTAMP> from <HK_FRONT_EGRESS_IP>:<SOURCE_PORT> accepted ... [ss-chain -> direct]
<TIMESTAMP> from <HK_FRONT_EGRESS_IP>:<SOURCE_PORT> accepted ... [ss-chain -> warp]
```

> [!NOTE]
> 智能入口 / IEPL 不能只靠 GeoIP 猜路径
>
> 机场入口 DNS 解析到的地址、节点的物理位置、以及该节点连接 Oregon 时使用的出口 NAT IP 可能各不相同。Oregon 日志中的来源即使不被 IP 地理库标为香港，也不能据此否定链路；需要把 `dialerProxy` 配置、时间窗口和服务端来源日志组合起来判断。

### 加密边界

| 问题 | 结论 |
| --- | --- |
| 机场的长入口域名是不是“加密协议”？ | 不是。它只是寻址或调度标识，外层加密取决于机场节点实际协议。 |
| 香港前置能否读取 Oregon SS 流量？ | `aes-256-gcm` 内层负载本身已加密并认证；在密码和终端未失陷、实现正常的前提下，前置不能直接读取明文。 |
| 香港前置还能看到什么？ | 能看到 Oregon IP、TCP 18443、连接时间、包大小和流量特征；传统 SS AEAD 不提供这类元数据隐匿，也不能等同于 SS2022 的重放防护。 |

> [!TIP]
> 本方案已实际验证
>
> - Oregon SS AES-256-GCM / 18443 可连接；
> - 普通网站走 Oregon `direct`；
> - Claude / Anthropic 走服务端 WARP；
> - v2rayNG 加香港前置后，页面访问和美国出口正常；
> - Oregon 日志确认请求来自前置网络并进入 `ss-chain`。

<a id="routing"></a>

## 5. 路由规则详解（第 2 层）

路由规则只对**已进入代理管道**的流量生效（桌面端被系统代理/Tun 捕获的、Android 端进入 VPN 的）。它按域名和 IP 判断流量去向。

### 预定义规则

| 规则 | 逻辑 | 效果 | 适用场景 |
| --- | --- | --- | --- |
| **绕过大陆** | 匹配中国大陆域名/IP → 直连<br>其他 → 走代理 | 国内网站直连（快），海外网站走代理 | 日常推荐 兼顾速度和访问 |
| **全局代理** | 所有流量 → 走代理 | 无差别全部代理 | 需要完全隐匿 IP、注册敏感账号 |
| **黑名单**（GFWList） | 匹配被墙域名 → 走代理<br>其他 → 直连 | 只代理已知被墙的网站 | 节省流量，但可能漏掉新被墙的站 |

### 路由规则的三种出站

```text
                        ┌──→ direct（直连）     不经过代理，直接访问目标
                        │
进入管道的流量 ──→ 路由判断 ──┼──→ proxy（代理）     通过代理服务器转发
                        │
                        └──→ block（拦截）     丢弃，常用于屏蔽广告域名
```

### 自定义路由规则

除了预定义规则，还可以手动添加自定义规则。常见需求：

| 需求 | 操作 |
| --- | --- |
| 某个国内域名需要走代理 | 在代理规则中添加该域名 |
| 某个海外域名需要直连 | 在直连规则中添加该域名 |
| 屏蔽广告域名 | 在拦截规则中添加广告域名 |

**操作位置**：

- **V2rayN**：设置 → 路由设置 → 可编辑规则列表
- **V2rayNG**：左侧菜单 → 设置 → 预定义规则（选大类）；自定义路由规则（精细控制）

> [!WARNING]
> 路由规则 vs 服务端分流的关系
>
> 客户端路由规则和服务端 Xray 分流路由是**两级分流**，不冲突：
>
> - **客户端路由**（V2rayN/NG）：决定流量是直连还是发给代理服务器
> - **服务端路由**（Lightsail 上的 Xray config）：决定收到的流量从哪个出口出去（直连 / WARP / 住宅 IP）
>
> 例如访问 claude.ai：客户端路由判断"不是大陆域名" → 发给代理服务器 → 服务端路由匹配 ai-services 规则 → 从 WARP 出口出去。

<a id="terminal"></a>

## 6. 终端程序的代理配置

终端命令行程序（curl、git、npm、Claude Code 等）是否走代理，取决于第 1 层的捕获方式：

| 捕获方式 | 终端是否自动走代理 | 需要额外配置吗 |
| --- | --- | --- |
| **Tun 模式** | 自动走 | 不需要，Tun 捕获所有流量 |
| **系统代理** | 不走 | 需手动设置环境变量 |
| **VPN（Android）** | 自动走 | 不需要（Termux 等终端也走 VPN） |

### 系统代理模式下的终端配置

如果不开 Tun，需要手动告诉终端程序代理地址：

```bash
# 临时生效（当前终端会话）
export HTTPS_PROXY="http://127.0.0.1:10809"
export HTTP_PROXY="http://127.0.0.1:10809"

# 或写入 ~/.zshrc 做成开关
proxy_on() {
  export HTTPS_PROXY="http://127.0.0.1:10809"
  export HTTP_PROXY="http://127.0.0.1:10809"
}
proxy_off() {
  unset HTTPS_PROXY HTTP_PROXY
}
```

> [!WARNING]
> ping 不走代理
>
> `ping` 使用的是 **ICMP 协议**，不是 HTTP/HTTPS。环境变量 `http_proxy` / `https_proxy` 只对 HTTP 协议生效（curl、wget、npm、git 等），**ping 永远不走代理**，即使设了环境变量也无效。
>
> 测试代理是否生效应该用 `curl`，不要用 `ping`：
>
> ```bash
> curl -I https://www.google.com   # 返回 HTTP 200 = 代理正常
> ping google.com                  # 即使代理正常也会超时，不代表代理有问题
> ```
>
> 想让 ping 也走代理，必须开 **Tun 模式**——Tun 在网络层捕获所有协议（TCP/UDP/ICMP），系统代理模式做不到。

> [!NOTE]
> Claude Code 用哪种
>
> 两种都行：
>
> - **Tun 模式**：开了就完事，Claude Code 自动走代理，零配置
> - **系统代理 + HTTPS\_PROXY**：更精细控制，可以只让 Claude Code 走代理，其他终端工具直连

<a id="scenarios"></a>

## 7. 常见场景配置推荐

### 桌面端（V2rayN）

| 场景 | 第 1 层 | 第 2 层 | 说明 |
| --- | --- | --- | --- |
| **日常浏览 + Claude Code** | Tun 模式 | 绕过大陆 | 最省心，所有流量自动分流，终端不用额外配置 |
| **日常浏览，终端单独控制** | 系统代理 | 绕过大陆 | 浏览器自动走代理；终端用 `HTTPS_PROXY` 按需开关 |
| **注册敏感账号（Claude、PayPal）** | Tun 模式 | 全局代理 | 确保所有流量（包括 DNS）都走代理，防泄露真实 IP |
| **打游戏需要低延迟** | Tun 模式 | 绕过大陆 | 国服直连、外服走代理，Tun 模式能捕获 UDP（游戏常用） |
| **与公司 VPN 共存** | 系统代理 | 绕过大陆 | 避免 Tun 和公司 VPN 抢虚拟网卡冲突 |

### 移动端（V2rayNG Android）

| 场景 | 分应用路由 | 路由规则 | 说明 |
| --- | --- | --- | --- |
| **日常使用** | 不配置（全部进 VPN） | 绕过大陆 | 国内 App 直连、海外 App 走代理，最常用 |
| **本地直连 Oregon 不稳定** | 按需（通常不配置） | 绕过大陆 | 香港机场前置 + Oregon SS AES-256-GCM；只作为备用，配置与证据见第 4 章 |
| **只代理浏览器** | 分应用代理 → 只选 Chrome | 全局代理 | 其他 App 完全不受影响 |
| **银行/支付 App 必须直连** | 分应用直连 → 选银行 App | 绕过大陆 | 银行 App 不走 VPN（防风控），其他正常分流 |
| **TikTok 注册** | 分应用代理 → 只选 TikTok | 全局代理 | TikTok 全流量走代理，其他 App 直连 |

### 完整流量路径示例

以"桌面端 Tun 模式 + 绕过大陆 + 服务端 WARP 分流"为例，访问 claude.ai 的完整路径：

```text
Claude Code 发出 HTTPS 请求到 api.anthropic.com
    │
    ▼
Tun 虚拟网卡 捕获流量                    ← 第 1 层：流量捕获
    │
    ▼
V2rayN 路由引擎                          ← 第 2 层：路由规则
    判断 api.anthropic.com → 不在大陆列表 → 走代理
    │
    ▼
VLESS-XHTTP-Reality 加密传输              ← 第 3 层：出站节点
    到 Lightsail 服务器 (Oregon)
    │
    ▼
Lightsail Xray 服务端路由                ← 服务端分流（独立于客户端）
    匹配 ai-services 规则 → 走 WARP 出站
    │
    ▼
Cloudflare WARP (AS 13335)
    │
    ▼
api.anthropic.com                        ← 目标服务器看到的是 Cloudflare IP
```

整理于 2026 年 6 月 · 仅供个人学习与技术参考

Oregon 服务端的 Reality、SS AES-256-GCM、WARP 与回滚步骤见 [代理服务器搭建与运维指南](proxy_server_guide.md#ss-chain)。
