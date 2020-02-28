//
//  ContentView.swift
//  Authing
//
//  Created by 廖长江 on 2020/2/24.
//  Copyright © 2020 steamory. All rights reserved.
//

import SwiftUI
import Combine


struct ContentView: View {
    
    @State private var remoteImage : UIImage? = nil
    @State private var showScanQRCode: Bool = false
    @State private var showAlert = false
    @State private var alertMsg = ""
    @EnvironmentObject var userInfo: UserInfo
    
    var body: some View {
         
        NavigationView {
            VStack {
                
                if self.showScanQRCode {
                    VStack {
                        CarBode(supportBarcode: [.qr, .code128]) //Set type of barcode you want to scan
                        .interval(delay: 5.0) //Event will trigger every 5 seconds
                           .found{
                                //Your..Code..Here
                            self.showScanQRCode = false
                            let data = convertToDictionary(text: $0)!
                            let qrcodeId = data["qrcodeId"] as! String
                            let userPoolId = data["userPoolId"] as! String
                            
                            // 检查是不是y同一个用户池下的二维码
                            if (userPoolId != UserPoolId) {
                                self.showAlert = true
                                self.alertMsg = "二维码错误！"
                                return
                            }
                            
                            markScanned(qrcodeId: qrcodeId)
                          }
                    }
                }

                VStack {
                    ImageView(withURL: self.userInfo.avatar)
                    Text(self.userInfo.nickname)
                    if self.userInfo.openid != "" {
                        Text("openid: " + self.userInfo.openid)
                    }
                    if self.userInfo.unionid != "" {
                        Text("unionid: " + self.userInfo.unionid)
                    }
                    if self.userInfo.phone != "" {
                        Text("phone: " + self.userInfo.phone)
                    }
                }
                
                HStack {
                    VStack {
                        Image("wechat")
                        .resizable()
                        .frame(width: 50.0, height: 50)
                        .scaledToFill()
                        Button(action: {
                            // your action here
                            let req = SendAuthReq()
                            req.scope = "snsapi_userinfo" //获取用户信息
                            req.state = "123" //随机值即可，这里用时间戳
                            WXApi.send(req)
                            }) {
                            Text("微信登录")
                            }
                    }
                    
                    VStack {
                        Image("wechatapp")
                        .resizable()
                        .frame(width: 50.0, height: 50)
                        .scaledToFill()
                        Button(action: {
                            let req = WXLaunchMiniProgramReq()
                            req.userName = MiniProgramUsername
                            req.path = "/routes/explore?userPoolId=\(UserPoolId)&getPhone=\(GetPhone ? "1" : "0")&fromApp=1"
                            req.miniProgramType = MiniProgramType
                            WXApi.send(req)
                        }) {
                            Text("小程序登录")
                        }
                    }
                    
                    VStack {
                        Image("alipay")
                        .resizable()
                        .frame(width: 50.0, height: 50)
                        .scaledToFill()
                        Button(action: {
                            loginByAlipay()
                        }) {
                            Text("支付宝登录")
                        }
                    }
                    
                    VStack {
                        Image("qrcode")
                        .resizable()
                        .frame(width: 55.0, height: 55)
                        .scaledToFill()
                        Button(action: {
                            
                            if self.userInfo.token == "" {
                                self.showAlert = true
                                self.alertMsg = "请先登录！"
                                return
                            } else {
                                self.showAlert = false
                            }
                            
                            self.showScanQRCode = !self.showScanQRCode
                        }) {
                            Text("App 扫码")
                        }.alert(isPresented: $showAlert) {
                            Alert(title: Text("提示"), message: Text(self.alertMsg), dismissButton: .default(Text("知道了")))
                        }
                    }
                }
            }.navigationBarTitle(Text("Authing 移动端登录"))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
