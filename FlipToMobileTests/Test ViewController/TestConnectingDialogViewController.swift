//
//  TestScanQRCodeViewController.swift
//  FlipToMobileTests
//
//  Created by NgoQuangThinh on 07/01/2021.
//  Copyright © 2021 Tran Ngoc Tam. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import To_Mobile

class TestConnectingDialogViewController: QuickSpec {
    override func spec() {
        describe("Test Connecting dialog VC") {
            context("When init view controller") {
                it("Connecting dialog should be init success") {
                    let connectingDialog = ConnectingDialogViewController()
                    let _ = connectingDialog.view
                    connectingDialog.beginAppearanceTransition(true, animated: false)
                    connectingDialog.endAppearanceTransition()
                    connectingDialog.viewDidLayoutSubviews()
                    expect(connectingDialog.cancelButton).notTo(beNil())
                    expect(connectingDialog.cancelButton.titleLabel?.text).to(equal("Cancel"))
                }
            }
        }
    }
}
