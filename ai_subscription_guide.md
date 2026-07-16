# 海外 AI 服务订阅全指南

支付渠道、低价订阅与终端配置，一站式解决 Claude / Codex 等海外 AI 服务的付费与使用

**标签：** AWS Lightsail · Xray VLESS-XHTTP-Reality · Cloudflare WARP · Timon 钱包 · 尼区低价订阅 · eSIM 工具卡

## 目录

0. [★ 快速上手：从零到 Claude Code 可用](#quickstart)
1. [▶ 代理服务器搭建与运维（独立文档）](proxy_server_guide.md)
2. [Claude 付费订阅方案](#subscribe)
3. [Timon 钱包详解](#timon)
4. [▶ eSIM 工具卡写号教程（独立文档）](esim_write_guide.md)
5. [Claude Code 终端代理配置](#claude-code-config)

<a id="quickstart"></a>

## ★ 快速上手：从零到 Claude Code 可用

以下是按时间顺序整理的完整执行清单。每步标注了预计耗时和详细说明的跳转链接，方便快速定位。

### 全链路执行清单

| 步骤 | 操作 | 耗时 | 前置条件 | 详细 |
| --- | --- | --- | --- | --- |
| **1** | **闲鱼联系商家，先开 MTN eSIM**<br>跟商家说明分两步：**先开通 MTN 号 + eSIM，Timon 注册稍后进行**。确认收到：MTN 手机号、eSIM 二维码。 | 1-2 天 | 无 | [第 7 章](#timon) |
| **2** | **eSTK 白卡写卡 + 保号**<br>淘宝买 eSTK 白卡（~¥24）+ USB-C 读卡器（~¥25）→ 电脑安装 MiniLPA/EasyLPAC → 读卡器写入 MTN 号 → 插入手机验证能收短信 → MyMTN App 开通保号。<br>*（eSTK + 读卡器可在等商家出 eSIM 期间先下单，同步到货节省时间）* | 1-3 天（等快递） | 步骤 1 | [eSIM 写号教程](esim_write_guide.md) |
| **3** | **注册 Gmail**<br>用国内手机号注册全新 Gmail 即可。Google 账号本身没有区域锁定，区域由首次登录 Google Play 时的 IP 和付款方式决定。 | 5 分钟 | 无 | [第 6 章](#subscribe) |
| **4** | **商家注册 Timon + 入金 + 开卡**<br>把步骤 3 的 Gmail 给商家 → 商家注册 Timon → 你登录后改密码、开 2FA → OKX 买 USDT（专用小额银行卡）→ 链上转到 Timon → 兑换 USD → 开 Visa/Mastercard（$5）→ 充值到卡。 | 1-2 小时 | 步骤 3 | [第 7 章](#timon) |
| **5** | **注册 AWS + 创建 Lightsail 实例**<br>AWS 注册（**用国内信用卡**，不用 Timon 卡）→ 创建 Oregon 区 $5 实例 → 分配静态 IP → 配置防火墙。 | 30 分钟 | 国内信用卡 | [代理指南第 2 章](proxy_server_guide.md#lightsail) |
| **6** | **搭建 Xray + WARP**<br>SSH 登录 Lightsail → Xray-script 一键安装 XHTTP Reality → 安装 WARP → jq 添加分流路由。 | 30 分钟 | 步骤 5 | [代理指南第 3-5 章](proxy_server_guide.md#xray) |
| **7** | **安装客户端 + 扫码添加节点**<br>Mac 安装 V2rayN / 手机安装 V2rayNG → SSH 连服务器运行管理菜单 → 终端显示二维码 → 扫码导入节点 → 终端配置 `HTTPS_PROXY`。 | 15 分钟 | 步骤 6 | [代理指南第 6 章](proxy_server_guide.md#client) |
| **8** | **订阅 Claude Pro**<br>美区 Google Play + 国内双币信用卡内购订阅（$19.99/月），或网页端 claude.ai 用 Timon 卡订阅。<br>*尼区 Google Play 无低价优惠且付款风控严格（IP 地区不一致会拦截），不推荐。想要低价需走尼区 App Store（需 iPhone/iPad）。* | 15 分钟 | 步骤 4 + 步骤 6 | [第 6 章](#subscribe) |
| **9** | **登录 Claude Code**<br>终端运行 `claude` → OAuth 登录（浏览器弹出 claude.ai 授权页面）→ 授权完成 → 开始使用。 | 2 分钟 | 步骤 7 + 步骤 8 | [第 11 章](#claude-code-config) |

> [!NOTE]
> 总耗时预估
>
> 排除等快递（eSTK 卡 + 读卡器 + Timon 商家处理）的时间，**实际动手操作约 4-5 小时**。建议分两天完成：第一天搞定步骤 1-4（支付侧），第二天搞定步骤 5-9（代理侧）。

### 风险清单与缓解措施

| 风险 | 等级 | 缓解措施 |
| --- | --- | --- |
| Timon 账号安全 | 低 | 已用自己邮箱注册，改密码 + 开 2FA + 踢多余设备 |
| USDT 买入冻卡 | 中 | 用专用小额银行卡，只选 OKX 认证商家，单次 ¥500 以内 |
| Claude 封号 | 中 | Timon 卡不存大额（够 1-2 月）；封号后退款→注销旧卡→开新卡→新账号 |
| Google Play 尼区可行性 | 未验证 | 先尝试；不行则走 Apple（需 iPad）或网页端 claude.ai 直接订阅 |
| Lightsail IP 被墙 | 低 | 重新分配静态 IP（免费），做好快照备份 |
| MTN 号码回收 | 极低 | 已开 1 年保号（¥16），到期前续费即可，eSIM 二维码多处备份 |
| Claude Code 指纹泄露 | 中 | TZ/LANG 伪装 + 关闭遥测 + 始终走代理 |

### 月度成本汇总

| 项目 | 月费 | 备注 |
| --- | --- | --- |
| AWS Lightsail | $5 | 前 3 个月免费（$5 plan） |
| Cloudflare WARP | $0 | 免费 |
| Claude Pro 订阅（尼区） | ~¥88 | 约 $12；美区价 $20 |
| MTN 保号 | ~¥1.3 | ¥16 / 12 个月，可忽略 |
| 住宅 IP（可选） | $3-5 | WARP 被风控时才需要 |
| **基础方案总计** | **~¥124/月** | Lightsail $5 + Claude ¥88 |
| **含住宅 IP 方案** | **~¥150/月** | \+ 住宅 IP $3-5 |

\* 一次性费用：Timon 账号 ¥100-200 + eSTK+读卡器 ¥49 + Timon 开卡 $5 ≈ ¥200-300

### 初始投入清单（一次性）

| 项目 | 费用 |
| --- | --- |
| 闲鱼 Timon 账号注册服务 | ¥100-200 |
| eSTK 白卡 + USB-C 读卡器 | ~¥49 |
| Timon Visa/Mastercard 开卡费 | $5（约 ¥36） |
| MTN 1 年保号（MyMTN App） | ¥16 |
| **合计** | **¥200-300** |

## 代理服务器搭建

代理服务器的搭建、配置与运维（AWS Lightsail + Xray + WARP + 住宅 IP + 安全加固）已拆为独立文档：

**[→ 代理服务器搭建与运维指南](proxy_server_guide.md)**

包含：整体架构 · Lightsail 购买与优化 · Xray XHTTP Reality 一键搭建 · WARP 出口 · 分流路由 · 客户端配置 · 住宅 IP 方案 · 安全与 geodata 更新踩坑修复

<a id="subscribe"></a>

## 1. Claude 付费订阅方案

核心思路：利用尼日利亚区应用商店的**区域低价**（Claude Pro 约 ¥88/月 vs 美区 ¥145/月），通过 Timon 钱包的 Visa 卡支付，应用商店代扣降低风控风险。

> [!TIP]
> Google Play 内购 Claude 已验证可行
>
> 多位国内用户实测：Claude Android App 支持 Google Play 内购订阅 Pro/Max。API 端点 `claude.ai/api/google-play-iap/purchase` 已确认存在。订阅后 Claude Code 直接可用（共享同一订阅额度，不需额外付费）。

尼区 App Store + Timon 卡（低价首选）（推荐）

通过尼区 Apple ID + Timon Visa 卡，在 Claude iOS App 内购订阅。**唯一有低价优惠的渠道。**

| 项目 | 说明 |
| --- | --- |
| 前置条件 | iPhone/iPad + 尼区 Apple ID + Timon 卡 |
| 价格 | **约 ¥88/月（Pro）**，已大量验证 |
| 开卡费 | $5（Timon Ace 卡） |

**操作路径：**

1. 创建尼区 Apple ID（或切换现有 Apple ID 到尼区：设置 → 媒体与购买 → 国家/地区 → Nigeria）
2. 付款方式添加 Timon Visa/Mastercard
3. App Store 搜索 Claude → 下载 App
4. 打开 Claude App → 登录 → Upgrade → 选 Pro → App Store 弹出支付确认 → 完成

**创建尼区 Apple ID 注意事项：**

- **不需要挂代理**，国内网络直连即可在 `account.apple.com` 创建
- **国内手机号和国内邮箱（如 163）都可以用**，创建时国家/地区选 Nigeria 即可
- 同一手机号关联 Apple ID 数量有上限（约 2 个），超出会提示「此时无法创建你的账户」
- 遇到无法创建的提示，联系 [Apple 在线客服](https://support.apple.com/contact)（选 Apple ID → 创建 → 在线聊天），客服可协助解除限制

**注意：**首次大额支付可能被拦截，需拨打 Apple 客服说明情况，等待约三天后再试。Apple ID 区域随时可改，灵活度高于 Google Play。

美区 Google Play + 国内双币卡（无苹果设备时）

用美区 Google 账号 + **国内 Visa/Mastercard 双币信用卡**直接绑定 Google Play 内购。已被多人实测成功。

| 项目 | 说明 |
| --- | --- |
| 前置条件 | 安卓手机 + 美区 Google 账号 + 国内 Visa/Mastercard 信用卡 |
| 价格 | $19.99/月（美区原价，约 ¥145） |
| 额外费用 | 无开卡费，直接用已有的国内双币卡 |

**操作要点：**

- Google Play 绑卡时地址填美国免税州地址（Oregon / Delaware）
- 登录 Google Play 时需挂美国 IP，付款方式地区和 IP 必须一致
- 仅支持 Visa / Mastercard，银联标识的卡不行

**优势：**不需要 Timon 卡，不需要 USDT 入金，流程最简单。<br>
**劣势：**没有低价优势，按美区原价 $19.99/月。

美区 App Store 礼品卡（最简单后备方案）

美区 Apple ID + 美区礼品卡，在 Claude iOS App 内购订阅。**不需要虚拟信用卡，不需要 PayPal。**

- 淘宝搜"美区 App Store 礼品卡"，买 $20 面额
- 美区 Apple ID 兑换礼品卡余额
- Claude App 内购订阅 Pro（$19.99/月，美区原价）

**优势**：零门槛，几分钟搞定，不需要折腾虚拟卡。<br>
**劣势**：美区原价 $19.99，没有尼区低价优势；余额用不完无法提现。

美区 PayPal + 国内全币种卡（网页/App Store 通用）

注册美区 PayPal（需美国电话号），绑定国内 Visa/Mastercard 全币种卡。可用于美区 Apple ID 付款方式，也可直接在 claude.ai 网页端订阅。

| 项目 | 说明 |
| --- | --- |
| 前置条件 | 美国电话卡（Red Pocket / Tello）+ 国内全币种 Visa/Mastercard |
| 价格 | $19.99/月（美区原价） |
| 优势 | 一个 PayPal 通吃所有美区支付场景，长期复用 |

虚拟信用卡（网页端订阅）

在 claude.ai 网页端用美国 BIN 虚拟卡直接订阅（Stripe 支付）。

| 项目 | 说明 |
| --- | --- |
| **BinGoCard** | $20/5年，美国 BIN，支持支付宝/云闪付，仍在运营（2026.06） |
| ~WildCard~ | 已停服（2026 年 3 月） |
| ~Dupay~ | 已跑路 |
| Wise | 护照认证，银行级 BIN 信誉好，大陆可能被拒 |

虚拟卡行业跑路率极高，随用随充，卡上不留余额。

> [!CAUTION]
> 实测结论：尼区 Google Play 不推荐
>
> 尼区 Google Play 存在两个问题：**1）Claude 定价无低价优惠**（NGN 33,500/月 ≈ $21，和美区同价）；**2）付款风控严格**——当 Timon 卡地址为尼日利亚但代理 IP 为日本/美国时，Google Play 会警告地区不一致并拦截付款。不推荐走这条路径。

### Google Play vs App Store 订阅对比

| 维度 | Google Play | App Store |
| --- | --- | --- |
| 需要的设备 | 安卓手机（小米即可） | iPhone / iPad |
| 国内双币卡直绑 | 支持（美区/新加坡区实测可行） | 不支持（需礼品卡或 Timon 卡） |
| 尼区低价 | 无优惠（实测 NGN 33,500/月 ≈ $21，和美区同价） | 已验证（Pro ~¥88/月） |
| 平台抽成 | 15-30% | 30% |
| 验证成熟度 | 中（有成功案例但尼区较少） | 高（大量成功案例） |

> [!CAUTION]
> 实测结论：Google Play 尼区 Claude 没有低价优惠
>
> 2026 年 6 月实测，尼区 Google Play Claude 定价如下，和美区基本持平，**不存在区域低价**：
>
> | 计划 | 尼区 Google Play | 美区 Google Play | 尼区 App Store |
> | --- | --- | --- | --- |
> | Pro（月付） | NGN 33,500（≈$21） | $19.99 | ~¥88（≈$12） |
> | Pro（年付） | NGN 361,800（≈$226，省10%） | — | — |
> | Max 5x（月付） | NGN 209,375（≈$131） | $99.99 | — |
> | Max 20x（月付） | NGN 418,750（≈$262） | $199.99 | — |
>
> **结论：想要尼区低价必须走 Apple App Store，Google Play 尼区没有价格优势。**如果没有 iPhone/iPad，直接用美区 Google Play + 国内双币卡订阅是最简单的方案（$19.99/月）。

> [!TIP]
> 重要概念：低价订阅是「渠道」决定的，不是 Claude 账号决定的
>
> Claude 账号本身**没有区域概念**。Claude 不知道也不关心你付了多少钱——它只知道你订阅了 Pro。价格差异完全由**应用商店的区域**决定：
>
> - 尼区 App Store → 尼区低价（Pro ~¥88/月）
> - 尼区 Google Play → **无优惠**（Pro NGN 33,500 ≈ $21，和美区同价）
> - 美区 Google Play / App Store → 美区价格（$19.99/月）
> - claude.ai 网页端 → 统一 $19.99/月
>
> 所以「注册 Claude 账号」和「订阅付费」是两件独立的事。你可以用日本 IP 注册 Claude 账号，然后通过尼区 Google Play 内购订阅 Pro，完全没有冲突。

### Google Play 区域锁定机制

Google Play 的区域设定规则比较严格，操作前务必了解：

| 规则 | 说明 |
| --- | --- |
| 区域何时锁定 | **首次登录 Google Play 时**，根据当前 IP + 付款方式地址确定区域 |
| 能否修改 | 可以，但**一年只能改一次** |
| 修改条件 | 需要添加对应区域的付款方式（卡或银行账户），且商店余额/礼品卡需清零 |
| IP 要求 | 首次登录和切换区域时需要对应地区的 IP，日常使用不强制 |

> [!CAUTION]
> 操作顺序很重要
>
> 如果你计划走尼区低价：**在 Timon 卡到手之前，不要用该 Google 账号登录 Google Play**。一旦用美国/日本 IP 首次登录，区域就被锁定，改回尼区要等一年。
>
> 正确顺序：拿到 Timon 卡 → 挂对应 IP → 首次登录 Google Play → 添加 Timon 卡（地址填尼日利亚）→ 区域锁定尼区。

> [!NOTE]
> 建议：新卡绑定后先做几笔小额消费再订阅
>
> Google Play 绑定新卡后直接订阅 $19.99 的服务可能触发风控。建议先买一两个小额付费 App（$1-3），等扣款成功后过两三天再订阅 Claude，降低被拦截的概率。

### Apple ID 区域 vs Google Play 区域

| 维度 | Google Play | Apple ID |
| --- | --- | --- |
| 区域锁定 | 首次登录时锁定，一年只能改一次 | **随时可改**（设置 → 媒体与购买 → 国家/地区） |
| 切换条件 | 需要对应区域的付款方式 | 需要对应区域的付款方式，且余额清零 |
| 设备要求 | 安卓手机 | iPhone / iPad |
| 灵活度 | 低 | 高 |

如果你同时有安卓和 iOS 设备，建议把 Google Play 账号留给更确定的区域（或暂不登录），用 Apple ID 灵活切换区域来订阅。

### 核心优势：为什么用 Timon 卡而不是礼品卡

| 维度 | Timon Visa 卡 | 尼区礼品卡 |
| --- | --- | --- |
| 封号资金回收 | 退回 Visa 卡，钱能拿回来 | 余额锁在被封账户，无法取回 |
| 重开成本 | 注销旧卡 → 新开一张 $5 | 需重新购买礼品卡 |
| 连坐风险 | 换新卡 + 新账号，完全隔离 | 同一批礼品卡可能被关联 |
| 操作复杂度 | 中（需 eSIM + Timon） | 低（买卡兑换即可） |

> [!NOTE]
> 封号后的恢复策略
>
> #### 第一步：止损（立即操作）
>
> 1. **取消自动续费**：iPhone 设置 → Apple ID → 订阅 → 找到 Claude → 取消续订，防止下个计费周期继续扣款
> 2. **申请退款**（退款渠道取决于你的订阅方式，详见下方退款指南）
> 3. **Timon 卡余额转出**：卡上不留大额资金。被封账号关联的卡信息可能被标记，后续该卡再订阅有连坐风险
>
> #### 第二步：等待申诉 / 并行准备新账号
>
> Claude 封号申诉通常回复较慢（官方提示 7 个工作日，实际可能更久）。建议**不要干等**，和申诉并行准备新账号：
>
> 1. 确认退款已到账
> 2. 在 Timon 中**注销被封的 Visa 卡**
> 3. 重新开一张**新 Visa 卡**（$5 开卡费）
> 4. 注册**新 Gmail**
> 5. 新尼区 Apple ID（或切换现有 Apple ID 区域）→ 绑定新 Timon 卡
> 6. 注册**新 Claude 账号**（新邮箱）→ 重新订阅
>
> 关键隔离点：**新卡号 + 新邮箱 + 新 Claude 账号**，和被封的旧账号没有任何关联。申诉成功是 bonus，不成功也不耽误使用。

> [!WARNING]
> Claude 订阅退款详细指南
>
> 退款渠道取决于你的订阅方式。Anthropic 官方政策：**除服务条款明确规定或法律要求外，所有付款不可退款**。但不同渠道有各自的退款路径：
>
> #### 通过 App Store（iOS）订阅
>
> Anthropic 官方说明：订阅从 Apple App Store 启动的，付款由 Apple 处理，Anthropic 无法退款，需联系 **Apple Support** 申请退款。
>
> 以下为 Apple 通用退款操作 + 社区实测经验（非 Anthropic 官方指引）：
>
> 1. 访问 `reportaproblem.apple.com`，登录订阅时的 Apple ID
> 2. 选择「**I'd like to**」→「**Request a refund**」
> 3. 退款理由选「**其他 / Other**」或「**The app doesn't work as expected**」
> 4. 找到 Claude 订阅的扣款记录，点击选中
> 5. 补充说明（建议英文），写清封号时间和未使用的订阅期限，参考模板：<br>
>     `On [封号日期], Anthropic suspended my account without explanation, even though my subscription doesn't expire until [到期日期]. I'm requesting a refund for the unused portion of my subscription.`
> 6. 提交后等待 Apple 审核，退款通常 **3-5 个工作日**到原付款方式（Timon 卡）
>
> **社区经验总结：**
>
> - 首次退款大概率成功，多次退款成功率递减（有用户反馈第二次被 Apple 拒绝）
> - 申请退款必须在购买后 **90 天内**
> - 非美区（尼区、土区等）App Store 也支持退款申请，流程相同
> - 不要把退款当作"免费试用"的后路——Apple 会记录退款历史，频繁退款会影响账号信誉
>
> 信源：[CSDN — Claude 账号被封后申请退款](https://blog.csdn.net/qq_32483009/article/details/157440954) · [CSDN — Claude 被封退款申诉重开全流程](https://blog.csdn.net/lulu1216544078/article/details/159489883)
>
> #### 退款已批准但 Timon 卡未到账
>
> Apple 在 `reportaproblem.apple.com` 显示 **"Refunded"** 后,Timon 卡上迟迟没有入账——这是**正常现象**,不需要重新提交申请。
>
> **"Refunded" 只代表 Apple 侧已处理完毕**,资金实际需要经过以下链路才能到达你的卡:
>
> | 步骤 | 环节 | 耗时 |
> | --- | --- | --- |
> | 1 | Apple 标记退款完成,通知你 | 即时 |
> | 2 | Apple 的收单银行发出退款指令 | 1-2 个工作日 |
> | 3 | Visa / Mastercard 国际清算网络中转 | 2-4 个工作日 |
> | 4 | Timon 发卡行（尼日利亚）接收并入账 | 1-3 个工作日 |
> | **全程总计** |  | **5-10 个工作日**（排除周末和公共假日） |
>
> 尼日利亚预付卡（Timon）比美国本土银行卡慢 3-5 天是常态,因为多了一层国际清算中转。
>
> **不需要做的事:**
>
> - **不要重新提交退款申请**——系统会提示"已处理"或"重复请求"
> - **不要在 10 个工作日之前联系客服**——这段等待是正常流程,客服也只会让你继续等
>
> **排查清单（等待期间可自行检查）:**
>
> - 打开 Timon App → Transactions,看有没有一笔 `APPLE.COM/BILL` 或 `APL*APPLE` 的正数金额（可能显示为 pending）
> - 确认 Timon 卡状态为 Active（未冻结/未注销）——如果退款发出时卡已注销,资金会被退回 Apple
> - 检查 Apple ID 余额（设置 → Apple ID → 媒体与购买 → 查看余额）——极少数情况退款会退到 Apple ID 余额而非原卡
> - 确认退款金额——按比例退款可能只有 $2-5,金额很小容易忽略
>
> **超过 10 个工作日仍未到账的升级操作:**
>
> 1. 联系 Apple 在线客服（`reportaproblem.apple.com` → 选择那笔退款 → "I haven't received my refund"）
> 2. 要求 Apple 提供退款的 **ARN（Acquirer Reference Number）**
> 3. 拿 ARN 联系 Timon 客服,让他们在 Visa 网络中追踪这笔资金具体停在哪一环
> 4. 如果 Timon 确认未收到,提供 ARN 让 Apple 重新发起退款或换其他退款方式
>
> \* 实测参考：2026 年 6 月尼区 App Store Claude Pro 退款,Apple 6 月 25 日标记 "Refunded",Timon 卡预计 7 月 1-7 日之间到账。
>
> #### 通过 Google Play（Android）订阅
>
> - **活跃订阅**：可联系 Anthropic 客服检查退款资格，客服确认后处理
> - **已取消的历史订阅**：Anthropic 无法退款，需联系 [Google 支持](https://support.google.com/googleplay/answer/2479637)
>
> #### 通过 claude.ai 网页端订阅
>
> 1. 登录 claude.ai → 左下角点击你的名字/头像
> 2. 选择 **Get help** → 打开右侧聊天窗口
> 3. 点击 **Send us a message** → **Accept** → **Claude Refund Request**
> 4. 选择退款原因 → 系统检查退款资格 → 符合条件则在线完成退款
>
> #### 无法登录被封账号怎么办
>
> 用另一个邮箱联系 [Anthropic 客服](https://support.anthropic.com)，并抄送（CC）被封账号的注册邮箱，说明需要取消订阅并退款。
>
> #### 特殊情况
>
> | 情况 | 退款可行性 |
> | --- | --- |
> | 欧盟/英国用户 | 购买后 14 天内可退款（按使用量比例扣除），在 Settings 页面可操作 |
> | 银行争议（Dispute）中 | Anthropic 无法处理退款，需等争议结束或撤回银行争议后由 Anthropic 退款 |
> | 迁移到 Team/Enterprise | 个人 Pro/Max 订阅自动取消，按比例退款 |
>
> 信源：[Claude Help Center — Requesting a refund for a paid Claude plan](https://support.claude.com/en/articles/12386328-requesting-a-refund-for-a-paid-claude-plan)

### 价格参考

| 计划 | 美区 App Store | 尼区 App Store | 美区 Google Play | 尼区 Google Play |
| --- | --- | --- | --- | --- |
| Pro | ¥145/月 | ¥88/月 | ¥145/月 | ≈¥150/月（无优惠） |
| Max 5 | ¥725/月 | ¥580/月 | ¥725/月 | ≈¥940/月（无优惠） |
| Max 20 | ¥1450/月 | ¥1160/月 | ¥1450/月 | ≈¥1880/月（无优惠） |

\* 尼区 App Store 价格受奈拉汇率波动影响，每日小幅变动，大方向稳定。

\* **尼区 Google Play 实测无低价优惠**（2026 年 6 月验证），Pro 定价 NGN 33,500/月 ≈ $21，和美区基本持平。想要低价必须走尼区 App Store。

\* Claude Code 不需要单独付费，订阅 Pro/Max 后终端运行 `claude` 登录同一账号即可使用，和网页端共享订阅额度。

\* 全球各区 App Store 实时价格查询工具：[AppStorePrice（Claude 各区定价）](https://appstoreprice.org/zh/apps/6448311069) · [VBR.me（全球 App Store 价格对比）](https://app.vbr.me/)

<a id="timon"></a>

## 2. Timon 钱包详解

### 基本信息

Timon（usetimon.com）是尼日利亚的电子钱包，受尼日利亚央行 (CBN) 监管。相比同类产品 gomoney，Timon 限额更高（2500 USD）且支持 USDT 入金。

### 可开卡类型

| 卡名 | 类型 | 货币 | 费用 | 限额 | 用途 |
| --- | --- | --- | --- | --- | --- |
| Blue Debit | 实体卡 (Afrigo) | NGN | 免费 | ₦10M/月 | 尼日利亚本地 POS，不支持线上支付 |
| Blue Prepaid | 实体卡 (Visa) | USD | — | $20,000/月 | 全球旅行线下消费 |
| **Blue Prepaid** | **虚拟卡 (Visa)** | **USD** | — | **$10,000/季，$2,500/笔** | **线上订阅、Google Play Store** |
| **Black Debit** | **虚拟卡 (Mastercard)** | **USD** | **$5/年** | **$25,000/月，$10,000/笔** | **全球网站支付、Apple Pay、Google Pay** |
| Blue Debit | 虚拟卡 (Verve) | NGN | 免费 | ₦10,000/月 | 尼日利亚本地网站 |

> [!NOTE]
> 推荐开哪张卡
>
> **Black Debit 虚拟美元卡 (Mastercard)**：$5/年，限额最高，支持 Apple Pay 和 Google Pay，BIN 前缀 `4173 9601`（文中提到的 Ace 卡即此类型）。一张卡可同时用于 Claude 订阅 + AWS Lightsail 支付。

### 入金方式

#### 推荐：USDT 入金（最适合国内用户）

Timon 官方支持稳定币兑换（stablecoin conversion），可直接用 USDT 充值。

```text
支付宝 / 银行卡
    │  C2C 交易（欧易 OKX / 币安）
    ▼
购入 USDT
    │  链上提币，选 TRC20（手续费最低 ~1 USDT）
    ▼
Timon 钱包 USDT 地址
    │  App 内兑换
    ▼
Timon USD 钱包余额
    │  手动 Top up
    ▼
Timon Visa / Mastercard 卡  → 可消费
```

> [!WARNING]
> 入金注意事项
>
> - **先小额测试**：第一次转 5-10 USDT 验证链路通畅，再转大额
> - **选 TRC20 链**：手续费最低（约 1 USDT），到账几分钟
> - **汇率损耗**：整个链路约 2-3%（C2C 买入溢价 + 链上手续费 + Timon 内部兑换汇差）
> - 欧易注册需实名认证（身份证即可），C2C 买 USDT 支持支付宝/微信/银行卡

### 办理步骤

1. **闲鱼购买 Timon 账号**（约 ¥100-200）：商家提供 Timon 账号密码、Gmail 邮箱、尼日利亚 MTN 手机号、eSIM 二维码、密码锁
2. **写入 eSIM**：用 eSTK 白卡 + 读卡器将尼日利亚号码写入实体卡（详见下节）
3. **登录 Timon**：使用邮箱登录，短信验证码用 eSTK 白卡接收
4. **安全加固**：踢出 Gmail 和 Timon 的多余设备登录，开启 2FA，防止商家找回
5. **入金**：通过 USDT 向钱包充值
6. **开卡**：选择 Timon Ace Visa 卡，开卡费 $5
7. **绑定 App Store**：尼区 Apple ID 添加 Timon Ace Visa 卡为支付方式
8. **订阅 Claude**：Claude App 内购

## 3. eSIM 工具卡写号

eSIM 白卡选购、写卡工具、eSTK 写号步骤、MTN 保号等内容已拆为独立文档：

**[→ eSIM 工具卡写号教程](esim_write_guide.md)**

包含：为什么需要工具卡 · eSTK / 9eSIM 白卡对比 · 读卡器 vs App 直写 · 写号步骤图解 · 多号码管理 · MTN 保号（MyMTN App ₦3,500/年）· 设备分工建议

<a id="claude-code-config"></a>

## 4. Claude Code 终端代理配置

代理搭建、客户端连通、Claude 订阅全部完成后，最后一步是让终端的 Claude Code CLI 走代理。Claude Code 支持标准的 `HTTPS_PROXY` 环境变量。

本节给一套已经在本机实测可用的脚本 `~/.claude-env.sh`，把**代理配置**、**时区/Locale 伪装**、**跨境连通性自检**合三为一，封装成三个命令：

| 命令 | 作用 |
| --- | --- |
| `claude-env` | 激活美西环境（代理 + TZ + Locale + NO\_PROXY），一行切换 |
| `claude-env-check [US]` | 跑 5 项自检（IP/时区/Locale/DNS/跨境连通性），PASS/FAIL 一目了然 |
| `claude-env-off` | 关闭代理并还原中文 Locale，回到日常环境 |

### 确认本地代理端口

V2rayN 默认监听端口：

| 客户端 | SOCKS5 端口 | HTTP 端口 |
| --- | --- | --- |
| V2rayN (Mac) | 10808 | 10809 |

下文脚本默认走 `socks5h://127.0.0.1:10808`。如果你的 V2rayN 同时开了 HTTP 和 SOCKS5 双端口，也可以改为 HTTP 端口；只开了 SOCKS5 一个口的情况推荐 `socks5h://`，**能把 DNS 一起走代理，避免 DNS 泄漏到本地**。

### 安装步骤

1. **把脚本写到家目录**：新建 `~/.claude-env.sh`，粘贴下方完整代码
2. **赋予执行权限**：

    ```bash
    chmod +x ~/.claude-env.sh
    ```

3. **注册到 zsh**：在 `~/.zshrc` 末尾追加一行：

    ```text
    [ -f "$HOME/.claude-env.sh" ] && source "$HOME/.claude-env.sh"
    ```

4. **重载**：`exec zsh` 或开一个新终端，`claude-env` 等三个命令就可用了

> [!NOTE]
> 设计决策：注册函数 ≠ 自动激活
>
> 这套脚本在 `.zshrc` 里 source 后**只注册三个函数，不会自动改任何环境变量**。每次新开终端是"干净"状态，需要时手动 `claude-env` 切到美西模式。
>
> 反例：如果在 `.zshrc` 里直接 `export HTTP_PROXY=...`，所有终端命令（`git clone` 内网仓库、`brew install`、`curl` 公司接口）都会走代理，且终端启动时还要 `curl ipinfo.io` 拖慢几秒。

### 完整脚本 `~/.claude-env.sh`

```bash
#!/bin/bash
# Claude Code 环境配置 + 一致性自检
# 安装: 在 ~/.zshrc 末尾加 `source ~/.claude-env.sh`
# 使用(按需手动调用,不会自动激活):
#   claude-env              激活美西环境(代理/时区/Locale)
#   claude-env-check [US]   一致性自检
#   claude-env-off          关闭代理并还原 Locale

claude-env() {
    export HTTP_PROXY="socks5h://127.0.0.1:10808"
    export HTTPS_PROXY="socks5h://127.0.0.1:10808"
    export ALL_PROXY="socks5h://127.0.0.1:10808"
    export NO_PROXY="localhost,127.0.0.1,::1,.local,.corp.example"
    export TZ="America/Los_Angeles"
    export LANG="en_US.UTF-8"
    export LC_ALL="en_US.UTF-8"
    echo "✅ Claude 环境已激活 (代理=10808, TZ=PST, Locale=en_US)"
}

claude-env-off() {
    unset HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY TZ LC_ALL
    export LANG="zh_CN.UTF-8"
    echo "✅ 已关闭 Claude 环境"
}

claude-env-check() {
    local EXPECT_COUNTRY="${1:-US}"
    local GREEN='\033[0;32m' RED='\033[0;31m' YELLOW='\033[0;33m' NC='\033[0m'
    local pass_p="${GREEN}[PASS]${NC}" fail_p="${RED}[FAIL]${NC}" warn_p="${YELLOW}[WARN]${NC}"

    echo "===== 环境一致性检查 (期望地区: $EXPECT_COUNTRY) ====="

    # 1. IP 出口
    echo
    echo "1. IP 出口国家:"
    local IP_JSON COUNTRY
    IP_JSON=$(curl -s --max-time 8 https://ipinfo.io/json)
    echo "$IP_JSON" | grep -E '"ip"|"country"|"city"|"org"'
    COUNTRY=$(echo "$IP_JSON" | grep '"country"' | sed -E 's/.*"country": *"([^"]+)".*/\1/')
    if [ "$COUNTRY" = "$EXPECT_COUNTRY" ]; then
        echo -e "   $pass_p IP 国家 = $COUNTRY"
    else
        echo -e "   $fail_p IP 国家 = ${COUNTRY:-未知}, 期望 $EXPECT_COUNTRY (非 $EXPECT_COUNTRY 易触发 403)"
    fi

    # 2. 时区
    echo
    echo "2. 系统时区:"
    local TZ_ABBR TZ_OFF
    TZ_ABBR=$(date +%Z)
    TZ_OFF=$(date +%z)
    echo "   当前时区: $TZ_ABBR (UTC$TZ_OFF)"
    echo "   当前时间: $(date)"
    case "$EXPECT_COUNTRY" in
        US)
            if echo "$TZ_ABBR" | grep -qE '^(PST|PDT|EST|EDT|CST|CDT|MST|MDT|HST|AKST|AKDT)$' && [ "$TZ_OFF" != "+0800" ]; then
                echo -e "   $pass_p 时区 $TZ_ABBR 属于美国时区"
            else
                echo -e "   $fail_p 时区 $TZ_ABBR ($TZ_OFF) 不像美国时区, CST+0800 会被交叉验证"
            fi
            ;;
        *)
            echo -e "   $warn_p 未配置 $EXPECT_COUNTRY 的时区白名单, 请人工核对"
            ;;
    esac

    # 3. Locale
    echo
    echo "3. 系统 Locale:"
    echo "   LANG=$LANG"
    echo "   LC_ALL=${LC_ALL:-未设置}"
    local LOCALE_VAL="${LC_ALL:-$LANG}"
    case "$EXPECT_COUNTRY" in
        US)
            if echo "$LOCALE_VAL" | grep -qi '^en_US'; then
                echo -e "   $pass_p Locale = $LOCALE_VAL"
            elif echo "$LOCALE_VAL" | grep -qi '^zh'; then
                echo -e "   $fail_p Locale = $LOCALE_VAL, zh_* 会作为辅助判定依据"
            else
                echo -e "   $warn_p Locale = $LOCALE_VAL, 建议改为 en_US.UTF-8"
            fi
            ;;
        *)
            echo -e "   $warn_p 未配置 $EXPECT_COUNTRY 的 Locale 白名单, 请人工核对"
            ;;
    esac

    # 4. DNS 泄漏
    echo
    echo "4. DNS 泄漏检查:"
    local DNS_OUT DNS_SERVER
    DNS_OUT=$(nslookup api.anthropic.com 2>/dev/null | head -5)
    echo "$DNS_OUT"
    DNS_SERVER=$(echo "$DNS_OUT" | grep -i '^Server' | awk '{print $2}')
    if [ -z "$DNS_SERVER" ]; then
        echo -e "   $warn_p 未能解析 DNS 服务器地址"
    elif echo "$DNS_SERVER" | grep -qE '^(114\.114\.|223\.[56]\.|119\.29\.|180\.76\.|211\.|1\.2\.4\.8)'; then
        echo -e "   $fail_p DNS=$DNS_SERVER 是中国大陆 DNS, 可能泄漏真实位置"
    else
        echo -e "   $pass_p DNS=$DNS_SERVER (非已知国内 DNS)"
    fi

    # 5. 跨境连通性 (不带凭证, 不触发风控)
    echo
    echo "5. 跨境连通性 (api.anthropic.com):"
    local PROBE_CODE
    PROBE_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 8 https://api.anthropic.com/ 2>/dev/null)
    case "$PROBE_CODE" in
        200|301|302|307|308|400|401|403|404|405)
            echo -e "   $pass_p 网络层通畅 (HTTP $PROBE_CODE), Anthropic 服务器可达"
            ;;
        000|"")
            echo -e "   $fail_p 连接失败/超时, 代理未生效或节点不通"
            ;;
        5*)
            echo -e "   $warn_p HTTP $PROBE_CODE (服务器侧问题, 网络通道本身正常)"
            ;;
        *)
            echo -e "   $warn_p HTTP $PROBE_CODE (非典型状态)"
            ;;
    esac

    echo
    echo "============================="
}
```

### 典型使用流程

```bash
# 切到美西模式
claude-env
# ✅ Claude 环境已激活 (代理=10808, TZ=PST, Locale=en_US)

# 跑一次自检, 确认 5 项全 PASS
claude-env-check

# 启动 Claude Code
claude

# 用完关闭
claude-env-off
```

### 自检 5 项的语义

| 检查项 | 探测方法 | 合格信号 | 风险解读 |
| --- | --- | --- | --- |
| 1\. IP 出口国家 | `ipinfo.io/json` 返回的 country 字段 | `US` | 非 US 直接触发 403 |
| 2\. 系统时区 | `date +%Z` | PST/PDT/EST 等美国时区 | `CST+0800` 会被风控交叉验证 |
| 3\. 系统 Locale | `$LC_ALL` / `$LANG` | `en_US.UTF-8` | `zh_CN` 作为辅助判定依据 |
| 4\. DNS 泄漏 | `nslookup api.anthropic.com` 看 Server 字段 | 非中国大陆 DNS | 114/阿里/腾讯 DNS 会暴露真实位置 |
| 5\. 跨境连通性 | `curl https://api.anthropic.com/` 看 HTTP code | 200~404 任一 | 000/超时 = 代理失效 |

> [!NOTE]
> 为什么探测目标用 `api.anthropic.com`
>
> 这是 Claude Code 真正要访问的服务器，能直接验证"网络层是否打通到目标"。**未认证请求会被服务器返回 404**——这个 404 没有 Cloudflare challenge、不带任何账号关联、不消耗任何风控配额，是最干净的网络层信号。
>
> 对比其他常见探测目标：
>
> - `ipinfo.io`：国内能直连，**测不出代理是否打穿 GFW**
> - `google.com`：国内被墙，但许多公司内网/移动数据有特殊路由，基准不稳
> - `claude.ai`：是 OAuth 登录目标，**反复探测可能让出口 IP 被打标**，不适合做基准
> - `chatgpt.com`：Cloudflare 强力防 bot，curl 必返 `HTTP/2 403, cf-mitigated: challenge`，看似失败实则代理是通的，容易误判

> [!WARNING]
> 易踩的几个坑
>
> - **必须 `source`，不能直接执行**：`./~/.claude-env.sh` 跑完会启动子 shell，变量在子 shell 退出后丢失。在 `.zshrc` 里用 `source` 加载，函数才会注入到当前 shell。
> - **SOCKS5h vs SOCKS5 的差别在 DNS**：`socks5://` 会让 curl 在本地解析域名再走代理（DNS 仍可能泄漏），`socks5h://` 把域名直接交给代理服务器解析。能用 `socks5h://` 就用，**少数老版 Node.js 库不识别 `socks5h://`**，遇到 `Invalid protocol` 错误改回 `socks5://` 即可。
> - **NO\_PROXY 务必加白公司内网**：脚本中的 `.corp.example` 是占位域名，使用时替换为你公司的内网域名后缀；不要把真实内部域名提交到公开仓库。遗漏会导致内网 Git/包管理走代理后失败。
> - **第 4 项 DNS 检查的局限**：用了 `socks5h://` 后，Claude Code 的真实 DNS 走代理隧道，但 `nslookup` 命令只看系统 resolver。所以这一项 FAIL 不一定代表真泄漏，仅作系统层参考。
> - **新开终端会回到日常环境**：脚本只注册函数不自动激活。新 tab 里再次需要时手动 `claude-env` 一次。

### Claude Code 需要访问的域名

确保以下域名都走代理（不在 `NO_PROXY` 中排除）：

| 域名 | 用途 |
| --- | --- |
| `api.anthropic.com` | 主 API 端点（消息、会话、OAuth） |
| `downloads.claude.ai` | 自动更新、插件下载 |
| `claude.ai` | OAuth 登录授权页面 |
| `status.anthropic.com` | 服务状态检查 |
| `mcp-proxy.anthropic.com` | 远程 MCP 服务器连接 |
| `statsigapi.net` | 功能开关（Feature Flags） |

### 关于指纹伪装

Claude Code 的遥测数据会发送时区、语言、操作系统等信息。`claude-env` 已经把以下三项处理掉：

| 配置项 | 脚本里的设置 | 说明 |
| --- | --- | --- |
| 时区 | `TZ="America/Los_Angeles"` | 伪装为美西时区，和 Lightsail Oregon 一致 |
| 语言 | `LANG="en_US.UTF-8"` | 系统语言设为美式英文 |
| Locale 强覆盖 | `LC_ALL="en_US.UTF-8"` | 盖住任何 zh\_\* 残留 |

额外可选的加固项（不强制）：

```bash
# 关闭遥测（可选）
claude config set --global telemetryEnabled false

# 精简模式: 禁用后台同步等附加请求（可选）
claude --bare
```

> [!NOTE]
> 这些 export 只影响当前会话
>
> 通过 `claude-env` 设置的环境变量仅作用于当前终端，不会改变系统全局设置，关闭终端或执行 `claude-env-off` 后恢复，**不影响其他 GUI 应用**。

### OAuth 登录

```bash
# 确保代理已激活
claude-env

# 首次运行 Claude Code，触发 OAuth 登录
claude

# 浏览器会自动打开 claude.ai 授权页面
# 用你的 Claude Pro 订阅账号登录并授权
# 授权完成后回到终端，即可使用
```

> [!WARNING]
> OAuth 登录时浏览器也需要走代理
>
> 授权页面在 `claude.ai`，需要确保**浏览器也通过代理访问**。V2rayN 开启系统代理后浏览器自动走代理。

整理于 2026 年 6 月 · 仅供个人学习与技术参考
