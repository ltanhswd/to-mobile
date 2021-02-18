//
//  NSObjectExtension.swift
//  TestSMB
//
//  Created by NgoQuangThinh on 15/12/2020.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import Foundation

extension NSObject {
    class func name() -> String {
        let path = NSStringFromClass(self)
        return path.components(separatedBy: ".").last ?? ""
    }
}

