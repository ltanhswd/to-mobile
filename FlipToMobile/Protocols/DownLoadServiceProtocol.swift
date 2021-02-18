//
//  DownLoadService.swift
//  TestSMB
//
//  Created by iOS on 12/7/20.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import Foundation

protocol DownloadServiceProtocol : class {
    var downloadDelegate: DownloadingProtocol? { get set }
    
    func downloadListFile(listFile: [File])
    func cancelDownload()
}
