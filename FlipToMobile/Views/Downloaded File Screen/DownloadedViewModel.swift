//
//  DownloadedViewModel.swift
//  TestSMB
//
//  Created by Phùng Minh Nhật on 10/29/20.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class DownloadedViewModel {
    
    private var directoryUrl: URL
    private var originListFile: [File] = []
    var contents: [URL] = []
    var listDownloadedFile = BehaviorRelay<[File]>(value: [])

    init(directoryUrl: URL) {
        self.directoryUrl = directoryUrl
        setUpContent(at: directoryUrl)
    }

    private func setUpContent(at url: URL) {
        do {
            contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            getListFile(content: contents)
        } catch let error {
            print(error.localizedDescription)
        }
    }

    private func getListFile(content: [URL]) {
        do {
            var listFile:[File] = []
            for contents in content {
                let attributes = try FileManager.default.attributesOfItem(atPath: contents.path)
                let name = FileManager.default.displayName(atPath: contents.path)
                let path = contents.path
                let type = attributes[.type] as? URLFileResourceType
                let size = attributes[.size] as? Int64
                let modified = attributes[.modificationDate] as? Date
                let created = attributes[.creationDate] as? Date
                let file = File(name: name, path: path, type: type, size: size, modified: modified, created: created)
                listFile.append(file)
            }
            listDownloadedFile.accept(listFile)
            self.originListFile = listFile
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func removerItem(indexPath: IndexPath) {
        let fileUrl = contents[indexPath.row]
        do {
            try FileManager.default.removeItem(at: fileUrl)
            contents = try FileManager.default.contentsOfDirectory(at: directoryUrl, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            getListFile(content: contents)
        } catch let error {
            let err = error as NSError
            print(err.domain)
            print(error.localizedDescription)
        }
    }
    
    func filterListFile(query: String) -> [File] {
        if query == "" {
            return originListFile
        } else {
            return listDownloadedFile.value.filter { ($0.name?.uppercased().hasPrefix(query.uppercased()))! }
        }
    }
    
    func searchFile(fileName: String) {
        let listFile = filterListFile(query: fileName)
        listDownloadedFile.accept(listFile)
    }
}
