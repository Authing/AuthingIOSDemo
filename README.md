# Authing 移动端登录示例

<img src="https://cdn.authing.cn/blog/20200229192013.png" height="600px" align="center">

目前支持的移动端登录方式共包括以下这些：

- 移动应用微信登录
- 移动应用支付宝登录
- APP 拉起小程序登录
- App 扫码登录

> 移动应用小程序登录指的是在移动 App 借助[微信开放能力](https://developers.weixin.qq.com/doc/oplatform/Mobile_App/Launching_a_Mini_Program/Launching_a_Mini_Program.html)，唤起微信小程序「小登录」，获取用户微信授权进行登录。**此方法可以获取到用户手机号。** 你可以点击查看此 [Live Demo](https://cdn.authing.cn/docs/1582853403868656.mp4).

小登录是 Authing 开发的小程序，可以让开发者快速实现免短信验证码登录！快速建立标准化、企业级用户后台！告别支付庞大短信费用，简化开发步骤！详情请见 [https://wxapp.authing.cn/](https://wxapp.authing.cn/) 。

## 示例 Demo

- [微信登录示例.mp4](https://cdn.authing.cn/%E5%BE%AE%E4%BF%A1%E7%99%BB%E5%BD%95.MP4)
- [支付宝登录示例.mp4](https://cdn.authing.cn/%E6%94%AF%E4%BB%98%E5%AE%9D%E7%99%BB%E5%BD%95.MP4)
- [App 拉起小程序登录.mp4](https://cdn.authing.cn/%E5%B0%8F%E7%A8%8B%E5%BA%8F%E7%99%BB%E5%BD%95.MP4)
- [App 扫码登录.mp4](https://cdn.authing.cn/App%E6%89%AB%E7%A0%81%E7%99%BB%E5%BD%95.MP4)

## 接入流程

运行项目之前需要先完成一些准备工作，详情请见：

- [接入移动应用微信登录](https://docs.authing.cn/authing/social-login/mobile/wechat-mobile)
- [接入移动应用支付宝登录](https://docs.authing.cn/authing/social-login/mobile/alipay)
- [接入 APP 拉起小程序登录](https://docs.authing.cn/authing/social-login/miniprogram/app2wxapp)
- [接入 App 扫码登录](https://docs.authing.cn/authing/scan-qrcode/app-qrcode)


## 运行项目

### 开发环境

- Swift 5.1.3
- Xcode 11.3
- SwiftUI
- SDK版本: SDK1.8.6 或以上
- 微信版本: 7.0.7 或以上
- iOS 系统版本: iOS12 或以上


### 安装项目依赖

```
pod install
```

### 替换项目证书

请将此 Bundle ID 替换成自己的：

![](https://cdn.authing.cn/blog/20200229185718.png)


### 修改配置文件

请修改 Configs.swift 文件中的配置

![](https://cdn.authing.cn/blog/20200229185827.png)

- UserPoolId: 你的用户池 ID。
- MiniProgramUsername: 小登录的 username, 如果你不需要私有化部署，请不要修改。
- GetPhone: App 拉起小登录是否需要获取手机号
- MiniProgramType: 小程序类型，请不要修改。
- WechatAppId: 微信移动应用 AppID，请替换成自己的。
- WechatUniversalLink: 你设置的 iOS Universal Link，配置详情请见[此](https://docs.authing.cn/authing/social-login/mobile/wechat-mobile)。
- AlipayURLSchema: 任意字符串（最好能确保唯一），需要和 URL Types 中配置的 URL Schema 保存一致：

![](https://cdn.authing.cn/blog/20200229190253.png)

## APP 扫码登录 Web 端 Demo

详细文档以及接口说明请见：[Authing - APP 扫码登录 Web](https://docs.authing.cn/authing/scan-qrcode/app-qrcode)

### 运行项目

```shell
$ npm install http-server -g
$ http-server ./examples 
```

然后打开浏览器扫码调试即可。

### 扫码登录代码简介

引入 Authing CDN：

```html
<script src="https://cdn.jsdelivr.net/npm/authing-js-sdk/dist/authing-js-sdk-browser.min.js"></script>
```

> 这里用到的 SDK 为 [authing-js-sdk](https://github.com/authing/authing.js)

初始化：

```javascript
const authing = new Authing({
  userPoolId: 'YOUR_USERPOOL_ID',
});
```

一键生成扫码登录表单：

```javascript
authing.qrlogin.startScanning({
  onSuccess(userInfo) {
    alert('扫码成功，请打开控制台查看用户信息')
    console.log(userInfo);
    // 存储 token 到 localStorage 中
    localStorage.setItem('token', userInfo.token);
  }
})
```

或者手动调用生成二维码、轮询二维码状态、换取用户信息：

```javascript
authing.qrlogin.geneCode({ scence: 'APP_AUTH' }).then(res => {
  if (res.code === 200) {
    const { qrcodeId, qrcodeUrl } = res.data
    $("#qrcode").attr('src', qrcodeUrl);
    $("#qrcode").show()
    authing.qrlogin.pollingCodeStatus({
      qrcodeId,
      scence: 'APP_AUTH',
      interval: 1000,
      onPollingStart: function (intervalNum) {
        console.log("Start polling for qrcode status: ", intervalNum)
        // clearInterval(intervalNum)
      },
      onResult: function (res) {
        console.log("Got qrcode latest result: ", res)
      },
      onScanned: function (userInfo) {
        console.log("User scanned qrcode: ", userInfo)
      },
      onSuccess: function (data) {
        const { ticket, userInfo } = data;
        console.log(`User confirmed authorization: ticket = ${ticket}`, userInfo)
        // 获取用户信息
        authing.qrlogin.exchangeUser(ticket).then(res => {
          const { code } = res
          if (code === 200) {
            console.log("Exchange userInfo success: ", res)
          } else {
            console.log("Exchange userInfo failed: ", res)
          }
        })
      },
      onCancel: function () {
        console.log("User canceled authorization")
      },
      onExpired: function () {
        console.log("QRCode has expired.")
      },
      onError: function (data) {
        console.log("Chcek qrcode status failed: ", data)
      }
    })
  }
})
```
