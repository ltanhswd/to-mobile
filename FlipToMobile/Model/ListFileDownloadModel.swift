//
//  ListFileDownloadModel.swift
//  TestSMB
//
//  Created by NgoQuangThinh on 22/12/2020.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import Foundation
import RxDataSources

struct ListFileDownloadModel {
    var headerTitle: String
    var items: [Item]
}

extension ListFileDownloadModel: SectionModelType {
    typealias Item = File
    init(original: ListFileDownloadModel, items: [File]) {
        self = original
        self.items = items
    }
}
