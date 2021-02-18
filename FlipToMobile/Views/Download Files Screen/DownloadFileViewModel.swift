//
//  DownloadFileViewModel.swift
//  TestSMB
//
//  Created by NgoQuangThinh on 18/12/2020.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import Foundation
import AMSMB2

class DownloadFileViewModel {
    
    private var downloadService: DownloadServiceProtocol?
    private var listFileDownload: [File]?
    private var fileDownloading: Int?
    
    init(downloadService: DownloadServiceProtocol) {
        self.downloadService = downloadService
    }
    
    func setDownloadDelegate(delegate: DownloadingProtocol) {
        downloadService?.downloadDelegate = delegate
    }
    
    func startDownloadFileList(listFile: [File]) {
        self.listFileDownload = listFile
        downloadService?.downloadListFile(listFile: listFile)
    }
    
    func cancelDownloadFileList() {
        downloadService?.cancelDownload()
    }
}
