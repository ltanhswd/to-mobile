//
//  TestDownloadedViewController.swift
//  FlipToMobileTests
//
//  Created by NgoQuangThinh on 05/01/2021.
//  Copyright © 2021 Tran Ngoc Tam. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import To_Mobile

class TestDownloadedViewController: QuickSpec {
    override func spec() {
        describe("Test downloaded view model") {
            var downloadedVC: DownloadedViewController!
            
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
                
                downloadedVC = DownloadedViewController()
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
            
            context("When has file download") {
                it("Table view should show item has downloaded") {
                    downloadedVC.setDocumentURL(url: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0])
                    let _ = downloadedVC.view
                    let numberOfItem = downloadedVC.tableView.numberOfRows(inSection: 0)
                    expect(numberOfItem).to(beGreaterThan(0))
                }
                
                it("Table view should correct data") {
                    print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path)
                    downloadedVC.setDocumentURL(url: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0])
                    let indexPath = IndexPath(row: 0, section: 0)
                    let _ = downloadedVC.view
                    let cell = downloadedVC.tableView.cellForRow(at: indexPath) as? DownloadedRollTableViewCell
                    expect(cell?.rollName.text).toNot(beNil())
                    expect(cell?.rollName.text).toNot(equal(""))
                }
            }
            
            context("When has no file download") {
                it("Table view should show no item") {
                    let blankFolder = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("blankFolder")
                    if FileManager.default.fileExists(atPath: blankFolder.path) {
                        try? FileManager.default.removeItem(at: blankFolder)
                    }
                    try? FileManager.default.createDirectory(atPath: blankFolder.path, withIntermediateDirectories: true, attributes: nil)
                    downloadedVC.setDocumentURL(url: blankFolder)
                    let _ = downloadedVC.view
                    let numberOfItem = downloadedVC.tableView.numberOfRows(inSection: 0)
                    expect(numberOfItem).to(equal(0))
                }
            }
            
            context("When delete downloaded file") {
                it("Should show dialog confirm") {
                    let indexPath = IndexPath(row: 0, section: 0)
                    downloadedVC.setDocumentURL(url: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0])
                    let window = UIWindow(frame: UIScreen.main.bounds)
                    window.makeKeyAndVisible()
                    window.rootViewController = downloadedVC
                    let _ = downloadedVC.view
                    downloadedVC.tableView.beginUpdates()
                    downloadedVC.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    var presentedVC = downloadedVC.presentedViewController
                    expect(presentedVC).to(beNil())
                    downloadedVC.trashButtonTap(self)
                    presentedVC = downloadedVC.presentedViewController
                    expect(presentedVC).to(beAnInstanceOf(UIAlertController.self))
                }
            }
            
            context("When share downloaded file") {
                it("Should show share sheet") {
                    let indexPath = IndexPath(row: 0, section: 0)
                    downloadedVC = DownloadedViewController()
                    downloadedVC.setDocumentURL(url: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0])
                    let window = UIWindow(frame: UIScreen.main.bounds)
                    window.makeKeyAndVisible()
                    window.rootViewController = downloadedVC
                    let _ = downloadedVC.view
                    downloadedVC.tableView.beginUpdates()
                    downloadedVC.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    var presentedVC = downloadedVC.presentedViewController
                    expect(presentedVC).to(beNil())
                    downloadedVC.shareButtonTap(self)
                    presentedVC = downloadedVC.presentedViewController
                    expect(presentedVC).to(beAnInstanceOf(UIActivityViewController.self))
                }
            }
        }
    }
}
