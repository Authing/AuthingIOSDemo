//
//  Common.swift
//  Authing
//
//  Created by 廖长江 on 2020/2/28.
//  Copyright © 2020 steamory. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Alamofire

func updateUserInfoEnvVariable(data: [String: Any]) {
    let nickname = data["nickname"]! as! String
    let avatar = data["photo"]! as! String
    let unionid = data["unionid"]! as! String
    let token = data["token"]! as! String
    userInfo.avatar = avatar
    userInfo.nickname = nickname
    userInfo.unionid = unionid
    
    userInfo.token = token

    let phone = data["phone"]!
    if (type(of: phone) != NSNull.self) {
        userInfo.phone = phone as! String
    } else {
        userInfo.phone = ""
    }
}


func createSession(token: String){
    // 移动端 SSO: createSession
    struct MobileSSO: Encodable {
        let userPoolId: String
        let deviceId: String
    }
    let body = MobileSSO(userPoolId: UserPoolId, deviceId: UIDevice.current.identifierForVendor!.uuidString)
    let headers: HTTPHeaders = [
        "Authorization": token ,
        "Accept": "application/json"
    ]
    let api = "\(AuthingServerHost)/oauth/sso/mobile/createSession"
    AF.request(api, method: .post, parameters: body, encoder: JSONParameterEncoder.default, headers: headers).response { response in
         debugPrint(response)
    }
}
