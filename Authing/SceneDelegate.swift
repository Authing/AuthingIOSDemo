//
//  SceneDelegate.swift
//  Authing
//
//  Created by 廖长江 on 2020/2/24.
//  Copyright © 2020 steamory. All rights reserved.
//

import UIKit
import SwiftUI
import Alamofire

class SceneDelegate: UIResponder, UIWindowSceneDelegate, WXApiDelegate {

    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView().environmentObject(userInfo)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        WXApi.handleOpenUniversalLink(userActivity, delegate: self as! WXApiDelegate)
    }
    
    // schema 回调
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        let url = URLContexts.first?.url
        let schema = url!.scheme
        switch schema {
        case WechatAppId:
            WXApi.handleOpen(URLContexts.first!.url, delegate: self as! WXApiDelegate)
        case AlipayURLSchema:
            AlipaySDK().processAuth_V2Result(url, standbyCallback: { back in
                let response = back!
                let resultStatus = response["resultStatus"] as! String
                let memo = response["memo"]
                let result = response["result"] as! String
                
                let data = parseUrlQueryString(string: result)
                let success = data["success"]
                let result_code = data["result_code"] as! String
                let auth_code = data["auth_code"] as! String
                let user_id = data["user_id"] as! String
                
                if resultStatus == "9000" && result_code == "200" {
                    let url = "\(AuthingServerHost)/connection/social/alipay/\(UserPoolId)/callback?auth_code=\(auth_code)"
                    AF.request(url).responseString { response in
                        
                        // 将 response.value 转化成字符串，示例如下：
                        // ["code": "200", "message": "获取用户信息成功", data: "" ]
                        let resp = convertToDictionary(text: response.value!)!
                        
                        let data = resp["data"] as! [String: Any]
                        debugPrint("Data: \(data)")
                        
                        // 更新 EnvironmentObject 触发页面更新
                        updateUserInfoEnvVariable(data: data)
                        createSession(token: data["token"] as! String)
                    }
                }
            })
        default:
            debugPrint("???")
        }
    }

    func onReq(_ req: BaseReq) {
        print(req)
    }

    func onResp(_ resp: BaseResp) {
        
        debugPrint(resp)
        
        // 微信登录请求信息
        if resp.isKind(of: SendAuthResp.self) {
            if resp.errCode == 0 && resp.type == 0{
                let response = resp as! SendAuthResp
                
                // 微信 authorication_code
                let code = response.code
                debugPrint("code: " ,code)
                
                let url = "\(AuthingServerHost)/connection/social/wechat:mobile/\(UserPoolId)/callback?code=\(code!)"
                AF.request(url).responseString { response in
                    let resp = convertToDictionary(text: response.value!)!
                    
                    // Authing 业务状态码, 200 表示成功
                    let code = resp["code"]! as! Int
                    let message = resp["message"]! as! String
                    if code == 200 {
                        let data = resp["data"] as! [String:Any]
                        debugPrint("Data: \(data)")
                        updateUserInfoEnvVariable(data: data)
                        createSession(token: data["token"] as! String)
                    } else {
                        debugPrint("Message: ", message)
                    }
                }
            }
        }
        
        // 微信小程序登录返回信息
        else if resp.isKind(of: WXLaunchMiniProgramResp.self ) {
            if resp.errCode == 0 && resp.type == 0 {
                let response = resp as! WXLaunchMiniProgramResp
                
                // extMsg: 小程序返回的原始数据，为一个 URL Query String，示例数据如下：
                // 成功：code=200&message=授权成功&ticket=eyJhbGciOiJIUz
                // 失败：code=400&message=用户取消授权
                let extMsg = response.extMsg!
                
                // 将 extMsg 转换成一个 dict
                // ["code": "200", "ticket": "eyJhbGciOiJIUzI1NiIsInR5cCI6Ik", "message": "授权成功"]
                let data = parseUrlQueryString(string: extMsg)
                
                let code = data["code"]! as! String
                let message = data["message"]! as! String
                if code == "200" {
                    
                    // 用 ticket 换取用户信息
                    // 注意：默认情况下换取用户信息需要提供用户池密钥(secret), 开发者可以在后台修改配置。
                    // 此示例设置了 ticket 换取用户信息 不需要 secret
                    let ticket = data["ticket"]! as! String
                    struct Body: Encodable {
                        let ticket: String
                    }
                    let body = Body(ticket: ticket)
                    let url = "\(AuthingServerHost)/oauth/app2wxapp/auth/\(UserPoolId)?ticket=\(ticket)"
                    AF.request(
                        url,
                        method: .post,
                        parameters: body,
                        encoder: JSONParameterEncoder.default
                    ).responseString { response in
                        
                        // 将 response.value 转化成字符串，示例如下：
                        // ["code": "200", "message": "获取用户信息成功", data: "" ]
                        let resp = convertToDictionary(text: response.value!)!
                        
                        // resp["data"] 还是一个字符串，再次转换一下。
                        let dataStr = resp["data"]! as! String
                        let data = convertToDictionary(text: dataStr)!
                        debugPrint("Data: \(data)")
                        
                        // 更新 EnvironmentObject 触发页面更新
                        updateUserInfoEnvVariable(data: data)
                        createSession(token: data["token"] as! String)
                    }
                }
            }
        }

    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

