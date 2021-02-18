//
//  TestAboutAppViewController.swift
//  FlipToMobileTests
//
//  Created by NgoQuangThinh on 29/12/2020.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import To_Mobile

class TestAboutAppViewController: QuickSpec {
    override func spec() {
        describe("Test Main View Controller") {
            context("When tap button Open source license") {
                it("Should move to Open source license screen") {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let aboutVC = AboutAppViewController(nibName: AboutAppViewController.name(), bundle: nil)
                    let navigationController = storyboard.instantiateViewController(identifier: "navigationcontroller") as? UINavigationController
                    navigationController?.pushViewController(aboutVC, animated: false)
                    let _ =  aboutVC.view
                    aboutVC.openSourceTap(self)
                    expect(navigationController?.visibleViewController).toEventually(beAnInstanceOf(OpenSourceLicenseViewController.self))
                }
            }
            
            context("When init Open source license view controller") {
                it("Open source license view controller should be true") {
                    let openSource = OpenSourceLicenseViewController()
                    let _ = openSource.view
                    expect(openSource.webView).notTo(beNil())
                }
            }
        }
    }
}
