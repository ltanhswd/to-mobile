//
//  FilesServiceProtocol.swift
//  FlipToMobile
//
//  Created by NgoQuangThinh on 12/01/2021.
//  Copyright © 2021 Tran Ngoc Tam. All rights reserved.
//

import Foundation

protocol FileServiceProtocol: class {
    func listFileAtPath(path: String, handler: @escaping (Result<[[URLResourceKey: Any]], Error>) -> Void)
}
