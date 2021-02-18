//
//  TestMainViewController.swift
//  FlipToMobileTests
//
//  Created by NgoQuangThinh on 29/12/2020.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import To_Mobile

class TestMainViewController: QuickSpec {
    override func spec() {
        describe("Test Main View Controller") {
            var mainVC: MainViewController!
            var navigationController: UINavigationController!
            
            beforeEach {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                mainVC = storyboard.instantiateViewController(identifier: MainViewController.name()) as? MainViewController
                navigationController = storyboard.instantiateViewController(identifier: "navigationcontroller") as? UINavigationController
                navigationController.pushViewController(mainVC, animated: false)
                let _ =  mainVC.view
            }
            
            describe("When tap button scan QR") {
                it("Should move to scan QR screen") {
                    mainVC.tapScanQR(self)
                    expect(navigationController.visibleViewController).toEventually(beAnInstanceOf(ScanQRCodeViewController.self))
                }
            }
            
            describe("When tap button Connect Manually") {
                it("Should move to connect manually screen") {
                    mainVC.tapManually(self)
                    expect(navigationController.visibleViewController).toEventually(beAnInstanceOf(ManuallyConnectViewController.self))
                }
            }
            
            describe("When tap button Downloaded roll") {
                it("Should move to downloaded roll screen") {
                    mainVC.tapDownloaded(self)
                    expect(navigationController.visibleViewController).toEventually(beAnInstanceOf(DownloadedViewController.self))
                }
            }
            
            describe("When tap button About") {
                it("Should move to about app screen") {
                    mainVC.tapAboutApp(self)
                    expect(navigationController.visibleViewController).toEventually(beAnInstanceOf(AboutAppViewController.self))
                }
            }
        }
    }
}
