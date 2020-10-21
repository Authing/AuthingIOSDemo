//
//  Alipay.swift
//  Authing
//
//  Created by 廖长江 on 2020/2/28.
//  Copyright © 2020 steamory. All rights reserved.
//

import Foundation
import Alamofire

let GetAuthInfoUrl = "\(AuthingServerHost)/connection/social/alipay/\(UserPoolId)/authinfo"
let GetUserInfoUrl = "\(AuthingServerHost)/oauth/alipaymobile/redirect/\(UserPoolId)"

func loginByAlipay() {
    
    // 获取 authInfo
    AF.request(GetAuthInfoUrl).responseString { response in
        let resp = convertToDictionary(text: response.value!)!
        
        // Authing 业务状态码, 200 表示成功
        let code = resp["code"]! as! Int
        let message = resp["message"]! as! String
        if code == 200 {
            let authInfo = resp["data"]! as! String
            debugPrint("authInfo: \(authInfo)")
            
            // 打开支付宝
            AlipaySDK().auth_V2(withInfo: authInfo, fromScheme: "authing-alipay", callback: { resp in
                debugPrint(resp)
            })
        } else {
            debugPrint("Message: ", message)
        }
    }
}
