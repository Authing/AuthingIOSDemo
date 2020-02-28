//
//  QRCode.swift
//  Authing
//
//  Created by 廖长江 on 2020/2/28.
//  Copyright © 2020 steamory. All rights reserved.
//

import Foundation
import Alamofire

func markScanned(qrcodeId: String) {
    let api = "\(AuthingServerHost)/oauth/scan-qrcode/scanned"
    let headers: HTTPHeaders = [
        "Authorization": userInfo.token,
        "Accept": "application/json"
    ]
    struct Body: Encodable {
        let qrcodeId: String
    }
    let body = Body(qrcodeId: qrcodeId)
    AF.request(
        api,
        method: .post,
        parameters: body,
        headers: headers
    ).responseString { response in
        
        // 将 response.value 转化成字符串，示例如下：
        // ["code": 200, "message": "二维码扫描确认成功", data: "" ]
        let resp = convertToDictionary(text: response.value!)!
        let code = resp["code"] as! Int
        if code != 200 {
            debugPrint("确认扫码失败: ", resp)
        }
    }
}

func confirmQRLogin(qrcodeId: String) {
    let api = "\(AuthingServerHost)/oauth/scan-qrcode/confirm"
    let headers: HTTPHeaders = [
        "Authorization": userInfo.token,
        "Accept": "application/json"
    ]
    struct Body: Encodable {
        let qrcodeId: String
    }
    let body = Body(qrcodeId: qrcodeId)
    AF.request(
        api,
        method: .post,
        parameters: body,
        headers: headers
    ).responseString { response in
        
        // 将 response.value 转化成字符串，示例如下：
        // ["code": 200, "message": "二维码扫描确认成功", data: "" ]
        let resp = convertToDictionary(text: response.value!)!
        let code = resp["code"] as! Int
        if code != 200 {
            debugPrint("确认授权失败: ", resp)
        }
    }
}


func cancelQRLogin(qrcodeId: String) {
    let api = "\(AuthingServerHost)/oauth/scan-qrcode/cancel"
    let headers: HTTPHeaders = [
        "Authorization": userInfo.token,
        "Accept": "application/json"
    ]
    struct Body: Encodable {
        let qrcodeId: String
    }
    let body = Body(qrcodeId: qrcodeId)
    AF.request(
        api,
        method: .post,
        parameters: body,
        headers: headers
    ).responseString { response in
        
        // 将 response.value 转化成字符串，示例如下：
        // ["code": 200, "message": "二维码扫描确认成功", data: "" ]
        let resp = convertToDictionary(text: response.value!)!
        let code = resp["code"] as! Int
        if code != 200 {
            debugPrint("确认授权失败: ", resp)
        }
    }
}
