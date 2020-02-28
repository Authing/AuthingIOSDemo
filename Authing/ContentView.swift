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
    @EnvironmentObject var userInfo: UserInfo
    
    var body: some View {
         
        NavigationView {
            VStack {
                
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
                }
            }.navigationBarTitle(Text("Authing 社会化登录"))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
