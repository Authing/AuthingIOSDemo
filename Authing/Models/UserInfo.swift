//
//  UserInfo.swift
//  Authing
//
//  Created by 廖长江 on 2020/2/27.
//  Copyright © 2020 steamory. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class UserInfo: ObservableObject {
    @Published var nickname: String = ""
    @Published var avatar: String = ""
    @Published var openid: String = ""
    @Published var phone: String = ""
    @Published var unionid: String = ""
    @Published var token: String = ""
}

var userInfo = UserInfo()
