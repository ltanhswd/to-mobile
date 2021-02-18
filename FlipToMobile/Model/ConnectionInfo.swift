//
//  ConnectionInfo.swift
//  TestSMB
//
//  Created by iOS on 11/25/20.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import Foundation

struct ConnectionInfo : Codable {
    let keyFolder: String!
    let keyIP: String!
    let isAnonymous: Bool!
    let keyPassword: String!
    let keySSID: String!
    let keySSIDPassword: String!
    let keyUser: String!
    
    enum CodingKeys: String, CodingKey {
        case keyFolder = "json_key_folder"
        case keyIP = "json_key_ip"
        case isAnonymous = "json_key_is_anonymous"
        case keyPassword = "json_key_password"
        case keySSID = "json_key_ssid"
        case keySSIDPassword = "json_key_ssid_password"
        case keyUser = "json_key_user"
    }
}
