//
//  File.swift
//  TestSMB
//
//  Created by Tran Ngoc Tam on 10/28/20.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import Foundation

struct File {
    let name: String?
    let path: String?
    let type: URLFileResourceType?
    let size: Int64?
    let modified: Date?
    let created: Date?
}
