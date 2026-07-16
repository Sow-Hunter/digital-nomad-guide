# 跨境资金与 AI 订阅决策指南

*Cross-border money decision guide*

梳理招行香港、招商永隆、Wise、Bitget Wallet / Card、Bybit Card、美国 PayPal 与 Neverless 的资格、入金、出金、消费、投资和资金保护边界。目标不是把所有账户串成最长链路，而是用最少中间层完成合法、可解释、能退出的资金操作。

**文档信息：** 更新：2026-07-15 · 官方政策动态核验：2026-07-15 · 侧重：AI 订阅与资金安全 · 不构成金融、法律或税务意见

## 目录

1. [先看结论与证据等级](#read-first)
2. [六类产品的真实身份与资格](#eligibility)
3. [银行主干：招行香港、招商永隆与跨境支付通](#bank-rail)
4. [入金流、出金流与退出测试](#money-flow)
5. [AI 服务订阅决策树](#ai-subscription)
6. [最佳消费实践与全链路成本](#spending)
7. [投资与“套利”空间](#investment)
8. [资金保护层级与安全基线](#safety)
9. [按居住地选择组合](#personas)
10. [每次操作的执行清单](#runbook)
11. [官方与社区资料索引](#sources)

<a id="read-first"></a>

## 0. 先看结论：资格优先于费率

A 监管 / 条款 B 官方帮助 / 产品资料 C 社区经验 P 本仓库实践

社区“成功”只证明某个用户在某个时间点完成过某一步，不能替代居住资格、KYC、资金用途或适用条款。本文的推荐顺序始终是：**居住与服务资格 → 同名资金来源 → 可退出性 → 资金保护 → 成本 → 收益**。

> [!CAUTION]
> **典型中国大陆居民不能把“美国手机号、海外 IP、账单地址”当成居住资格** 美国 PayPal 要求个人用户实际居住在美国或其领地；Bitget 标准卡与 Bybit 当前官方资料均限制中国大陆和香港；Neverless 的 EAA 协议面向其可服务辖区的合法居民。虚构地址、借用身份或用代理掩盖所在地，会把支付问题升级为冻结、关户和资金取回问题。

| 产品 | 适合扮演的角色 | 典型大陆居民当前判断 | 最常见误区 |
| --- | --- | --- | --- |
| 招行香港 / 招商永隆 | 银行主账户、合法跨境收付、应急储备 | 已有合资格账户优先 | 把两家机构混为一谈，或把 5 万美元便利化额度当成海外投资许可 |
| Wise | 合资格地区的多币种收付与透明换汇 | 功能受地址限制 | 中国地址没有 Wise Card，也不能获得 USD 账户信息；不能把 Wise 当加密出金中转 |
| Bitget Wallet（链上） | 自托管资产与链上操作 | 仅作自托管工具 | 助记词自持不等于 Wallet Card 卡账户也自托管 |
| Bitget Exchange Card | 合资格地区的小额消费卡 | 大陆 / 香港禁止 | 把标准卡 / APAC 卡资格和费率套到 Wallet Card |
| Bitget Wallet Card 中国项目 | Fiat24 托管卡账户；历史上面向大陆现居用户 | 当前暂停新注册 | 只看旧申请页，忽略当前帮助中心暂停提示和余额不可转出 |
| Bybit Card | 受支持地区用户的小额加密消费 | 不适用 | 只看卡能否刷，不看平台对中国大陆和香港的服务限制 |
| 美国 PayPal | 真实美国居民的支付钱包与商户争议渠道 | 非美国居民不适用 | 认为美国电话号、代理和国内卡足以建立合规账户；忽略 3%–4% 的换汇价差 |
| Neverless | 合资格地区的投资 / 加密 / 证券产品 | 大陆 / 香港居民不适用 EAA | 把展示年化收益当存款利息，或把证券投资者赔偿误解成保本 |

> [!TIP]
> **最稳的总体结构：三只桶** 核心储备放在有存款保障的银行；支付账户只留一个账单周期的额度；加密资产、收益产品和卡片余额属于风险桶，只放即使冻结或亏损也不影响生活的钱。

<a id="eligibility"></a>

## 1. 先辨认产品，再谈链路

### 招行香港不等于招商永隆

- **招行香港分行（CMB Hong Kong Branch）**是招商银行在香港的持牌银行分行。官方通知显示，自 2024-03-29 起，新开香港一卡通要求存入并维持不少于等值 **800 万港元**资产；此前已开账户不受该通知影响。
- **招商永隆银行（CMB Wing Lung Bank）**是另一家香港注册银行，有独立开户文件、费率、App 和条款。其官方开户文件页面列有中国大陆身份证材料，但是否获批仍取决于预约、KYC、用途与当期政策。
- 两者均不能因为“招商”品牌而共享开户资格、费用、账户号码或客服结论。转账前按收款银行全名、SWIFT、账户名和适用费用逐项核对。

### Wise：同一个账户，功能随居住地和证件变化

- Wise 官方页面当前允许中国居民持有余额，但香港居民的余额功能仅列企业账户；卡片支持地区列表不包含中国大陆或香港。
- 中国地址用户不能获得 USD 账户信息。HKD 账户信息还有证件类型和额外审核条件，不能从“能注册 Wise”推导出“有美元账号和卡”。
- 从 CNY 汇出功能面向符合税务记录条件的非中国籍人士；中国大陆籍用户不应把它当人民币自由出境通道。

### Bitget：Wallet、交易所与 Card 是三个风险边界

- **Bitget Wallet 链上余额**是自托管钱包：用户控制助记词 / 私钥，平台无法替你恢复丢失的密钥；这不等于资产有银行存款保障。
- **Bitget 交易所账户**是平台托管和交易关系，受适用实体、地区、KYC 与平台条款约束。
- **Bitget Exchange Card**又分标准卡与 APAC 等项目。标准卡官方申请资料明确把中国大陆和香港列为禁止地区；APAC 资格和发卡实体另按居住地判断。
- **Bitget Wallet Card**另有 Fiat24、DCS、Immersve 等项目。旧版 Fiat24 中国申请页面向中国大陆现居用户、排除港澳与海外，但当前帮助中心明确显示“中国大陆暂停新用户注册”，所以旧资格不能当成现在可申请。既有中国卡账户的充值资产会转为托管法币余额，当前帮助资料写未消费余额不能转出；只充值近期确定要花的小额。

### Bybit、美国 PayPal 与 Neverless

| 产品 | 资格门槛 | 资金性质 | 行动建议 |
| --- | --- | --- | --- |
| Bybit Card | 只面向列明地区的真实居民；Bybit 当前限制中国大陆与香港服务 | 交易平台余额驱动的支付卡，不是银行存款 | 只有实际迁居受支持地区并完成真实 KYC 后再评估 |
| 美国 PayPal | 个人必须是美国或其领地居民、年满 18 岁；可能要求政府证件和地址证明 | 支付钱包余额及绑定资金源，不是长期储蓄工具 | 仅真实美国居民使用；银行账户必须匹配美国账户与姓名 |
| Neverless | 按适用实体与所在地开放；当前 EAA 协议要求可服务国家的合法居民，范围不等同全球 | 加密托管、策略与证券可能由不同实体提供 | 先在 App / 协议确认法律实体和产品，再判断保障；大陆 / 香港居民不要伪造 EEA 居住 |

> [!NOTE]
> **Neverless 目前不是支付卡** Apple Pay / Google Pay 在其定价页中属于部分地区的入金方式，不是可用于商户或 AI 订阅的“Neverless Card”。Neverless 在本组合中只能放在投资 / 资产服务一侧。

<a id="bank-rail"></a>

## 2. 银行主干：日常资金不要绕远路

**合法收入**<br>
工资、经营、储蓄及来源材料

→

**境内本人账户**<br>
真实用途购汇 / 人民币通道

→

**跨境支付通或银行汇款**<br>
同名、额度与用途核验

→

**本人香港银行账户**<br>
生活、留学、旅行或获准用途

### 跨境支付通能降低操作摩擦，但不会改变外汇用途规则

香港金管局当前说明：**南向（内地 → 香港）**汇款可在指定条件下使用内地居民每年等值 5 万美元便利化额度；**北向（香港 → 内地）**付款人须符合香港身份证等条件，并设有每家参与机构每日 1 万港元、每年 20 万港元等安排。服务为 16×7，参与银行和限额可能调整。招商银行是内地参与机构，招行香港与招商永隆均出现在香港参与机构资料中。

> [!WARNING]
> **“不另交用途证明”不等于“任何用途都允许”** 国家外汇管理局仍禁止借用额度、拆分、虚假材料，以及使用个人购汇便利化额度进行未获允许的境外证券、房地产等资本项目。银行会按交易实质和 KYC 审核；备注、金额和后续流向应与真实用途一致。

### 存款保障只保护合资格存款

香港存款保障计划自 2024-10-01 起，把每名存款人在每家成员银行的最高保障提高到 **80 万港元**。截至 2025-03-31 的公开成员附件分别列出招商银行股份有限公司与招商永隆，因此该名单下的合资格香港存款按两个成员分别计算；外币普通存款也可能合资格，但结构性存款、期限超过五年的存款、债券、股票、基金、保险、虚拟资产和存储值工具不在保障范围。开户和入金前仍应核对当期成员标识以及具体产品是否受保。

> [!WARNING]
> **香港银行账户不等于可做国际线上循环扣款的 Visa / Mastercard** 招行香港与招商永隆的公开借记卡资料主要围绕银联、EPS、JETCO / ATM 和实体消费。它们适合作法币中枢，但不要仅凭“港卡”名称推断能订阅 Claude、ChatGPT 或其他国际 SaaS；应另行核对具体卡组织、线上交易、3DS 和 recurring billing 能力。

<a id="money-flow"></a>

## 3. 入金流、出金流与退出测试

### 推荐入金流

| 场景 | 推荐路径 | 先决条件 | 不要做 |
| --- | --- | --- | --- |
| 香港生活 / 海外日常支付 | 境内本人账户 → 合法购汇 / 跨境支付通 → 本人香港银行 | 真实用途、同名、保留收入与汇款记录 | 用多人额度拆分，或让陌生人代收代付 |
| Wise 换汇 / 转账 | 本人银行 → 本人 Wise → 换汇 → 本人或真实收款方 | 居住地支持对应余额 / 账户信息；资金来源兼容 | Bitget P2P 买家直接付款到 Wise，或隐瞒加密来源 |
| 合资格加密卡消费 | 本人合法资金 → 受支持入金 → 交易所 / 钱包 → 仅保留短期卡余额 | 真实受支持居住地、KYC、税务与链路可解释 | 把卡内稳定币当应急储蓄或工资账户 |
| Neverless 投资 | 合资格地区本人银行 / 允许的链上资产 → 对应 Neverless 实体 | 先确认实体、产品、费用、赎回与税务 | 为追求展示年化借钱入金，或把投资者赔偿当保本 |

### 推荐出金流

| 起点 | 优先退出路径 | 必须保存的材料 | 主要风险 |
| --- | --- | --- | --- |
| 香港银行 | 本人香港银行 → 本人境内 / 海外银行，按真实用途申报 | 银行流水、工资 / 交易合同、汇款用途、税务记录 | 频繁无解释往返、个人账户经营使用、拆单 |
| Wise | Wise → 同名银行或真实商品 / 服务收款方 | 入金来源、兑换记录、发票 / 合同 | 第三方款项、P2P、Wise 不兼容的加密平台 |
| Bitget / Bybit | 先用平台当前支持的受监管出金或本人链上地址做小额测试 | 入金证明、交易历史、TxID、钱包归属、税务成本 | 平台 / 地区限制、链错、对手方污染、冻结 |
| Neverless | 先按产品赎回，再到同名银行或本人链上地址 | 产品确认、收益 / 成本、赎回和提现记录 | 提前退出费、流动性、合规审核、市场亏损 |
| 美国 PayPal | 余额 → 同名美国银行，尽量保持同币种并选标准提现 | 商户订单、退款 / 争议记录、资金来源 | 即时提现费、换汇价差、账户限制 |

> [!TIP]
> **先做退出测试，再扩大余额** 新路径只用可承受损失的小额完成一次“入金 → 使用 / 投资 → 赎回 → 到账”闭环。记录到账净额和天数；如果无法解释法律实体、资金来源或退出路径，就不扩大规模。

<a id="ai-subscription"></a>

## 4. AI 服务订阅：支付成功不是资格证明

1. **先查服务地区。**OpenAI 与 Anthropic 都维护支持国家 / 地区页面。人在未支持地区，不能用一张可扣款的海外卡替代服务资格。
2. **再查付款主体。**网页直付要求发卡地区、账单地址、姓名和 3DS 能通过；Apple / Google 内购还要遵守真实商店地区及其付款规则。
3. **选最短链路。**真实居住地的银行信用卡 / 借记卡直付通常最清楚；移动端内购适合需要 Apple / Google 账单与订阅管理的人。
4. **只留一个订阅渠道。**网页、App Store 和 Google Play 可能形成重复订阅；切换前先取消原渠道并确认到期。
5. **首次只买月付。**先验证账号稳定、发票、退款路径和续费，再评估官方年付或用量包。

> [!CAUTION]
> **中国大陆和香港目前不在 OpenAI 的 ChatGPT 支持地区列表中** OpenAI 说明，从不支持国家 / 地区访问或使用其不支持地区的付款方式，可能导致访问受阻或账户暂停。Anthropic 也要求先符合其支持地区和消费者条款。本文不提供伪造居住地、账单地址、商店区或绕过封禁的操作步骤。

> [!NOTE]
> **美国 PayPal 不是 Claude / ChatGPT 网页直付通道** Claude 当前官方账单帮助明确只接受信用卡 / 借记卡，不接受 PayPal 或 Venmo；ChatGPT 网页官方通用支付清单也没有把 PayPal 列为通用方式。真实美国居民可在 Apple / Google 明确支持 PayPal 时把它作为移动商店资金源，但商店地区、付款资料与本人所在地仍须一致。

| 订阅路径 | 适合谁 | 优点 | 主要边界 | 建议 |
| --- | --- | --- | --- | --- |
| 网页直接刷卡 | 服务与发卡地均受支持的真实用户 | 链路短、账单清楚、少一层平台 | 发卡地区、账单地址、3DS、续费风控 | 首选 |
| App Store / Google Play | 真实商店地区且需要移动端账单管理的用户 | 订阅管理和退款入口集中 | 商店地区、付款方式与服务资格是三套规则 | 合资格时可选 |
| Wise Card | Wise Card 支持地区的真实居民 | 换汇透明，适合多币种日常消费 | 中国大陆 / 香港居民不能新领 Wise Card | 按居住地 |
| Bitget Exchange / Bybit Card | 卡项目与 AI 服务均支持地区的用户 | 可把小额稳定币转为消费能力 | 地区资格；部分项目 0.9% 转换费，另有 FX、平台与发卡方多层风控 | 仅备用 |
| Bitget Wallet Card | 对应地区项目仍开放且本人合资格的用户 | 钱包充值后形成独立卡账户消费能力 | 费率和退出按 Fiat24 / DCS / Immersve 分开；中国项目当前暂停新注册且既有未消费余额不能转出 | 既有用户小额 |
| 美国 PayPal | 真实美国居民且资料、美国银行 / 卡匹配 | 商户不直接保存卡号，部分交易有争议渠道 | 身份核验、位置变化、换汇价差；并非所有数字服务都适用买家保护 | 美国居民可选 |
| 礼品余额 | 真实商店地区、接受余额支付的用户 | 隔离主卡并限制损失上限 | 余额通常不可提现，礼品卡来源和账号限制风险 | 小额备用 |

### 本仓库实践给出的边界

P Bitget 卡曾通过 Google Play 完成 Claude Pro 首次付款，但 Claude 账号随后被停用；美区 PayPal 曾成功绑定 Apple 付款方式但实际扣款失败。它们共同说明“绑卡成功”“订单成功”“服务持续可用”是三个独立阶段。详细证据、退款与申诉路径见 [Bitget Card 使用与争议手册](bitget_card_guide.md)。

<a id="spending"></a>

## 5. 最佳消费实践：算净成本，不看卡面币种

```text
全链路消费成本 = 入金费 + 汇兑费 / 隐含价差 + 稳定币兑换费 + 卡交易费 + 非本币 FX + 商户附加费 + 提现 / 退款损耗

实际返现收益 = 返现 - 上述全部成本 - 被排除 MCC / 撤销返现的预期损失
```

| 工具 | 已知成本特征 | 适合的消费 | 不适合 |
| --- | --- | --- | --- |
| 香港银行本币卡 | 取决于发卡行外币手续费和卡组织汇率 | 有稳定银行流水、需要传统争议处理的订阅与旅行 | 未核对 DCC、外币手续费和境外交易开关 |
| Wise Card | 中间价 + 明示费用；资金不足币种时自动转换 | 受支持居民的多币种日常消费 | 中国大陆 / 香港居民申请、加密平台充值 |
| Bitget Exchange 标准 / APAC Card | 对应公开费率通常含 0.9% 交易 / 转换费；非 USD 还可能有 1% + Visa 汇率；这些项目的授权可预留 120% | 合资格用户的小额 USD 消费与已验证商户 | 酒店 / 租车等大额预授权、紧急资金、Wise 入金 |
| Bitget Wallet Card 中国 / Fiat24（既有卡） | 当前帮助资料列 1% 充值费，消费本身不另收费但跨币种可能约有 1% 汇差；微信 / 支付宝单笔超过 200 元可能另收 3% | 仍合资格的既有用户小额、确定性消费 | 新注册当前暂停；未消费卡余额不能转出，不作储蓄或可逆中转 |
| Bybit Card | 费率、FX、ATM 和限额按项目与地区变化 | 合资格用户在 App 当前费率可接受时的小额备用 | 中国大陆 / 香港居民；只看营销返现忽略转换费 |
| 美国 PayPal | 无换汇的合资格购买通常无消费者手续费；PayPal 当前个人费率页列出约 3%–4% 的换汇价差 | 真实美国居民、同币种、需要隐藏卡号的商户 | 跨币种“套利”、长期持有余额、身份资料不完整 |
| Neverless | 当前 EAA 定价页列 Apple / Google 前 3 笔且累计不超过 1,000 USD 后收 2.49%；银行、链上和退出费另按产品变化 | 合资格用户的投资入金，不是主消费卡 | 把入金优惠当消费返现或无风险收益 |

### 订阅消费的实操纪律

- 账单币种尽量和账户持有币种一致，拒绝商户 DCC；先用官方价格页确认税前 / 税后金额。
- 支付账户只留 1–2 个账单周期余额，打开即时通知和低限额；非订阅日冻结不用的卡。
- 卡片需要 120% 授权时，把“可用余额”而不是“总余额”作为判断依据。
- 保存订阅渠道、订单号、续费日、取消入口与退款责任方；不要同时从网页和移动商店购买同一服务。
- 连续拒付后停止重试，先判断是商户、商店、卡组织、发卡项目还是账户资格问题。

<a id="investment"></a>

## 6. 投资与“套利”：先算回本，再算尾部风险

```text
往返成本率 = 入金 + 兑换价差 / 滑点 + 平台费 + 出金 + 税务与合规成本
回本天数 ≈ 往返成本率 ÷ 税后可实现年化收益率 × 365
```

例如往返总成本 2%、可实现净年化 7.16%，仅回收交易成本就约需 102 天；7.16% 只是 Neverless 官网在 2026-07-15 展示的营销页快照，收益可变且不保证。这还没有计入收益率下降、稳定币脱锚、平台冻结、市场亏损或税务。不同平台之间的显示收益率差，不是无风险套利。

| 机会 | 可能的价值 | 隐藏成本 / 风险 | 结论 |
| --- | --- | --- | --- |
| 香港银行定存 / 货币管理 | 核心现金分层、流动性和存保范围内的本金保护 | 外汇波动；结构性产品、基金和证券不受存保保护 | 适合核心储备 |
| Wise 自动换汇 / 中间价 | 减少不透明价差，适合真实支付和汇款 | 仍有明示费用、动态费与转换频率限制；不是高频交易平台 | 省成本，不是套利 |
| Wise Interest | 部分地区把余额投资于货币市场基金 | 中国 / 香港不可用；收益可变，可能亏损，不是银行现金 | 仅合资格地区 |
| Neverless Strategies | 当前页面展示可变 AER，可作风险资产的一小部分 | 非存款、非保证收益；条款允许借出、质押 / 再质押和使用第三方协议，另有流动性、延迟赎回与不足 14 天退出费风险 | 限额、先退出测试 |
| Bitget / Bybit Earn 与卡返现 | 闲置风险资金收益或抵消费成本 | 平台、稳定币、条款、MCC 排除、返现撤回和税务；Bybit 部分订阅奖励还要求商户官网直付，不含 App Store / Google Play | 不能覆盖核心储备 |
| PayPal 跨币种 | 支付便利 | 3%–4% 换汇价差通常已吞噬价差机会；用户协议也限制投机交易 / conversion arbitrage | 不做 FX 套利 |
| AI 官方年付 / 用量包 | 只有在持续真实使用时，官方折扣可降低单位成本 | 预付锁定、账号资格、退款限制和使用量预测误差 | 先月付验证 |

> [!WARNING]
> **跨境投资必须和资金用途分开判断** 产品对你开放，不代表境内资金可以通过个人购汇便利化额度用于该投资。先确认居住地、税务居民身份、资金来源地规则和平台法律实体；不确定时咨询持牌机构或专业顾问。

<a id="safety"></a>

## 7. 资金保护层级：名字相似，保障完全不同

| 资金位置 | 典型保护 | 不保护什么 | 余额上限思路 |
| --- | --- | --- | --- |
| 香港存保成员银行的合资格存款 | 每名存款人每家成员银行最高 80 万港元 | 市场亏损、结构性产品、证券、基金、保险、虚拟资产 | 核心储备按银行和保障上限分散 |
| Wise 电子货币余额 | 客户资金隔离 / safeguarding，按服务实体规则执行 | 不是普通银行存款保险；冻结期间的即时可用性 | 日常周转，不放全部应急金 |
| 美国 PayPal 余额 | 支付平台控制、部分交易争议机制 | 不等同银行储蓄；买家保护有类别和时限排除 | 尽快结算到同名银行 |
| Bitget Exchange / Bybit 托管账户与卡余额 | 平台安全措施、发卡项目争议流程 | 无银行存保；平台、稳定币、地区与交易对手风险 | 仅一个账单周期的小额 |
| Bitget Wallet 自托管 | 用户掌握私钥，隔离交易所托管风险 | 助记词丢失、钓鱼、恶意授权、链错通常不可逆 | 按密钥管理能力分层，冷 / 热钱包分开 |
| Bitget Wallet Card 托管余额 | 取决于 Fiat24 / DCS / Immersve 等发卡项目及争议流程 | 不是助记词控制的链上余额；中国项目当前未消费余额不能转出，也无银行存保 | 只充值近期确定要花的小额 |
| Neverless 证券 / 加密 / 策略 | 仅 Boku Securities SIA 提供的合资格证券服务，可能在机构无法返还资产时适用拉脱维亚投资者赔偿，最高 20,000 欧元 | 不保护市场亏损；Neverless Labs 的 crypto / Strategies 不自动享有该证券赔偿或存保 | 先识别实体，再设风险预算 |

### 账户与密钥安全基线

- 每个平台使用独立邮箱和唯一密码；优先通行密钥 / 硬件密钥，其次 TOTP，不把短信作为唯一二要素。
- 启用提现白名单、反钓鱼码、登录 / 交易通知、低卡限额；不用时冻结卡和撤销不再使用的 API / 钱包授权。
- 助记词离线保存至少两份，分开地点；绝不放云笔记、聊天窗口、截图相册或密码管理器普通备注。
- 保留资金来源台账：收入、购汇、银行流水、交易所入金、TxID、成本价、提现、发票和税务材料能首尾相接。
- 每季度做一次小额退出演练；账户限制时不密集重试、不拆单，按平台要求提供完整原始材料。

<a id="personas"></a>

## 8. 按真实居住地选择组合

### 中国大陆居民，已有合资格香港银行账户

**核心：**香港银行做储备与真实跨境生活支付，跨境支付通 / 银行汇款做可解释入出金。Wise 只使用中国地址实际开放的转账功能；Bitget Exchange Card、Bybit Card、美国 PayPal、Neverless 不作为新开户方案，Bitget Wallet Card 中国项目当前也暂停新注册。AI 服务只在本人实际符合官方支持地区时订阅。

### 中国大陆居民，没有香港或海外居住资格

**核心：**不要为订阅建立虚假海外账户链。招行香港新账户门槛很高，可按真实需求了解招商永隆或其他持牌银行的当前开户规则，但不保证批准。优先选择中国区正式提供的服务、雇主 / 企业合规渠道或等待服务开放。

### 真实 EEA / Wise Card 支持地区居民

**核心：**当地受保存款银行做储备，Wise 做多币种消费和汇款；Neverless 只作为有上限的投资桶，并核对提供产品的法律实体。Bitget / Bybit Card 只有在居住地和卡项目均支持时才作小额备用。

### 真实美国居民

**核心：**美国银行与匹配账单地址的卡直接支付 AI 服务；PayPal 用于希望隔离卡号或需要其支付流程的商户，并尽量避免 PayPal 换汇。Bybit 当前把美国列为受限地区，Neverless EAA 也面向 EEA 合资格且非美国人士；Wise、加密卡和 Neverless 都不是美国 AI 订阅的必需中间层。

### 已有旧版 Bitget Card，当前账户仍显示可用

**核心：**“旧卡仍可刷”不证明当前新申请资格，也不覆盖账户所在地变化。以 App 内适用条款和客服书面答复为准；只留短期消费余额，先在低额普通商户测试，保留传统银行备用卡和退出路径。

<a id="runbook"></a>

## 9. 每次资金操作的执行清单

1. 记录当天日期、实际居住地、税务居民身份、产品法律实体和条款版本。
2. 在官方支持 / 限制页面确认地区、证件、卡项目和服务资格；不要只问社区“能不能用”。
3. 画出完整链路，逐段写出账户所有人、币种、费用、汇率、资金保护、预计到账时间和失败责任方。
4. 确认资金来源与用途真实合法，所有银行 / 平台尽量同名；提前准备收入、合同、账单和税务文件。
5. 用最小金额完成入金、支付 / 投资、退款 / 赎回、出金闭环，计算最终到账净额。
6. 给支付桶和风险桶设硬上限；核心储备不经过 PayPal、交易所、加密卡或投资平台。
7. 每月重新核对费率、支持地区、卡条款、提现网络与 AI 服务订阅状态；政策变化时先停新增资金。

> [!NOTE]
> **社区经验的正确用法** 用近期社区帖寻找“哪个环节容易卡住、需要什么材料、退款多久”这类操作信号；资格、费率、额度、资金保障和法律边界仍以监管与适用于本人账户的官方条款为准。

| 近期社区样本 | 可以借鉴 | 不能推出 |
| --- | --- | --- |
| 招商永隆到店开户个案 | 提前准备身份、地址、职业、社保 / 资产、开户用途与资金来源材料 | 不能推出“人人 15–30 分钟必开”或固定存款就是开户门槛 |
| 美国 PayPal 绑定中国卡后受限 / 申诉个案 | 姓名、地址、卡账单与交易资料的一致性，以及提前保留退出证据很重要 | 不能推出美国 IP、手机号、护照或申诉可以替代美国居住资格 |
| Wise 涉加密转账后关户报告 | 在执行前核对对手平台法律实体与 Wise 兼容政策 | 不能用单个用户对关户原因的推测证明因果，也不能用偶发成功覆盖官方限制 |
| Bybit Card 支付 AI 服务的成败混合报告 | 商户受理、订阅奖励、卡项目与账号资格要分别验证 | 不能从 Claude 一笔成功推导 ChatGPT、Cursor 或续费都成功 |
| Neverless 公开评价中的客服与提现反馈 | 先做小额赎回 / 提现，保存签约实体和第三方银行信息 | 自选择评价不能代表总体成功率或故障率 |

<a id="sources"></a>

## 10. 官方与社区资料索引

动态页面于 **2026-07-15**核验。不同语言、地区、登录状态和法律实体可能展示不同版本；执行前应再次打开原文。

### A 监管、条款与资金保护

- [香港金管局：招商银行香港分行登记](https://vpr.hkma.gov.hk/eng/regulatory-resources/registers/register-of-ais-and-lros/info/100255)。
- [香港金管局：跨境支付通](https://www.hkma.gov.hk/eng/smart-consumers/payment-connect/)：参与机构、服务时段与南北向限额。
- [国家外汇管理局：个人购汇常见问题](https://www.safe.gov.cn/shanghai/2019/1213/1198.md)：5 万美元便利化额度、禁止用途与不得拆分。
- [国家外汇管理局：个人外汇业务政策问答](https://www.safe.gov.cn/safe/file/file/20230908/1381cedc1da643a9b2f6ea097152dc4c.pdf)：真实性审核与交易实质。
- [香港存款保障委员会：保障范围](https://www.dps.org.hk/en/coverage.md)：80 万港元上限及不受保障产品；[2025 成员名单附件](https://www.dps.org.hk/en/download/pdf/annual_report_2025/e_10_annex.pdf)分别列出招商银行与招商永隆。
- [PayPal US User Agreement](https://www.paypal.com/us/legalhub/paypal/useragreement-full?locale.x=en-US)：美国居民资格、身份与账户规则。
- [PayPal Purchase Protection](https://www.paypal.com/us/legalhub/paypal/buyer-protection)：争议时限、适用条件与排除类别。
- [Bybit：受限制国家 / 地区](https://www.bybit.com/en/help-center/article/Service-Restricted-Countries)。
- [Neverless EAA Client Agreement](https://neverless.com/zh-Hant_EAA/legal/terms) 与 [法律实体总览](https://neverless.com/es_GB/legal)。
- [Neverless 风险披露](https://neverless.com/en_ES/advertising-policy)：加密资产、收益与保障边界。

### B 官方产品与帮助资料

- [招行香港：香港一卡通新开户资产要求](https://hk.cmbchina.com/Notice/Detail?guid=2d817024-1756-46dd-8f6b-fc493f7589ff)。
- [招行香港：个人账户合规使用提示](https://hk.cmbchina.com/Notice/Detail.aspx?guid=9baa8781-1c1d-4d88-9536-568c132221ce)。
- [招行香港：香港一卡通使用手册](https://s3gw.cmbimg.com/lb5001-cmbweb-prd-1255000097/cmbcms/20230324/6935fb36-ca18-4041-91a1-0edd29c18341.pdf)：转账、汇款、卡片与限额的历史公开说明；使用前以 App 当前设置为准。
- [招商永隆：开户所需文件](https://www.cmbwinglungbank.com/wlb_corporate/hk/about-us/service-guide/documents-required-for-opening-account.md)、[服务收费](https://www.cmbwinglungbank.com/wlb_corporate/cn/about-us/service-guide/service-fee/tariff_guide.md)与[ATM 卡资料](https://www.cmbwinglungbank.com/wlb_corporate/hk/e-services/wing-lung-atm-card/new-wing-lung-chip-based-atm-card.md)。
- [Wise：余额功能支持地区](https://wise.com/help/articles/2813542/where-do-i-need-to-live-to-hold-money-with-wise)、[Wise Card 支持地区](https://wise.com/help/articles/2968915/can-i-get-the-wise-card-in-my-country)、[USD 账户信息资格](https://wise.com/help/articles/2810318/can-i-get-usd-account-details)。
- [Wise：HKD 账户信息与证件条件](https://wise.com/help/articles/12CQfcpIVOHULnFNNzBgmE/how-do-i-receive-money-with-my-hkd-account-details)、[CNY 转账条件](https://wise.com/help/articles/2955298/guide-to-cny-transfers)。
- [Wise：不兼容账户、第三方与加密付款](https://wise.com/help/articles/2932118/incompatible-accounts-and-payments)、[资金 safeguarding](https://wise.com/help/articles/2949821/how-wise-keeps-your-money-safe)。
- [Wise Interest：支持地区与投资风险](https://wise.com/help/articles/1o9thu2We5TjlL9YpGBnuI/wise-interest-how-is-your-money-held-and-what-is-the-risk)。
- [Wise：中间市场汇率](https://wise.com/help/articles/2932395/whats-the-mid-market-exchange-rate)、[余额换汇与频率](https://wise.com/help/articles/2596980/how-can-i-convert-money)、[动态费用](https://wise.com/help/articles/2amMyWoOyhgTL0CkDcY2m4/what-are-dynamic-charges)。
- [Bitget 标准卡申请、地区与 Wise 限制](https://www.bitget.com/support/articles/12560603840909)、[标准卡费率](https://www.bitget.com/support/articles/12560603803519)。
- [Bitget APAC Cardholder Terms](https://www.bitget.com/support/articles/12560603881449)、[Bitget Wallet 安全架构](https://web3.bitget.com/about/security-technology)、[Wallet Card 项目总览](https://web3.bitget.com/card)与[当前帮助中心（含大陆暂停提示）](https://web3.bitget.com/zh-CN/helpCenter)。
- [Bitget Wallet Card 中国项目旧申请资格](https://web3.bitget.com/zh/helpCenter/235)、[充值与未消费余额限制](https://web3.bitget.com/zh/helpCenter/239)、[费用说明](https://web3.bitget.com/zh/helpCenter/241)：旧申请页须与当前暂停状态一起阅读。
- [Bybit Card 申请资格](https://www.bybit.com/en/help-center/article/How-to-Apply-for-Bybit-Card)、[费率与限额](https://www.bybit.com/en/help-center/article/Fees-and-Spending-Limits-Bybit-Card)、[订阅奖励规则](https://www.bybit.com/en/help-center/article/Introduction-to-Bybit-Card-Rewards)。
- [PayPal US 消费者费率](https://www.paypal.com/us/digital-wallet/paypal-consumer-fees?locale.x=en_US)、[身份核验](https://securepayments.paypal.com/us/cshelp/article/how-do-i-confirm-my-identity-cip-help606)、[银行账户与姓名要求](https://www.paypal.com/us/cshelp/article/why-cant-i-link-a-bank-account-to-my-paypal-account-help199)、[位置 / 设备安全检查](https://www.paypal.com/us/cshelp/article/why-do-i-have-to-complete-a-security-check-help171)。
- [Neverless 营销首页](https://neverless.com/)：2026-07-15 的可变 AER 快照；[Neverless Pricing](https://neverless.com/en_EAA/pricing)、[股票与投资者赔偿说明](https://neverless.com/es_ES/stocks)。
- [OpenAI：ChatGPT 支持地区](https://help.openai.com/en/articles/7947663-chatgpt-supported-countries/)、[不支持地区访问与付款说明](https://help.openai.com/en/articles/9131992)、[卡片拒付排查](https://help.openai.com/en/articles/7232916-why-was-my-credit-card-declined)。
- [OpenAI：避免网页与移动端重复订阅](https://help.openai.com/en/articles/20001043-how-do-i-avoid-being-charged-twice-if-i-subscribe-to-chatgpt-on-ios-android-and-the-web)。
- [Anthropic：支持国家 / 地区](https://www.anthropic.com/supported-countries)、[付费方案账单](https://support.claude.com/en/articles/8325618-paid-plan-billing-faqs)、[退款路径](https://support.claude.com/en/articles/12386328-requesting-a-refund-for-a-paid-claude-plan)。

### C 公开经验样本

- [近期跨境支付通入金香港账户的个人记录](https://www.reddit.com/r/u_tanghua2/comments/1s7grls/)：可用于理解 App 操作摩擦，不代表所有账户或用途都获批。
- [2025 年港卡帖评论中的招商永隆开户个案](https://forum.naixi.net/thread-5247-1-1.md) 与 [另一份开户总结](https://linux.do/t/topic/971444)：可用于准备材料，不构成审批或时效承诺。
- [美国 PayPal 绑卡后 App Store 拒付 / 账户受限个案](https://s.v2ex.com/t/1151547) 与 [历时申诉恢复的个案](https://v2ex.com/t/1194818)：证明绑定、扣款、KYC 和长期可用是不同阶段；虚假地址仍不合规。
- [Wise 涉加密转账后的关户自述](https://www.reddit.com/r/wisebank/comments/1m0i2k7/crypto_deposits_withdrawals/)：方向与官方兼容政策一致，但关户原因属于用户推测。
- [Bybit Card 支付多种 AI 商户结果不一致](https://www.reddit.com/r/BybitCard/comments/1t3cls0/bybit_card_chatgpt_plus_and_cursor_ai_payments/) 与 [Claude 返现争议](https://www.reddit.com/r/BybitCard/comments/1tuwod5/no_100_cashback_for_claude/)：营销资格不保证商户受理或返现结果。
- [Neverless 公开评价](https://www.trustpilot.com/review/neverless.com)：同时存在客服好评与入金 / 提现投诉，样本自选择，不能当总体故障率。
- [Google Play Community：Claude 购买后账号不可用的公开报告](https://support.google.com/googleplay/thread/436745664/my-claude-pro-subscription-became-unusable-shortly-after-purchase?hl=en)：说明支付与服务访问可能分离，不证明共同原因。
- [本仓库 Bitget Card 实测账本](bitget_card_guide.md)：区分绑卡、授权、清算、服务访问、退款与争议；个人结果不推广为平台普遍承诺。

任何“普遍成功经验”都有幸存者偏差。最可复用的共同点不是绕过规则，而是真实居住与地址、同名账户、小额测试、完整资金来源、低余额和可验证的退出路径。

Digital Nomad Guide · 跨境资金与 AI 订阅决策指南 · 2026
