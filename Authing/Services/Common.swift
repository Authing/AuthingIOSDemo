//
//  Common.swift
//  Authing
//
//  Created by 廖长江 on 2020/2/28.
//  Copyright © 2020 steamory. All rights reserved.
//

import Foundation

func updateUserInfoEnvVariable(data: [String: Any]) {
    let nickname = data["nickname"]! as! String
    let avatar = data["photo"]! as! String
    let unionid = data["unionid"]! as! String
    let token = data["token"]! as! String
    userInfo.avatar = avatar
    userInfo.nickname = nickname
    userInfo.unionid = unionid
    
    userInfo.token = token
    
    let openid = data["openid"]
    if (openid != nil) {
        userInfo.openid = openid as! String
    } else {
        userInfo.openid = ""
    }
    
    let phone = data["phone"]!
    if (type(of: phone) != NSNull.self) {
        userInfo.phone = phone as! String
    } else {
        userInfo.phone = ""
    }
}
