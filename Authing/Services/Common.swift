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
//    let openid = data["openid"]! as! String
    let unionid = data["unionid"]! as! String
    let phone = data["phone"]! as! String
    let token = data["token"]! as! String
    userInfo.avatar = avatar
    userInfo.nickname = nickname
//    userInfo.openid = openid
    userInfo.unionid = unionid
    userInfo.phone = phone
    userInfo.token = token
}
