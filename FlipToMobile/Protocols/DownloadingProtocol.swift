//
//  DownloadingProtocol.swift
//  TestSMB
//
//  Created by NgoQuangThinh on 16/12/2020.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import Foundation

protocol DownloadingProtocol {
    func updateByteDownloadedNumber(downloadedByte: Int64)
    func updateFileDownloadedNumber()
    func handleError(error: Error)
}
