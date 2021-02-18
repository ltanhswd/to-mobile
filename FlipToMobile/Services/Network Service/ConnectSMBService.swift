//
//  SMBService.swift
//  TestSMB
//
//  Created by iOS on 12/4/20.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import Foundation
import AMSMB2

class ConnectSMBService : ConnectServiceProtocol {
    
    enum connectSMBServiceError: Error {
        case initError
    }
    
    func connectToSMBServer(server: String, shareFolder: String, handler: @escaping (Result<AMSMB2, Error>) -> Void) {
        let credential = URLCredential(user: Constants.guestUser, password: "", persistence: URLCredential.Persistence.forSession)
        guard let serverURL = URL(string: server),
            let client = AMSMB2(url: serverURL, credential: credential) else {
                handler(.failure(connectSMBServiceError.initError))
                return
        }
        client.connectShare(name: shareFolder) { error in
            if let error = error {
                handler(.failure(error))
            } else {
                handler(.success(client))
            }
        }
    }
}
