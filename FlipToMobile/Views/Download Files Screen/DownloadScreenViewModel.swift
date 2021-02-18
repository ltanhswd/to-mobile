//
//  DownloadScreenViewModel.swift
//  TestSMB
//
//  Created by NgoQuangThinh on 18/12/2020.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import Foundation
import AMSMB2
import RxCocoa
import RxSwift

class DownloadScreenViewModel {

    private weak var fileService: FileServiceProtocol?
    var listFileWithSection = BehaviorRelay<[ListFileDownloadModel]>(value: [])
    
    init(fileService: FileServiceProtocol) {
        self.fileService = fileService
    }

    func getListFile(at path: String) {
        fileService?.listFileAtPath(path: path, handler: { [weak self] result in
            switch result {
            case .success(let files):
                self?.processData(data: files)
            case .failure(let error):
                print(error)
            }
        })
    }

    private func processData(data: [[URLResourceKey: Any]]) {
        var listPdfFile = ListFileDownloadModel(headerTitle: "PDF File", items: [])
        var listOtherFile = ListFileDownloadModel(headerTitle: "Other File", items: [])
        
        for entry in data {
            let name = entry[.nameKey] as? String
            let path = entry[.pathKey] as? String
            let type = entry[.fileResourceTypeKey] as? URLFileResourceType
            let size = entry[.fileSizeKey] as? Int64
            let modified = entry[.contentModificationDateKey] as? Date
            let created = entry[.creationDateKey] as? Date
            let file = File(name: name, path: path, type: type, size: size, modified: modified, created: created)
            if let fileExtension = name?.components(separatedBy: ".").last {
                if fileExtension == Constants.pdfFileExtension {
                    listPdfFile.items.append(file)
                } else {
                    listOtherFile.items.append(file)
                }
            }
        }
        listPdfFile.items.sort {
            $0.name! < $1.name!
        }
        listOtherFile.items.sort {
            $0.name! < $1.name!
        }
        listFileWithSection.accept([listPdfFile, listOtherFile])
        if let file = listPdfFile.items.first {
            print("File Path: \(file.path ?? "No path")")
        }
    }
}
