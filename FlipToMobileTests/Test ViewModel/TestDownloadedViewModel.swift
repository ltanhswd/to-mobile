//
//  TestDownloadedViewModel.swift
//  FlipToMobileTests
//
//  Created by NgoQuangThinh on 29/12/2020.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import To_Mobile

class TestDownloadedViewModel: QuickSpec {
    override func spec() {
        describe("Test downloaded view model") {
            
            beforeEach {
                let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                if let paths = try? FileManager.default.contentsOfDirectory(atPath: documentURL!.path) {
                    for path in paths {
                        let filePath = documentURL?.appendingPathComponent(path)
                        if FileManager.default.fileExists(atPath: filePath!.path) {
                            try? FileManager.default.removeItem(atPath: filePath!.path)
                        }
                    }
                }
                for number in 1...10 {
                    var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    print(url.path)
                    let fileName = "File_Number_\(number).txt"
                    url.appendPathComponent(fileName)
                    let string = "ABC"
                    if !FileManager.default.fileExists(atPath: url.path) {
                        try? string.write(to: url, atomically: true, encoding: .utf8)
                    }
                }
            }
            
            afterEach {
                for number in 1...10 {
                    var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let fileName = "File_Number_\(number).txt"
                    url.appendPathComponent(fileName)
                    if FileManager.default.fileExists(atPath: url.path) {
                        try? FileManager.default.removeItem(at: url)
                    }
                }
            }
            
            context("When init downloaded view model") {
                it("instance variable should not be nil") {
                    if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        let viewModel = DownloadedViewModel(directoryUrl: url)
                        let content = viewModel.contents
                        let listFile = viewModel.listDownloadedFile
                        expect(content).notTo(beNil())
                        expect(listFile).notTo(beNil())
                    }
                }
            }
            
            context("When get content at invalid URL") {
                it("Content array should be have no element") {
                    if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        let invalidURL = url.appendingPathComponent("Invalid_Folder")
                        let viewModel = DownloadedViewModel(directoryUrl: invalidURL)
                        let listContent = viewModel.contents.count
                        expect(listContent).to(equal(0))
                    }
                }
            }
            
            context("When get content at valid URL and have file") {
                it("Content array should be have element") {
                    if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        let viewModel = DownloadedViewModel(directoryUrl: url)
                        let listContent = viewModel.contents.count
                        expect(listContent).to(beGreaterThan(0))
                    }
                }
            }
            
            context("When get content at valid URL and have no file") {
                it("Content array should be have no element") {
                    for number in 1...10 {
                        var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        let fileName = "File_Number_\(number).txt"
                        url.appendPathComponent(fileName)
                        if FileManager.default.fileExists(atPath: url.path) {
                            try? FileManager.default.removeItem(at: url)
                        }
                    }
                    if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        let viewModel = DownloadedViewModel(directoryUrl: url)
                        let listContent = viewModel.contents.count
                        expect(listContent).to(equal(0))
                    }
                }
            }
            
            context("When delete file downloaded") {
                it("Deleted file should not be exist after delete") {
                    if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        let indexPath = IndexPath(row: 0, section: 0)
                        let viewModel = DownloadedViewModel(directoryUrl: url)
                        let fileNameToDelete = viewModel.listDownloadedFile.value.first?.name
                        let listFileBeforeDelete = viewModel.filterListFile(query: fileNameToDelete!).count
                        expect(listFileBeforeDelete).to(equal(1))
                        
                        viewModel.removerItem(indexPath: indexPath)
                        
                        let listFileAfterDelete = viewModel.filterListFile(query: fileNameToDelete!).count
                        expect(listFileAfterDelete).to(equal(0))
                    }
                }
            }
            
            context("When search downloaded file with name is not blank") {
                it("Should return correct file name with search input") {
                    if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        let viewModel = DownloadedViewModel(directoryUrl: url)
                        let numberFileBeforeSearch = viewModel.listDownloadedFile.value.count
                        expect(numberFileBeforeSearch).to(beGreaterThan(0))
                        
                        viewModel.searchFile(fileName: "File_Number_6.txt")
                        
                        let listSearchFile = viewModel.listDownloadedFile.value.count
                        let numberAfterSearch = viewModel.listDownloadedFile.value.count
                        let fileNameAfterSearch = viewModel.listDownloadedFile.value.first?.name
                        expect(listSearchFile).to(equal(1))
                        expect(numberFileBeforeSearch).to(beGreaterThan(numberAfterSearch))
                        expect(fileNameAfterSearch).to(equal("File_Number_6.txt"))
                    }
                }
            }
            
            context("When search downloaded file by name is blank") {
                it("Should return original list download file") {
                    if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        let viewModel = DownloadedViewModel(directoryUrl: url)
                        var numberFileBeforeSearch = viewModel.listDownloadedFile.value.count
                        let listOrigin = numberFileBeforeSearch
                        expect(numberFileBeforeSearch).to(beGreaterThan(0))
                        
                        viewModel.searchFile(fileName: "File_Number_6.txt")
                        
                        var listSearchFile = viewModel.listDownloadedFile.value.count
                        var numberFileAfterSearch = viewModel.listDownloadedFile.value.count
                        let fileNameAfterSearch = viewModel.listDownloadedFile.value.first?.name
                        expect(listSearchFile).to(equal(1))
                        expect(numberFileBeforeSearch).to(beGreaterThan(numberFileAfterSearch))
                        expect(fileNameAfterSearch).to(equal("File_Number_6.txt"))
                        
                        numberFileBeforeSearch = viewModel.listDownloadedFile.value.count
                        expect(numberFileBeforeSearch).to(beGreaterThan(0))
                       
                        viewModel.searchFile(fileName: "")
                        listSearchFile = viewModel.listDownloadedFile.value.count
                        numberFileAfterSearch = viewModel.listDownloadedFile.value.count
                        expect(listSearchFile).to(equal(listOrigin))
                    }
                }
            }
            
            context("When search downloaded file by name is not exist") {
                it("Should return list download file with no value") {
                    if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        let viewModel = DownloadedViewModel(directoryUrl: url)
                        let numberFileBeforeSearch = viewModel.listDownloadedFile.value.count
                        expect(numberFileBeforeSearch).to(beGreaterThan(0))
                        
                        viewModel.searchFile(fileName: "NoName.txt")
                        
                        let listSearchFile = viewModel.listDownloadedFile.value.count
                        let numberAfterSearch = viewModel.listDownloadedFile.value.count
                        let fileNameAfterSearch = viewModel.listDownloadedFile.value.first?.name
                        expect(listSearchFile).to(equal(0))
                        expect(numberFileBeforeSearch).to(beGreaterThan(numberAfterSearch))
                        expect(fileNameAfterSearch).to(beNil())
                    }
                }
            }
        }
    }
}
