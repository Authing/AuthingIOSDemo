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
