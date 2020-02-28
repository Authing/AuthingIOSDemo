//
//  Wechat.swift
//  Authing
//
//  Created by 廖长江 on 2020/2/28.
//  Copyright © 2020 steamory. All rights reserved.
//

import Foundation

func loginByWechat() {
    let req = SendAuthReq()
    req.scope = "snsapi_userinfo" //获取用户信息
    req.state = "123" //随机值即可，这里用时间戳
    WXApi.send(req)
}

func loginByMiniProgram() {
    let req = WXLaunchMiniProgramReq()
    req.userName = MiniProgramUsername
    req.path = "/routes/explore?userPoolId=\(UserPoolId)&getPhone=\(GetPhone ? "1" : "0")&fromApp=1"
    req.miniProgramType = MiniProgramType
    WXApi.send(req)
}
