//
//  DownloadSMBService.swift
//  TestSMB
//
//  Created by iOS on 12/7/20.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import Foundation
import AMSMB2

class DownloadSMBService: DownloadServiceProtocol {
    
    private var docsPath: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private weak var smbClient: AMSMB2?
    private var outputStream: OutputStream!
    private var downloadOperation = OperationQueue()
    private var isPaused: Bool = false
    private var listFile: [File] = []
    
    var downloadDelegate: DownloadingProtocol?

    init(smbClient: AMSMB2) {
        self.smbClient = smbClient
    }
    
    func downloadListFile(listFile: [File]) {
        var operation: [Operation] = []
        downloadOperation.maxConcurrentOperationCount = 1
        for file in listFile {
            if let filePath = file.path {
                let block = BlockOperation { [weak self] in
                    self?.downloadFileOnList(at: filePath)
                }
                if operation.count > 0 {
                    block.addDependency(operation.last!)
                }
                operation.append(block)
            }
        }
        downloadOperation.addOperations(operation, waitUntilFinished: true)
    }
    
    func cancelDownload() {
        isPaused = true
        downloadOperation.cancelAllOperations()
    }
    
    private func downloadFileOnList(at path: String) {
        let docsPath: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let tempPath = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(path)
        let destinationPath = docsPath.appendingPathComponent(path)
        try? FileManager.default.removeItem(at: tempPath)
        outputStream = OutputStream(url: tempPath, append: true)
        smbClient?.downloadItem(atPath: path, to: outputStream, progress: { [weak self] (byteDownloaded, totalByte) -> Bool in
            if self!.isPaused {
                return false // return false when pause or download completed
            }
            self?.downloadDelegate?.updateByteDownloadedNumber(downloadedByte: byteDownloaded)
            if byteDownloaded == totalByte {// download file complete
                do{
                    if FileManager.default.fileExists(atPath: destinationPath.path) {
                        try FileManager.default.removeItem(at: destinationPath)
                    }
                    try FileManager.default.moveItem(atPath: tempPath.path, toPath: destinationPath.path)
                    self?.downloadDelegate?.updateFileDownloadedNumber()
                } catch let error {
                    print(error.localizedDescription)
                }
            }
            return true // return true when downloading
            }, completionHandler: { [weak self] (error) in
                if let error = error {
                    do {
                        if FileManager.default.fileExists(atPath: tempPath.path) {
                            try FileManager.default.removeItem(at: tempPath)
                        }
                        self?.downloadDelegate?.handleError(error: error)
                    } catch let fileManagerError {
                        print(fileManagerError.localizedDescription)
                    }
                }
        })
    }
}
