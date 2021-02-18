//
//  OpenSourceLicenseViewController.swift
//  TestSMB
//
//  Created by iOS on 12/3/20.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import UIKit
import WebKit

class OpenSourceLicenseViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = Bundle.main.url(forResource: Constants.openSourceHTMLFile, withExtension: Constants.htmlFileExtension) {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }
}
