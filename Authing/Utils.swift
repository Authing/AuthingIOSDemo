//
//  Utils.swift
//  Authing
//
//  Created by 廖长江 on 2020/2/27.
//  Copyright © 2020 steamory. All rights reserved.
//

import Foundation

func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}

func parseUrlQueryString(string: String) -> [String:Any] {
    let arr = string.components(separatedBy:"&")
    var data = [String:Any]()
    for row in arr {
        let pairs = row.components(separatedBy:"=")
        data[pairs[0]] = pairs[1]
    }
    return data
}
