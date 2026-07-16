# Giffgaff eSIM 模拟器申请指南

通过 MuMu 模拟器 + Kitsune Mask + LSPosed + HookEuicc，在无 eSIM 设备的情况下获取 Giffgaff 英国号码

**标签：** MuMu 模拟器 · Kitsune Mask · LSPosed · HookEuicc · Giffgaff eSIM · XeSIM / 9eSIM

免实名

无需身份证件，邮箱注册即可开通英国 +44 号码

开卡 ≈ ¥90

充值 £10 credit 即开通，无月租，不用不扣费

保号 ≈ ¥0.3/半年

每 6 个月发一条短信（£0.30），£10 够保号 30+ 次

接码免费

全球漫游免费接收短信，ChatGPT / Telegram / Wise 验证码可收

无需 eSIM 设备

模拟器开卡 + 转换卡方案，国行手机直接插卡使用

真实运营商号码

O2 网络实体号码，不会被服务商识别为 VoIP 拒收

> [!TIP]
> 教程参考
>
> **模拟器开卡视频：**以下步骤 1-9 可对照此视频操作（MuMu 配置到获取激活码完整演示）：<br>
> [https://youtu.be/870-WhPHjXc](https://youtu.be/870-WhPHjXc)
>
> **实体卡激活充值教程：**@AI\_Jasonyu 的保姆级图文指南，涵盖购卡选择、激活、充值（无需 Visa）、转 eSIM、WiFi Calling 开启全流程：<br>
> [手把手教你激活充值 Giffgaff 英国 SIM 卡](https://x.com/AI_Jasonyu/article/2069761380274630997)
>
> 建议先通读本文了解原理，再配合上述教程逐步操作。

## 目录

1. [原理与整体流程](#principle)
2. [提前下载安装包](#downloads)
3. [MuMu 模拟器新建与配置](#mumu-setup)
4. [安装 Kitsune Mask + 获取 Root](#kitsune)
5. [安装 LSPosed 模块](#lsposed)
6. [安装并配置 HookEuicc](#hookeuicc)
7. [注册 Giffgaff 并申请 eSIM](#giffgaff)
8. [获取并保存激活码](#activation-code)
9. [使用激活码（写入实体卡 / 原生设备）](#use-esim)
10. [常见问题排查](#troubleshooting)
11. [日常使用防扣费指南](#usage-pitfalls)
12. [WiFi Calling 开启与省钱指南](#wifi-calling)

<a id="principle"></a>

## 1. 原理与整体流程

Giffgaff 是英国运营商（O2 旗下 MVNO），提供免费的 eSIM。正常情况下需要一台支持 eSIM 的手机才能申请和安装 eSIM 配置。**模拟器方案**的核心思路是：用软件手段让安卓模拟器"假装"成支持 eSIM 的设备，骗过 Giffgaff App 获取激活码。

```text
MuMu 模拟器  (Android 12, Root)
    │
    ├── Kitsune Mask  (Magisk fork, 提供 Root + Zygisk)
    │       │
    │       └── LSPosed  (Zygisk 模块, Xposed 框架)
    │               │
    │               └── HookEuicc  (Hook 系统框架, 伪装 eSIM 支持)
    │
    ├── Giffgaff App  (检测到 "eSIM 设备" → 允许申请)
    │
    └── 输出 eSIM 激活码  (LPA:1$xxx$xxx)
              │
              ▼
    XeSIM / 9eSIM 转换卡  或原生 eSIM 设备
              │
              ▼
    国行手机正常使用英国号码
```

> [!NOTE]
> 关键认知
>
> **模拟器不是最终使用 eSIM 的地方，它只是开卡工具。**拿到激活码之后，后续的写卡和使用完全不依赖模拟器。激活码是一次性的，但永久有效（未写入前不会过期）。

### 安装顺序（不可跳步）

```text
Kitsune Mask → Magisk（面具内安装）→ 重启
  → LSPosed（面具模块安装）→ 重启
  → HookEuicc（APK 安装 + LSPosed 启用）→ 重启
  → Giffgaff + Via → 注册 → 购买 eSIM → 获取激活码
```

> [!CAUTION]
> 每一步安装后都必须重启模拟器
>
> Kitsune Mask、LSPosed、HookEuicc 都需要在系统层面注入，不重启不会生效。跳步骤是这类教程最大的坑。

<a id="downloads"></a>

## 2. 提前下载安装包

在电脑上提前下载以下文件，后续通过共享文件夹传入模拟器：

| 序号 | 文件 | 用途 | 下载地址 | 备注 |
| --- | --- | --- | --- | --- |
| 1 | **MuMu 模拟器** | Android 模拟器 | [Windows 版](https://mumu.163.com/) · [macOS 版](https://mumu.163.com/mac/) | 官网直接下载 |
| 2 | **Kitsune Mask APK** | Magisk 分支（Root + Zygisk） | [v27.2 直链下载](https://magiskdeltazip.com/wp-content/uploads/2025/08/magisk-delta-apk-v27.2.apk)<br>完整版本号 `v27.2-kitsune-4(27002)` | **指定 v27.2**（已验证兼容 MuMu） |
| 3 | **LSPosed ZIP**（Zygisk 版） | Xposed 框架模块 | [v1.9.2 Release](https://github.com/LSPosed/LSPosed/releases/tag/v1.9.2)<br>下载 `LSPosed-v1.9.2-7024-zygisk-release.zip` | 仓库已 Archive，但 Release 仍可下载 |
| 4 | **HookEuicc APK** | 伪装 eSIM 环境 | [v2.0.0 Release](https://github.com/Unicorn369/HookEuicc/releases/tag/v2.0.0)<br>下载 `app-release-sign.apk` | **建议 v2.0.0**（2026-04 发布） |
| 5 | **Giffgaff APK** | 英国运营商 App | [APKMirror v20.6.0](https://www.apkmirror.com/apk/giffgaff-limited/my-giffgaff/giffgaff-20-6-0-release/giffgaff-20-6-0-android-apk-download/) · [APKPure v20.6.0](https://apkpure.com/cn/giffgaff/com.giffgaffmobile.controller/download/20.6.0)<br>包名 `com.giffgaffmobile.controller` | **指定 v20.6.0**（已验证可用） |
| 6 | **Via 浏览器 APK** | 轻量浏览器（模拟器内用） | [APKPure v7.1.0](https://apkpure.com/cn/via-browser/mark.via.gp/download/7.1.0) · [官方直链（最新版）](https://res.viayoo.com/v1/via-release-cn.apk) | 可选，**指定 v7.1.0** |

> [!WARNING]
> 关于 Kitsune Mask 的仓库说明
>
> Kitsune Mask 原作者 HuskyDG 的 GitHub 仓库已被删除/私有化。本教程使用的 `v27.2-kitsune-4(27002)` 来自 [magiskdeltazip.com](https://magiskdeltazip.com/)，该版本在 MuMu 模拟器 + giffgaff 场景中已被社区广泛验证。**不要使用更新版本（如 v31.0），在模拟器中 Zygisk 无法正常加载。**

> [!WARNING]
> HookEuicc 版本
>
> 多个教程强调 HookEuicc **建议使用 v2.0.0**。其他版本可能存在兼容性问题，导致 Giffgaff 检测不到 eSIM 支持。

> [!NOTE]
> 关于 LSPosed 的版本
>
> LSPosed 官方仓库已 Archive，但 [v1.9.2 Release](https://github.com/LSPosed/LSPosed/releases/tag/v1.9.2) 仍可正常下载和使用。确保下载的是 **Zygisk 版本**（文件名含 `zygisk`），不是 Riru 版本——Kitsune Mask 使用 Zygisk。

<a id="mumu-setup"></a>

## 3. MuMu 模拟器新建与配置

### 安装 MuMu

前往 MuMu 官网下载并安装。Windows 和 macOS 都支持。

### 新建模拟器实例

1. **打开 MuMu 多开器**，点击「新建模拟器」
2. **选择 Android 版本**：推荐 **Android 12**
    - Android 12 对 Kitsune Mask + LSPosed + HookEuicc 兼容性最好
    - 不建议 Android 7/9（LSPosed 部分功能不支持）
3. **配置硬件参数**

    | 配置项 | 推荐值 | 说明 |
    | --- | --- | --- |
    | CPU | 2 核 | 默认即可 |
    | 内存 | 4GB | LSPosed + 多个 App 同时运行需要 |
    | 分辨率 | 手机模式 | 随意，不影响功能 |
    | 磁盘空间 | 默认 | 不需要大磁盘 |

4. **开启 Root**：MuMu 设置 → 其他设置 → **开启 Root 权限**
5. **开启可写系统盘**：MuMu 设置 → 磁盘设置 → **可写系统盘（Writable System Disk）** → 开启

    > [!CAUTION]
    > Root + 可写系统盘缺一不可
    >
    > **Root**：Kitsune Mask 需要 Root 权限才能安装 Magisk 和 Zygisk。
    >
    > **可写系统盘**：Magisk 安装过程需要修改系统分区（`/system`）。MuMu 默认将系统盘设为只读，不开启此选项会导致 Magisk 安装失败或重启后丢失。
    >
    > 两项都必须在**首次启动模拟器之前**设置好。如果已启动过，修改后需要**重启模拟器**生效。

6. **启动模拟器实例**

### 安装 APK 和传入文件（macOS）

MuMu Mac 版安装 APK 有两种方式，LSPosed 的 `.zip` 需要单独处理：

#### APK 文件（Kitsune Mask、HookEuicc、Giffgaff、Via）

以下两种方式任选其一：

| 方式 | 操作 |
| --- | --- |
| **菜单安装（推荐）** | Mac 菜单栏 → **工具** → **安装 APK** → 选择电脑上的 APK 文件 |
| **拖拽安装** | 直接将 APK 文件从 Finder **拖到模拟器窗口**内，松开鼠标即触发安装 |

#### LSPosed ZIP 文件

LSPosed 是 Magisk/Zygisk 模块（`.zip` 格式），**不能用上述方式安装**，必须先传入模拟器、再通过 Kitsune Mask 内安装。传入方式：

1. Mac 菜单栏 → **工具** → **共享文件夹** → 打开 Mac 端共享目录
2. 将 `LSPosed-v1.9.2-7024-zygisk-release.zip` 复制到该目录
3. 模拟器内打开**文件管理器**，在共享目录中可找到该文件
4. 后续在 Kitsune Mask → 模块 → 从本地安装 → 选择该 ZIP 文件

> [!NOTE]
> Mac 版 vs Windows 版差异
>
> Windows 版 MuMu 的共享文件夹入口在模拟器右侧工具栏 → 更多工具 → 共享文件夹。Mac 版的入口在**顶部菜单栏「工具」菜单**中，功能相同。

<a id="kitsune"></a>

## 4. 安装 Kitsune Mask + 获取 Root

### 什么是 Kitsune Mask

Kitsune Mask（狐狸面具）是 Magisk 的一个 fork 分支，提供 Root 管理和 Zygisk 支持。在模拟器环境中，它是整个工具链的地基——LSPosed 依赖 Zygisk，HookEuicc 依赖 LSPosed。

### 安装步骤

1. **安装 Kitsune Mask APK**<br>
    在模拟器内的文件管理器中找到 `app-release.apk`（Kitsune Mask），点击安装
2. **首次打开 Kitsune Mask**
    - 弹出超级用户（Root）权限请求
    - 勾选「**永久记住选择**」
    - 点击「**允许**」
3. **关闭 Kitsune Mask → 重新打开**（确保 Root 权限已持久化）
4. **安装 Magisk**
    - 在 Kitsune Mask 主界面，找到 **Magisk** 区块
    - 点击「**安装**」
    - 选择最后一项「**直接安装（直接修改 /system）**」
    - 等待安装完成
5. **重启模拟器**

### 开启 Zygisk 等关键设置

Magisk 安装并重启后，Zygisk 虽然内置但**默认未开启**，需要手动启用：

1. 打开 Kitsune Mask，点击**右上角齿轮图标**进入设置
2. 找到 **Magisk** 段，依次开启以下三项：

    | 开关 | 说明 |
    | --- | --- |
    | **Zygisk** | LSPosed 依赖 Zygisk 运行，必须开启 |
    | **MagiskHide** | 隐藏 Root 状态，防止部分 App 检测到 Root 后拒绝运行 |
    | **Sulist**（实现 Sulist） | 白名单模式管理 Root 权限，增强隐蔽性 |

3. **重启模拟器**

### 验证

重启后打开 Kitsune Mask 主界面，确认：

| 检查项 | 预期状态 |
| --- | --- |
| Magisk 版本 | 显示具体版本号（非「N/A」） |
| Zygisk | 是 |
| 超级用户 | 显示 Kitsune Mask 自身有 Root 权限 |

> [!CAUTION]
> Zygisk 显示「否」？
>
> 如果重启后 Zygisk 仍然显示「否」，检查：
>
> - 是否用的 **v27.2**（v31.0 等新版本在模拟器下 Zygisk 无法正常加载）
> - 是否开启了**可写系统盘**（第 3 章）
> - Magisk 安装时是否选的「直接安装（直接修改 /system）」

> [!WARNING]
> 不要安装额外的 Zygisk 模块
>
> Kitsune Mask v27.2 已内置 Zygisk，如果额外安装 ZygiskNext 等模块会冲突，提示 `Please disable built-in zygisk of magisk`。用内置的就行。

> [!CAUTION]
> 必须用 v27.2，不要用更新版本（如 v31.0）
>
> 社区 fork 的新版本（如 Jordan231111/KitsuneMagisk v31.0）在模拟器环境下 **Zygisk 无法正常加载**，主界面会显示 Zygisk「否」。这会导致后续 LSPosed 和 HookEuicc 全部无法工作。
>
> v27.2 是经过社区广泛验证、在 MuMu 模拟器中 Zygisk 能正常 built-in 启用的版本。**如果你已经装了其他版本且 Zygisk 显示「否」**：
>
> 1. 卸载当前版本的 Kitsune Mask
> 2. 安装 [v27.2-kitsune-4(27002) APK](https://magiskdeltazip.com/wp-content/uploads/2025/08/magisk-delta-apk-v27.2.apk)
> 3. 重新走安装流程：打开 → 授权 Root → 安装 Magisk（直接修改 /system）→ 重启
> 4. 重启后 Zygisk 应自动启用

<a id="lsposed"></a>

## 5. 安装 LSPosed 模块

### 什么是 LSPosed

LSPosed 是一个 Xposed 框架的现代实现。它允许在不修改 APK 的情况下，Hook（拦截和修改）系统和应用的行为。HookEuicc 正是通过 LSPosed 框架来拦截系统的 eUICC 相关 API，让系统误以为设备支持 eSIM。

> [!CAUTION]
> LSPosed 必须通过 Kitsune Mask 安装
>
> LSPosed 是一个 **Magisk/Zygisk 模块**（`.zip` 文件），不是普通的 APK。必须在 Kitsune Mask 的模块管理中安装，不能直接点击 zip 安装。

### 安装步骤

1. **打开 Kitsune Mask**
2. **切换到「模块」页面**（底部导航栏）
3. **点击「从本地安装」**
4. **找到共享文件夹中的 LSPosed ZIP 文件**，选择安装
5. **等待安装完成**，看到 `Done` 提示
6. **重启模拟器**

### 找到 LSPosed 管理器

重启后，LSPosed 管理器的入口可能出现在以下位置：

| 位置 | 操作 |
| --- | --- |
| 通知栏 | 下拉通知栏，找到 LSPosed 通知 → 点击创建桌面快捷方式 |
| 桌面图标 | 部分版本会自动创建桌面图标（可能是一个寄生图标，外观像另一个 App） |
| Kitsune Mask 模块页 | 点击已安装的 LSPosed 模块 → 有时有「打开」入口 |

> [!NOTE]
> 找不到 LSPosed 图标？
>
> LSPosed 默认会将自己伪装成系统应用以降低检测。下拉通知栏是最可靠的入口——看到 LSPosed 通知后长按或点击即可进入管理界面。如果通知栏也没有，尝试在模拟器拨号盘输入 `*#*#5776733#*#*`（对应 `lsposed`）。

<a id="hookeuicc"></a>

## 6. 安装并配置 HookEuicc

### 什么是 HookEuicc

HookEuicc 是一个 LSPosed/Xposed 模块。它 Hook 安卓系统中与 eUICC（eSIM 芯片）相关的 API，让系统和应用误以为设备内置了 eUICC 芯片、支持 eSIM 功能。这样 Giffgaff App 就会正常展示 eSIM 申请流程。

### 安装步骤

1. **安装 HookEuicc APK**<br>
    在模拟器文件管理器中找到 `app-release-sign.apk`，像普通 App 一样安装
2. **打开 LSPosed 管理器**
3. **进入「模块」页面**
4. **找到 HookEuicc → 启用**（打开开关）
5. **配置作用域**：点击 HookEuicc → 进入「作用域」（Scope）
    - 勾选 **System Framework**（系统框架）— 必选
    - 如果列表中有 `giffgaff`，也勾上
6. **重启模拟器**

> [!CAUTION]
> System Framework 作用域是关键
>
> HookEuicc 需要 Hook 的是**系统级 API**（`android.telephony` 包下的 eUICC 相关类），不是某个 App。如果不勾选 System Framework，HookEuicc 只会注入到 Giffgaff App 进程，无法拦截系统层面的 eSIM 能力查询，导致伪装不生效。

### 验证 HookEuicc 生效

重启后，打开 LSPosed 管理器 → 日志页面，查看是否有 HookEuicc 的日志输出。如果看到类似 `HookEuicc: hooked xxx` 的日志，说明注入成功。

### 同时安装其他 App

在这一步顺便把 **Giffgaff APK** 和 **Via 浏览器 APK** 也装上。它们是普通 APK，直接在文件管理器点击安装即可。

<a id="giffgaff"></a>

## 7. 注册 Giffgaff 并申请 eSIM

> [!WARNING]
> 网络环境要求
>
> Giffgaff 是英国运营商，其 App 和网站可能需要**科学上网**才能正常访问。确保模拟器内能访问外网。模拟器通常共享宿主机的网络，宿主机开代理即可。

### 注册 Giffgaff 账户

1. **打开 Giffgaff App**（或用 Via 浏览器访问 `giffgaff.com`）
2. **选择 Sign Up / Register**
3. **输入邮箱**：使用能正常收邮件的邮箱（Gmail 推荐）
4. **创建密码**
5. **邮箱验证**：去邮箱点击验证链接完成注册
6. **登录 Giffgaff App**

### 购买 eSIM

1. **进入 eSIM 页面**：App 内寻找「Get a SIM」或「Order a SIM」→ 选择 **eSIM**
2. **选择套餐**

    | 套餐 | 价格 | 说明 |
    | --- | --- | --- |
    | Pay As You Go | 免费（但需充值 £10 credit） | 按使用量付费，适合只需要号码 |
    | Goodybag（月包） | £10 起 | 包含通话/短信/流量 |

    > [!NOTE]
    > 选哪个套餐
    >
    > 如果只是为了拿一个英国号码用于注册验证，选 **Pay As You Go + 充值 £10** 即可。£10 credit 在账户余额中，不用不扣费。

3. **支付**：支持 Visa / Mastercard。部分虚拟卡可用（如 Wise、Dupay 等），国内双币信用卡也可以尝试
4. **支付成功**后，进入 eSIM 安装流程

<a id="activation-code"></a>

## 8. 获取并保存激活码

这是整个流程中**最关键的一步**。支付成功后 Giffgaff 会尝试在当前设备上安装 eSIM。

### 获取激活码

1. **支付成功后**，App 进入 eSIM 安装流程
2. **点击「Install eSIM」**
3. **关键时刻**：系统会弹出一个 **eSIM 激活码分享框**

    > [!NOTE]
    > 不用紧张
    >
    > 激活码会自动复制到剪贴板。如果错过了弹窗，可以**再次进入下载 eSIM 流程**，分享框会重新弹出。不需要提前录屏。

4. **复制激活码**：格式类似

    ```text
    LPA:1$rsp-xxxx.xxxx.com$XXXXXXXXXXXXXXXXXXXXXX
    ```

### 妥善保管激活码

激活码是后续写入实体转换卡或原生设备的唯一凭证。**建议三重备份**：

| 方式 | 操作 |
| --- | --- |
| 剪贴板复制 | 在模拟器内复制到记事本 App |
| 截图保存 | 模拟器截图（MuMu 工具栏有截图按钮），保存到电脑 |
| 云端备份 | 发到自己的邮箱 / 备忘录 / 云文档 |

> [!TIP]
> 激活码的有效期
>
> eSIM 激活码在**未被写入任何设备之前**是永久有效的。你可以隔天、隔周甚至隔月再写入，不需要急着操作。但一旦写入一台设备就不能再写入另一台（一码一用）。

<a id="use-esim"></a>

## 9. 使用激活码（写入实体卡 / 原生设备）

拿到激活码后，模拟器的使命完成。根据你的设备情况选择写入方式：

> [!NOTE]
> eSIM 不需要额外激活
>
> 实体 SIM 卡买到手是未激活状态，需要去官网走 Activate your SIM 流程。但 **eSIM 不同**——在模拟器中购买并获取激活码的过程中，giffgaff 已经完成了号码分配和账户绑定。激活码写入转换卡（或原生设备）后，插入手机搜到信号即可直接使用，**不需要再走任何激活流程**。

方案 A：原生 eSIM 设备

适用于支持 eSIM 的手机/平板（海外版 iPhone、Pixel、Samsung 等）。

- 设置 → 蜂窝网络 → 添加 eSIM
- 选择「手动输入」
- 粘贴激活码（不含 `LPA:` 前缀，部分设备需要）
- 等待下载并激活

**优点：**原生体验，无需额外硬件<br>
**限制：**国行 iPhone 不支持 eSIM

方案 B：XeSIM / 9eSIM 转换卡（推荐）

适用于**国行手机**（不支持 eSIM）。将 eSIM 配置写入可编程的 nano-SIM 转换卡。

| 产品 | 价格 | 特点 |
| --- | --- | --- |
| **XeSIM** | ~¥99-149 | 官网 xesim.cc，附带写卡 App |
| **eSTK 白卡** | ~¥24 + 读卡器 ¥25 | 开源方案，性价比最高 |
| **9eSIM** | ~¥85-133 | 容量从入门到旗舰 |

**操作：**

1. 在转换卡配套 App（或电脑软件 MiniLPA/EasyLPAC）中输入激活码
2. 注意加上 `LPA:` 前缀（部分工具需要手动输入）
3. 写入成功后，转换卡插入手机卡槽
4. 手机识别为 Giffgaff SIM 卡 → 可正常收短信和接电话

> [!NOTE]
> 写入转换卡时的注意事项
>
> - 激活码格式通常为 `LPA:1$server$code`，有些工具要求手动输入 `LPA:` 前缀
> - XeSIM 的老版本 App 可以直接粘贴完整激活码；新版本可能需要扫码，此时把激活码生成二维码再扫
> - 写入过程需要联网（卡会向运营商服务器验证配置文件）
> - 写入后等待 1-5 分钟，手机信号栏出现 `giffgaff` 或 `O2-UK` 标识即成功

### 写入后的使用

- 转换卡插入手机后就是一张**真实的英国 SIM 卡**，支持收发短信、接打电话
- 在国内可以正常收短信（国际漫游），用于接收各种验证码
- 不需要额外的 App 或网络连接，短信走运营商蜂窝信号
- 换手机时拔出转换卡插入新手机即可

### Giffgaff 保号

Giffgaff 的保号政策比较宽松：

| 规则 | 说明 |
| --- | --- |
| 回收周期 | 连续 **6 个月**无任何活动（无充值、无通话、无短信、无流量使用），号码可能被回收 |
| 保号方法 | 每 6 个月内**发一条短信**或**打一个电话**即可（有余额的情况下） |
| 最低成本 | £10 credit 可以用很久（发一条短信几便士） |
| Goodybag 自动续费 | 如果订了月包且绑了支付方式，每月自动扣费 = 自动保号 |

> [!TIP]
> 保号建议
>
> 开通时充值的 £10 credit 足够保号很长时间。每隔几个月用这个号码发一条短信（随便发到任何号码）就行。设个日历提醒，半年操作一次。<br>
> **进阶：开启 WiFi Calling 后发短信仅 £0.08/条**（漫游价 £0.30），£10 可发 125 条，理论保号 62 年。详见[第 12 章](#wifi-calling)。

<a id="troubleshooting"></a>

## 10. 常见问题排查

| 问题 | 原因 | 解决方案 |
| --- | --- | --- |
| **Kitsune Mask 打开后没有弹出 Root 请求** | MuMu 模拟器未开启 Root | MuMu 设置 → 其他设置 → 开启 Root → 重启模拟器 |
| **LSPosed 安装后找不到图标** | LSPosed 默认隐藏入口 | 下拉通知栏找 LSPosed 通知；或拨号盘输入 `*#*#5776733#*#*` |
| **LSPosed 中看不到 HookEuicc 模块** | HookEuicc 未正确安装 | 确认 HookEuicc APK 已安装成功（应用列表中能看到）→ 重新打开 LSPosed 模块页 |
| **HookEuicc 已启用但 Giffgaff 仍检测不到 eSIM** | 作用域配置错误 / 未重启 | ① 确认 LSPosed 中 HookEuicc 的作用域勾选了 **System Framework**<br>② 确认已**重启模拟器**<br>③ 尝试 HookEuicc v2.0.0 版本 |
| **Giffgaff App 打不开 / 闪退** | 网络问题或 APK 版本不兼容 | 确认模拟器能访问外网（需代理）；尝试从 APKPure 下载不同版本 |
| **支付失败** | 信用卡被拒 | 尝试不同的信用卡/虚拟卡；部分卡可能因为是海外交易被银行拦截，致电银行放行 |
| **激活码弹窗一闪而过** | 系统自动关闭了分享框 | 提前开启模拟器录屏功能；或在 Giffgaff 账户页面找 eSIM 详情，有些可以重新查看激活码 |
| **激活码写入转换卡失败** | 网络问题 / 激活码已被使用 | 确认写卡设备联网畅通；一个激活码只能写入一次——如果之前已成功写入另一台设备，不能复用 |
| **写入后手机无信号** | 转换卡未启用 / 需要等待 | 写卡软件中确认该号码状态为 Enabled；插入手机后等待 3-5 分钟；尝试开关飞行模式 |

### 排查思路速查

```text
Giffgaff 检测不到 eSIM？
    │
    ├── Kitsune Mask 状态正常？ → 不正常 → 重装 Kitsune Mask + 重启
    │
    ├── Zygisk 已启用？ → 未启用 → Kitsune Mask 设置开启 Zygisk + 重启
    │
    ├── LSPosed 管理器能打开？ → 不能 → 重装 LSPosed ZIP + 重启
    │
    ├── HookEuicc 在 LSPosed 中已启用？ → 未启用 → 启用 + 配置作用域 + 重启
    │
    ├── 作用域含 System Framework？ → 没有 → 勾选 System Framework + 重启
    │
    └── 以上都正常？ → 检查 HookEuicc 版本（换 v2.0.0）+ 检查 Giffgaff APK 版本
```

<a id="usage-pitfalls"></a>

## 11. 日常使用防扣费指南

转换卡写好后，**插卡的瞬间**系统就会自动执行一系列操作（发送激活短信、注册运营商、同步数据等），每一项都可能产生国际漫游费用。核心原则：**先设置，再插卡；先关闭，再开启。**

> [!CAUTION]
> 漫游资费概览（在中国大陆使用 Giffgaff）
>
> | 项目 | 费用 | 说明 |
> | --- | --- | --- |
> | **接收短信** | 免费 | 全球漫游免费接收，这是 Giffgaff 最大的优点 |
> | **发送短信** | £0.30/条 | 保号发一条即可，不要误触回复 |
> | **接听/拨打电话** | £1.00/分钟 | 包括转入语音信箱的通话（前 30 秒后按秒计费） |
> | **移动数据** | £0.20/MB（≈¥2/MB） | £10 余额只撑约 50MB，极易烧完 |
>
> **Goodybag 月包套餐的通话/短信/流量额度在国内漫游时完全无效**，所有消耗都从 Credit 余额中按量扣除。
>
> 信源：[giffgaff 社区 — Turkey call charges](https://community.giffgaff.com/d/34591735-34591735-turkey-call-charges)（官方版主确认非欧盟漫游资费：Data 20p/MB, Calls & voicemail £1/min）

### iPhone 特有陷阱

#### 1. iMessage / FaceTime 激活短信 — 每次 £0.30

iPhone 插入新 SIM 卡后会弹窗询问是否激活 iMessage 和 FaceTime。一旦点击确认，苹果后台会**自动发送一条国际短信**到苹果服务器。如果网络不稳导致激活失败，手机会**反复重试**，每次都扣 £0.30。

> [!CAUTION]
> 隐蔽陷阱：「Turn on iCloud?」弹窗也会触发激活短信
>
> 不只是插卡——在装有 Giffgaff 卡的 iPhone 上**登录 Apple ID / iCloud / 切换账号**时，系统会弹出一个确认框，根据系统语言不同显示为：
>
> **英文系统：**<br>
> "Turn on iCloud?"<br>
> "Your network provider may charge for SMS messages used to activate iCloud."<br>
>
> **中文系统：**<br>
> 「打开 iCloud？」<br>
> 「你的网络服务提供商可能会对用于激活 iCloud 的短信收取费用。」
>
> **这个弹窗极具误导性**——标题只说「iCloud」，完全没有提到 iMessage 或 FaceTime，让人以为只是普通的云服务同步。但实际上点击确认后，系统发送的正是 **iMessage/FaceTime 激活短信**（它们属于 iCloud 服务的一部分），漫游状态下**必然扣费 £0.30**。「may charge」/「可能会」的措辞也很轻描淡写，实际在漫游下不是「可能」，是「一定」。
>
> 以下操作都可能触发这个弹窗或直接触发激活短信：
>
> - **登录 / 切换 Apple ID**
> - **登录 iCloud**
> - **iOS 大版本更新后**（系统可能重新激活 iMessage/FaceTime）
> - **手动重新开启 iMessage / FaceTime 开关**
> - **eSIM 转移、SIM swap、更换卡槽**后系统识别到新 SIM

> [!WARNING]
> 操作
>
> **插卡之前**：设置 → 信息 → 关闭 iMessage；设置 → FaceTime → 关闭 FaceTime。
>
> **日常使用中**：在装有 Giffgaff 卡的 iPhone 上遇到任何「Turn on iCloud?」或「是否激活 iMessage / FaceTime」的弹窗，一律点**「Not Now」/「稍后」/「取消」**。
>
> **不需要关闭「查找我的 iPhone」**：该功能通过 iCloud 网络连接和蓝牙定位，不发短信，不会产生额外费用。需要关闭的只有 iMessage 和 FaceTime。

信源：<br>
· [@ArthurMorganMAG — giffgaff 实体卡教程](https://x.com/ArthurMorganMAG/article/2054159765723623584)（「苹果手机：请提前关闭 iMessage 和 FaceTime 功能，以防止系统自动发出国际短信」）<br>
· [@AI\_Jasonyu — Giffgaff 保姆级教程](https://x.com/AI_Jasonyu/status/2068346487809970464)（「插卡后系统会自动发短信激活这些服务，扣费 0.3 英镑」）<br>
· 实测验证：在装有 Giffgaff eSIM 的港版 iPhone 上登录 iCloud，弹出「Turn on iCloud? Your network provider may charge for SMS messages used to activate iCloud.」提示并点击确认后，被扣除 £0.30（2026-07 实测）

### 小米/安卓 特有陷阱

#### 2. SIM 卡自动激活短信 — £0.30

MIUI / HyperOS 插入新 SIM 卡后，系统会**自动发送一条激活/注册短信**（到运营商或设备注册服务器），直接扣除 £0.30。「查找手机」等功能也可能触发额外短信发送。

> [!WARNING]
> 操作
>
> 插卡**之前**：设置 → 更多设置（或隐私保护）→ 关闭「自动发送诊断数据」；设置 → 关闭「查找手机」功能。

信源：[@ArthurMorganMAG — giffgaff 实体卡教程](https://x.com/ArthurMorganMAG/article/2054159765723623584)（「安卓手机：请提前在设置中关闭"查找位置"等功能，否则插卡后手机会自动发送一条短信，导致被直接扣除 0.3 英镑」）

#### 3. 后台 App 偷跑流量 — 最大的扣费黑洞

小米系统后台 App 活跃度高。如果 Giffgaff SIM 被选为默认数据卡，后台同步、推送、系统更新会瞬间消耗流量。按 £0.20/MB 计算，**几分钟就能烧掉全部 £10 余额**。

> [!WARNING]
> 操作（三步锁死流量）
>
> - 设置 → SIM 卡管理 → **默认移动数据指向国内主卡**
> - 设置 → 移动网络 → 选中 Giffgaff → **关闭「数据漫游」**
> - 设置 → 移动网络 → 流量管理 → 应用联网 → **关闭所有 App 对 Giffgaff 卡的移动数据权限**

信源：<br>
· [869hr.uk — 0月租 Giffgaff 保号助手](https://869hr.uk/2026/tech/0-card-giffgaff-03-20-free-200/)（小米流量管理细节：仅开启指定浏览器的移动数据权限）<br>
· [@AI\_Jasonyu](https://x.com/AI_Jasonyu/status/2068346487809970464)（「确保手机已连接 WiFi，避免插卡瞬间产生流量消耗」）

### 通用陷阱（iPhone & 小米都要注意）

#### 4. 语音信箱偷扣费 — £1.00/分钟

Giffgaff 的语音信箱**默认开启**。在国内有人拨打你的 Giffgaff 号码，如果你没接（或关机/无服务），来电会**自动转入语音信箱**，按漫游通话费率 £1/分钟扣费（前 30 秒后按秒计费），相当于你不知情时一直在漏钱。**对于在国内使用 Giffgaff 卡的用户来说，这是最大的隐形扣费来源**——必须在插卡后第一时间关闭。

> [!CAUTION]
> 漫游场景下的关闭方法（主要场景）
>
> 在国内或其他漫游地，**1626 / 1616 / ##002# 这类 USSD 指令往往无效**——它们需要通过英国本土网络发起，漫游网络不一定能正确转发。**最可靠的方式是联系 giffgaff 人工客服请求后台关闭**。以下方法按推荐顺序排列：

##### 方法 A：Giffgaff App 在线客服（最推荐）

这是漫游场景下最高效、最稳定的方式，全程走 WiFi 不消耗任何漫游费用。

1. **登录 Giffgaff App**（之前申请 eSIM 用的那个账户）
2. **进入 Help** → **Chat with us** → **Chat now**
    - 初始可能是 HelpBot（AI 机器人）应答
    - 输入英文关键词 `speak to agent` / `talk to an agent` / `disable voicemail` 触发转人工
3. **用英文向客服说明诉求**，参考模板：

    ```text
    Hi, I'm currently abroad and roaming charges apply.
    Could you please disable voicemail (901 / call divert to voicemail)
    on my number?

    Phone number: 07XXX XXX XXX
    Account email: xxx@xxx.com

    Thank you.
    ```

4. **客服会在后台关闭语音信箱转接**，通常 5-30 分钟内确认
5. **关闭后保留聊天记录截图**，以备日后核对

##### 方法 B：Web 端 Ask an Agent 表单

没装 App 或 App 无法登录时使用。同样走 WiFi，无任何漫游费。

1. **浏览器打开** [https://www.giffgaff.com/support/ask](https://www.giffgaff.com/support/ask)（会跳转到 `support2.giffgaff.com/app/ask`，需登录 giffgaff 账户）
2. **选择问题分类**：`International / Roaming` 或 `Account / Other`（按页面提示选最接近的一项）
3. **提交问题内容**，参考模板（同上方法 A）
4. **查看回复**：

    - App 内：**Help → Messages from us → Inbox**
    - 网页端：客服文章页头部/底部点击 **View agent messages**

    客服回复通常需要 24-48 小时（比 App 在线客服慢，所以优先用方法 A）

##### 方法 C：社区发帖求助（备用）

极少数情况下，App 和 Web 客服都不通时可尝试。**注意：公开发帖不要贴完整手机号**，只描述诉求即可，让版主（Mod）私信你处理。

1. 访问 [community.giffgaff.com](https://community.giffgaff.com/)，登录账户
2. 发新帖：标题 `Request to disable voicemail (roaming abroad)`，正文说明在国外漫游、希望关闭语音信箱以避免 £1/分钟扣费
3. 等 giffgaff 版主回帖或私信收集你的号码后台处理

> [!NOTE]
> 联系客服的注意事项
>
> - **明确说明在漫游**：客服默认会建议你拨 1626，但这在漫游下不一定生效，提前说清楚可以省去来回沟通
> - **请求关闭范围**：说清楚要关闭的是「voicemail diversion」（来电转语音信箱），保留接收短信和能主动拨打电话的能力
> - **用英文沟通**：giffgaff 客服仅英文支持
> - **验证是否真的关掉了**：让朋友用另一个号码拨你的 Giffgaff 号码，听到「该用户无法接通」等提示而**不是转语音信箱提示音**即为成功

#### 📞 可选：英国本地（或 WiFi Calling 连英国 IP）的自助关闭方法

如果你人在英国，或在国内开启了 WiFi Calling 并连接英国节点（详见[第 12 章](#wifi-calling)），可以自助拨打以下号码关闭：

| 号码 | 作用 |
| --- | --- |
| `1626` | 关闭语音信箱（听到确认语音后挂断） |
| `1616` | 重新开启语音信箱 |
| `##002#` | GSM 标准指令：取消所有呼叫转移（含语音信箱）。拨号盘输入后按拨出键 |

在漫游下尝试这些指令通常无效或不稳定，不要把这些作为主要方案。如果确实想试，先把手机连上英国 IP 的 WiFi 并开启 WiFi Calling，让通话走 VoWiFi 隧道再拨。

信源：<br>
· [giffgaff 社区 — Request to disable voicemail to avoid roaming charges](https://community.giffgaff.com/d/34591026-34591026-request-to-disable-voicemail-to-avoid-roaming-charges)（漫游场景下需联系客服后台关闭）<br>
· [giffgaff 官方 — How to get help with giffgaff](https://help.giffgaff.com/en/articles/258945-how-to-get-help-with-giffgaff)（App「Help → Chat with us → Chat now」与 Web「giffgaff.com/support/ask」两个客服入口）<br>
· [giffgaff 社区 — How to block incoming calls, only keep SMS](https://community.giffgaff.com/d/34591816-34591816-how-to-block-incoming-calls-only-keep-sms-for-number-keep)（「Turn off voicemail: Dial 1626 and press Call」）<br>
· [giffgaff 社区 — mailbox](https://community.giffgaff.com/d/34591110-34591110-mailbox)（「1616 to turn it on; 1626 to turn it off」）<br>
· [giffgaff 社区 — Turkey call charges](https://community.giffgaff.com/d/34591735-34591735-turkey-call-charges)（「Calls & voicemail £1 per minute」官方版主确认非欧盟漫游资费）

#### 5. Goodybag 套餐流量在国内无效

即使购买了大流量 Goodybag 月包，在中国漫游时**套餐额度完全不生效**。所有通话/短信/流量消耗都从 Credit 余额中按上述漫游资费扣除，套餐仅在英国本土有效。

信源：[@AI\_Jasonyu — Giffgaff 保姆级教程](https://x.com/AI_Jasonyu/status/2068346487809970464)（「套餐流量在国内完全无效，在中国漫游必须使用 Credit 余额扣费」）

#### 6. 插卡瞬间的流量消耗

插卡前确保手机已连接 WiFi。部分系统在识别新 SIM 卡时会立即尝试联网验证运营商配置，走蜂窝数据就是漫游流量。

信源：[@AI\_Jasonyu — Giffgaff 保姆级教程](https://x.com/AI_Jasonyu/status/2068346487809970464)（「确保手机已连接 WiFi，避免插卡瞬间产生流量消耗」）

### 插卡操作 Checklist

| 顺序 | 操作 | 适用设备 |
| --- | --- | --- |
| 1 | 连接 WiFi | 通用 |
| 2 | 关闭 iMessage + FaceTime | iPhone |
| 3 | 关闭「查找手机」/ 诊断数据自动发送 | 小米/安卓 |
| 4 | 插入转换卡 | 通用 |
| 5 | 弹窗全部点**取消/拒绝** | 通用 |
| 6 | 默认移动数据指向国内主卡 | 通用 |
| 7 | 关闭 Giffgaff 卡的数据漫游 | 通用 |
| 8 | 联系 Giffgaff App 在线客服关闭语音信箱（漫游下首选；英国本地可拨 `1626` / `##002#`） | 通用 |
| 9 | 流量管理 → 关闭所有 App 对 Giffgaff 的数据权限 | 小米/安卓 |

> [!TIP]
> 按此操作后的预期
>
> Giffgaff 卡仅用于**被动接收短信**（免费）和偶尔保号发短信（£0.30/条）。£10 初始余额可以用很久——每 6 个月发一条短信保号，每次 £0.30，理论上可以保号 30+ 次。

<a id="wifi-calling"></a>

## 12. WiFi Calling 开启与省钱指南

Giffgaff（O2 网络）支持 WiFi Calling（VoWiFi）。开启后通话和短信走 WiFi 网络隧道，运营商视为英国本土使用，资费大幅降低。

### WiFi Calling vs 蜂窝漫游资费对比

| 项目 | 蜂窝漫游（默认） | WiFi Calling | 节省 |
| --- | --- | --- | --- |
| **发送短信** | £0.30/条 | **£0.08/条** | 73% |
| **打电话** | £1.00/分钟 | **£0.03/分钟** | 97% |
| **接收短信** | 免费 | 免费 | — |
| **£10 可发短信** | 33 条 | **125 条** | 保号 62 年 vs 16 年 |

> [!NOTE]
> 原理
>
> WiFi Calling 通过英国 IP 与 O2 的 ePDG 服务器建立加密 IPsec 隧道，所有短信和通话走隧道传输。O2 将其视为英国本土用户，因此按英国国内资费计费（£0.08/条短信、£0.03/分钟通话），而非国际漫游资费。

### 前置条件

| 条件 | 说明 |
| --- | --- |
| **英国 IP 网络** | 手机连接的 WiFi 必须出口为英国 IP。O2 ePDG 服务器可能校验来源 IP 地区 |
| **全局代理** | 需要全局代理（不是仅浏览器代理），WiFi Calling 是系统级连接 |
| **支持的设备** | iPhone XS 及以上、部分 Android 设备（需运营商白名单匹配） |

> [!WARNING]
> WiFi Calling 是实时连接，不是一次性开关
>
> 每次使用时手机都需要连着英国 IP 的 WiFi 才能建立 VoWiFi 隧道。隧道断开（WiFi 断、IP 切换、手机重启）后退回蜂窝漫游资费。保号发短信时临时挂英国节点即可，不需要常驻。

### iPhone 开启步骤

1. **连接英国 IP 的 WiFi**<br>
    路由器挂英国代理节点，或手机全局 VPN 连英国服务器
2. **开启 VoLTE**<br>
    设置 → 蜂窝网络 → 点击 Giffgaff 号码 → 语音与数据 → 选择 **4G** 或 **5G**
3. **开启 WiFi 通话**<br>
    设置 → App → 电话 → 打开「**Wi-Fi 通话**」
4. **确认生效**<br>
    状态栏信号旁出现 `WiFi` 标识，或显示 `giffgaff WiFi`，即表示 WiFi Calling 已连接

### 小米 / 安卓手机开启步骤

1. **连接英国 IP 的 WiFi**<br>
    和 iPhone 相同，需要全局英国代理
2. **开启 VoLTE**<br>
    设置 → SIM 卡与移动网络 → 选择 Giffgaff 卡 → 开启「**VoLTE 高清通话**」
3. **开启 WiFi Calling**<br>
    设置 → SIM 卡与移动网络 → 选择 Giffgaff 卡 → 开启「**WiFi 通话**」（或「WLAN 通话」）

    > [!WARNING]
    > 小米找不到 WiFi 通话选项？
    >
    > 国行小米/红米可能隐藏了 WiFi Calling 开关（运营商白名单限制）。尝试以下方法：
    >
    > - 拨号盘输入 `*#*#869434#*#*`（解除运营商检查限制，HyperOS 适用）
    > - 重置网络设置：设置 → 更多设置 → 重置 → 重置网络设置（会清除 WiFi 密码，注意备份）
    > - 确认系统已更新到最新 HyperOS / MIUI 版本

4. **确认生效**<br>
    通知栏或信号栏出现 WiFi Calling 图标

> [!CAUTION]
> eSTK 转换卡的 WiFi Calling 兼容性
>
> WiFi Calling 在原生 eSIM 设备上最可靠。eSTK / 9eSIM 等转换卡是否能正常触发 WiFi Calling **需要实测**——部分手机可能无法通过转换卡建立 VoWiFi 隧道。如果开启后状态栏没有 WiFi Calling 标识，说明不兼容，退回蜂窝漫游收短信即可（接收短信仍然免费）。

### 保号省钱操作流程

每 6 个月保号时，按以下步骤操作可用 £0.08 而非 £0.30 发短信：

1. **手机连 WiFi + 开英国代理**（全局模式）
2. **确认状态栏显示 WiFi Calling 已连接**
3. **发一条短信**（随便发到任何号码，£0.08）
4. **完成，关掉代理即可**

信源：<br>
· [@AI\_Jasonyu — 手把手教你激活充值 Giffgaff 英国 SIM 卡](https://x.com/AI_Jasonyu/article/2069761380274630997)<br>
· [@yaohui12138 — Giffgaff eSIM 教程](https://x.com/yaohui12138/status/2069984194676355580)<br>
· [Giffgaff 官方 — WiFi Calling and VoLTE](https://help.giffgaff.com/en/articles/258841-understanding-wifi-calling-and-volte)

## 附：Giffgaff 号码可以做什么

一个英国 Giffgaff 号码（+44 开头）的常见用途：

| 用途 | 说明 |
| --- | --- |
| **海外服务注册验证** | 接收需要非中国大陆号码的短信验证码（ChatGPT、Telegram、WhatsApp 等） |
| **两步验证 (2FA)** | 作为海外账号的备用 2FA 手机号 |
| **旅行通信** | 去英国/欧洲旅行时当本地号码用（EU 漫游包含） |
| **WhatsApp/Telegram** | 用英国号码注册，和国内号码隔离 |
| **虚拟号码替代** | 比 Google Voice 更稳定（GV 容易被回收且注册越来越难） |

> [!NOTE]
> Giffgaff vs Google Voice
>
> | 维度 | Giffgaff | Google Voice |
> | --- | --- | --- |
> | 号码归属 | 英国 +44 | 美国 +1 |
> | 保号难度 | 低（6 个月发一条短信） | 中（3 个月需活动，且政策常变） |
> | 获取难度 | 容易（模拟器即可） | 困难（需美国号码转入，门槛高） |
> | 实体卡方案 | eSIM → 转换卡，当真实 SIM 用 | 仅 App/网页，无实体卡 |
> | 接码可靠性 | 高（真实运营商号码） | 中（部分服务拒绝 VoIP 号码） |

整理于 2026 年 6 月 · 仅供个人学习与技术参考
