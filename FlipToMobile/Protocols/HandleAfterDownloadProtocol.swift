//
//  CancelDownloadProtocol.swift
//  TestSMB
//
//  Created by NgoQuangThinh on 16/12/2020.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import Foundation

protocol HandleAfterDownloadProtocol : class {
    func showErrorDialog(error: Error)
    func openDownloadedScreen()
}
