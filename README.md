# PayGo 官网与接口文档

PayGo 官网首页及公开开发文档的独立源码仓库。官网介绍产品能力和接入流程，接口文档提供下单参数、Browser SDK、请求返回、服务器回调、签名计算与错误码说明，帮助商户完成支付接入与联调。

项目使用 HTML、CSS 和原生 JavaScript，无需 npm 安装或构建。此仓库维护静态页面与接入示例。

## 域名

| 入口 | 链接 |
| --- | --- |
| 官网首页 | [https://www.paygo2.uk](https://www.paygo2.uk) |
| 对接文档 | [https://www.paygo2.uk/docs](https://www.paygo2.uk/docs) |

## 项目内容

- **官网首页**：产品介绍、收款方式、接入步骤及常见问题。
- **接口文档**：商户下单、收银台调用、支付结果确认、签名与联调说明。
- **多语言**：页面支持简体中文、繁体中文和英文。
- **Apifox 示例**：提供自动生成时间戳、nonce 与下单签名的前置脚本。

## 接口文档导览

| 章节 | 内容 |
| --- | --- |
| [快速开始](https://www.paygo2.uk/docs/#start) | 商户配置、服务端签名、收银台展示与支付确认流程 |
| [签名规则](https://www.paygo2.uk/docs/#sign) | 字段排序、RFC 3986 编码与 HMAC-SHA256 签名 |
| [Browser SDK](https://www.paygo2.uk/docs/#sdk) | `PayGo.mount()` 调用方式及浏览器事件回调 |
| [请求参数](https://www.paygo2.uk/docs/#parameters) | 下单接口、必填字段、字段格式与请求约束 |
| [请求返回参数](https://www.paygo2.uk/docs/#response) | 业务状态码、订单状态、金额、收银台与二维码字段 |
| [服务器回调参数](https://www.paygo2.uk/docs/#callbacks) | Webhook JSON 正文及签名请求头 |
| [签名计算](https://www.paygo2.uk/docs/#signature) | 下单签名与回调验签的完整示例 |
| [支付方式](https://www.paygo2.uk/docs/#methods) | 微信、支付宝及 TRON 网络支付通道 |
| [错误码](https://www.paygo2.uk/docs/#errors) | 身份、签名、Origin、重复请求及金额错误处理 |

文档语言入口：[简体中文](https://www.paygo2.uk/docs/?lang=zh) · [繁體中文](https://www.paygo2.uk/docs/?lang=zh-TW) · [English](https://www.paygo2.uk/docs/?lang=en)。

### 接入流程

1. 在商户后台配置收款方式、Webhook 地址和 Browser SDK 的 Origin 白名单，并获取商户 `PID` 与 `SECRET`。
2. 商户服务端根据真实订单生成下单字段、当前时间戳及新的随机 `nonce`，计算签名。
3. 浏览器接收服务端生成的签名参数，通过 `PayGo.mount()` 展示收银台。
4. 使用 SDK 回调更新页面中的支付状态。
5. 商户服务端接收 Webhook，验签并核对业务订单后，幂等处理发货或权益开通。

### 下单与支付确认要点

- 下单必填字段包括 `pid`、`merchant_order_no`、`amount`、`name`、`type`、`timestamp`、`nonce`、`sign` 和 `return_url`；完整定义见[请求参数](https://www.paygo2.uk/docs/#parameters)。
- 金额使用字符串，人民币订单最低为 `1.00`，最多两位小数。
- `timestamp` 为 Unix 秒级时间戳，有效窗口为 ±5 分钟；同一 `pid` 下的 `nonce` 只能使用一次。
- 签名字段按字典顺序排列，对值进行 RFC 3986 编码，使用 `SECRET` 计算 HMAC-SHA256，输出小写十六进制字符串。
- 下单响应应先检查业务字段 `code`；`code = 0` 表示请求成功，不能只判断 HTTP 状态码。
- 创建订单成功与订单支付成功是两个阶段；浏览器回调和支付返回页面仅用于界面展示，履约以服务端验签后的 Webhook 为依据。
- 回调验签必须保留原始请求正文。按文档使用时间戳、nonce 和正文的 SHA-256 摘要计算签名，按 `merchant_order_no` 幂等处理，成功处理后返回纯文本 `success`。

### 支付方式

| 参数值 | 支付方式 |
| --- | --- |
| `wechat` | 微信收款码 |
| `alipay` | 支付宝收款码 |
| `usdt.tron` | TRON 网络 USDT |
| `trx.tron` | TRON 网络 TRX |

实际可用通道取决于商户启用状态、有效订阅权益以及收款码或钱包配置。

## Apifox 下单联调

已有私有项目：[PayGo 下单测试](https://app.apifox.com/project/8934328)。需要具备该项目的访问权限。

1. 选择「PayGo API（填写本地凭据）」环境，在**本地值**填写 `PAYGO_PID`、`PAYGO_SECRET` 和 `PAYGO_ORIGIN`。
2. `PAYGO_ORIGIN` 应为已加入商户白名单的页面 Origin，不包含路径。
3. 打开「创建支付订单（自动签名）」中的「下单测试（修改订单号或金额即可）」用例，填写订单号、金额、商品名、支付方式及返回地址。
4. 发送前，前置脚本自动填入商户 PID、刷新时间戳与 nonce、计算签名，并设置 `Origin` 和 JSON 请求头。
5. 检查响应的业务状态码和订单字段；支付后结合 Webhook 验签结果确认完整流程。

前置脚本源码见 [docs/apifox-pre-request.js](docs/apifox-pre-request.js)。脚本要求签名字段为非空字符串；创建新订单或修改金额时，请使用新的商户订单号。Webhook 地址在商户后台配置。

## 目录结构

```text
.
├── index.html                 # 官网首页及多语言内容
├── assets/
│   ├── style.css              # 官网样式
│   └── docs.css               # 文档样式
├── docs/
│   ├── index.html             # 接口文档及多语言内容
│   └── apifox-pre-request.js   # Apifox 自动签名前置脚本
├── robots.txt                 # 搜索引擎抓取规则
├── sitemap.xml                # 站点地图
├── README.md                  # 项目说明与文档入口
├── BACKUP.md                  # 备份范围与恢复说明
├── AGENTS.md                  # 项目维护及 Git 账号规则
└── .githooks/                 # 提交身份与推送检查
```

## 维护说明

- 首页内容与交互在 `index.html` 中维护，文档内容与示例在 `docs/index.html` 中维护；修改文案时同步检查三种语言。
- 更新接口字段、签名或回调说明时，同时检查文档示例和 Apifox 前置脚本的一致性。
- 页面样式分别由 `assets/style.css` 和 `assets/docs.css` 管理，维护时保留资源的相对路径。
- `SECRET` 仅保存在商户服务端或联调工具的本地环境中，不得写入浏览器代码、共享值或 Git 仓库。文档中的演示密钥与固定参数只用于说明算法。
- 本仓库提交和推送统一使用 `xee-martin`。当前工作区已启用身份检查；新克隆需按 [AGENTS.md](AGENTS.md) 设置本地身份、独立认证并启用 hooks。
- 备份范围和恢复说明见 [BACKUP.md](BACKUP.md)。
