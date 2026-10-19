// Apifox 前置脚本：SECRET 仅从当前环境的本地值读取。
const CryptoJS = require('crypto-js');
const secret = String(pm.environment.get('PAYGO_SECRET') || '').trim();
const pid = String(pm.environment.get('PAYGO_PID') || '').trim();
const origin = String(pm.environment.get('PAYGO_ORIGIN') || '').trim();
if (!secret || !pid || !origin || origin === 'https://merchant.example') {
  throw new Error('请先在环境本地值中填写 PAYGO_PID、PAYGO_SECRET 和已加入商户白名单的 PAYGO_ORIGIN');
}
const body = JSON.parse(pm.variables.replaceIn(pm.request.body.raw || '{}'));
body.pid = pid;
body.timestamp = String(Math.floor(Date.now() / 1000));
body.nonce = CryptoJS.lib.WordArray.random(16).toString(CryptoJS.enc.Hex);
const fields = ['amount', 'merchant_order_no', 'name', 'nonce', 'pid', 'return_url', 'timestamp', 'type'];
if (Object.prototype.hasOwnProperty.call(body, 'currency')) fields.push('currency');
fields.sort();
const encode = value => encodeURIComponent(value).replace(/[!'()*]/g, c => '%' + c.charCodeAt(0).toString(16).toUpperCase());
const canonical = fields.map(key => {
  if (typeof body[key] !== 'string' || !body[key].trim()) throw new Error(key + ' 必须是非空字符串');
  body[key] = body[key].trim();
  return key + '=' + encode(body[key]);
}).join('&');
body.sign = CryptoJS.HmacSHA256(canonical, secret).toString(CryptoJS.enc.Hex);
pm.request.headers.upsert({key: 'Origin', value: origin});
pm.request.headers.upsert({key: 'Content-Type', value: 'application/json'});
pm.request.body.update(JSON.stringify(body, null, 2));
