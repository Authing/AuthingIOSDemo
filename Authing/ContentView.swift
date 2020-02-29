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
    
    // 扫码相关状态
    @State private var qrcodeId = ""
    @State private var showScanQRCode: Bool = false
    @State private var qrcodeScanned: Bool = false
    
    // alert msg
    @State private var showAlert = false
    @State private var alertMsg = ""

    @EnvironmentObject var userInfo: UserInfo
    
    var body: some View {

        NavigationView {
            
            if self.qrcodeScanned {
                VStack {
                    VStack {
                        Image("desktop")
                            .resizable()
                            .frame(width: 200.0, height: 200)
                            .scaledToFill()
                        Text("电脑端登录确认")
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(height: nil)
                            
                    }
                    
                    Spacer()
                    
                    VStack {
                        Button(action: {
                            confirmQRLogin(qrcodeId: self.qrcodeId)
                            self.qrcodeScanned = false
                        }) {
                            Text("登录")
                            }.frame(width: 200, height: 40).background(Color.green)
                        .foregroundColor(Color.white)
                        .padding(50)
                        
                        Button(action: {
                            cancelQRLogin(qrcodeId: self.qrcodeId)
                            self.qrcodeScanned = false
                        }) {
                            Text("取消登录")
                        }
                    }
                }
            } else {
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
                                self.qrcodeId = qrcodeId
                                markScanned(qrcodeId: qrcodeId)
                                self.qrcodeScanned = true
                              }
                        }
                    }

                    VStack {
                        if self.userInfo.avatar != "" {
                            ImageView(withURL: self.userInfo.avatar)
                                .cornerRadius(5)
                                .shadow(radius: 5)
                        }
                        if self.userInfo.nickname != "" {
                            Text(self.userInfo.nickname)
                        }
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
                                loginByWechat()
                                }) {
                                    Text("微信登录").foregroundColor(Color.black)
                                }
                        }
                        
                        VStack {
                            Image("wechatapp")
                            .resizable()
                            .frame(width: 50.0, height: 50)
                            .scaledToFill()
                            Button(action: {
                                loginByMiniProgram()
                            }) {
                                Text("小程序登录").foregroundColor(Color.black)
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
                                Text("支付宝登录").foregroundColor(Color.black)
                            }
                        }
                        
                        VStack {
                            Image("qrcode")
                            .resizable()
                            .frame(width: 50, height: 50)
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
                                Text("APP 扫码").foregroundColor(Color.black)
                            }.alert(isPresented: $showAlert) {
                                Alert(title: Text("提示"), message: Text(self.alertMsg), dismissButton: .default(Text("知道了")))
                            }
                        }
                    }
                }.navigationBarTitle(Text("Authing 移动端登录"))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(userInfo)
    }
}
