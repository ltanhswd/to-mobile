//
//  FileService.swift
//  FlipToMobile
//
//  Created by NgoQuangThinh on 12/01/2021.
//  Copyright © 2021 Tran Ngoc Tam. All rights reserved.
//

import Foundation
import AMSMB2

class SMBFileService: FileServiceProtocol {
    private var smbClient: AMSMB2?
    
    init(smbClient: AMSMB2) {
        self.smbClient = smbClient
    }
    
    func listFileAtPath(path: String, handler: @escaping (Result<[[URLResourceKey : Any]], Error>) -> Void) {
        smbClient?.contentsOfDirectory(atPath: path) { result in
            switch result {
            case .success(let listFiles):
                handler(.success(listFiles))
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
