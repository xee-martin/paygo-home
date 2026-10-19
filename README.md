> 独立仓库的备份范围及恢复说明见 [BACKUP.md](BACKUP.md)。

# PayGo 官网首页

这是 PayGo 的独立静态官网首页，仅包含 HTML 和 CSS，不依赖 npm、前端框架或第三方脚本。

## 本地预览

进入本目录后使用任意静态文件服务器即可，例如：

```bash
python3 -m http.server 8080
```

浏览器打开 `http://localhost:8080`。也可直接打开 `index.html` 查看页面结构；通过 HTTP 服务预览时更接近生产环境的链接行为。

## 域名

- 官网首页：`https://www.paygo2.uk`
- 对接文档：`https://www.paygo2.uk/docs`
- 用户后台：`https://app.paygo2.uk`
- API：`https://api.paygo2.uk`
- WebSocket：`wss://ws.paygo2.uk`

本目录承载官网首页和公开开发文档。文档是静态文件：`docs/index.html` 可在未登录状态访问；`/docs/?lang=zh`、`/docs/?lang=zh-TW`、`/docs/?lang=en` 分别选择简体、繁体、英文。用户后台、API 与 WebSocket 由各自服务部署。

## Nginx 部署建议

将静态文件部署到例如 `/var/www/paygo-home`，并将 `www.paygo2.uk` 的 Nginx `root` 指向该目录：

```nginx
server {
    server_name www.paygo2.uk;
    root /var/www/paygo-home;
    index index.html;

    # 文档必须是实际静态文件；不能将未知 /docs 路径伪回退成首页 200。
    location = /docs { return 301 /docs/; }
    location ^~ /docs/ { try_files $uri $uri/ =404; }
    location / { try_files $uri $uri/ /index.html; }
}
```

部署时保留 `docs/` 和 `assets/docs.css` 的相对目录结构。上述配置支持 `/docs`、`/docs/` 及文档目录内的静态深链接，并让不存在的文档路径明确返回 404。

浏览器 SDK 由后台前端提供：`https://app.paygo2.uk/sdk/paygo.js`。它请求 `https://api.paygo2.uk` 的支付 API；不要将 SDK 地址放在官网文档域名或 API 域名。

## Apifox 下单测试

已创建私有项目 [PayGo 下单测试](https://app.apifox.com/project/8934328)，项目 ID 为 `8934328`。

1. 选择「PayGo API（填写本地凭据）」环境，在**本地值**填写 `PAYGO_PID`、`PAYGO_SECRET`、`PAYGO_ORIGIN`。Origin 必须已加入商户 Browser SDK 白名单，不包含路径。
2. 打开「创建支付订单（自动签名）」下的「下单测试（修改订单号或金额即可）」用例，按需修改 JSON Body 中的订单号、金额、商品名、支付方式及返回地址。
3. 发送前自动刷新时间戳和 nonce，并使用 RFC 3986 编码计算 HMAC-SHA256。连续创建新订单或更改金额时使用新订单号，金额等字段保持字符串。

完整请求地址：`POST https://api.paygo2.uk/api/v1/paygo/checkout/sessions`。用例自动携带 Origin 和 JSON Content-Type；Webhook 地址在商户后台配置。

前置脚本源码保存在 `docs/apifox-pre-request.js`，与项目已保存用例一致。不要将实际 SECRET 写入此文件、请求正文、共享值或仓库。私有项目链接只对有权限的 Apifox 账号开放。
