//
//  ConnectService.swift
//  TestSMB
//
//  Created by iOS on 12/4/20.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import Foundation
import AMSMB2

protocol ConnectServiceProtocol {
    func connectToSMBServer(server: String, shareFolder: String, handler: @escaping (Result<AMSMB2, Error>) -> Void)
}
