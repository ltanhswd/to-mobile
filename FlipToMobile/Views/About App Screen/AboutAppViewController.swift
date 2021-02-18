//
//  AboutAppViewController.swift
//  TestSMB
//
//  Created by iOS on 12/2/20.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import UIKit

class AboutAppViewController: UIViewController {

    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var versionStatusLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var opensourceButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func setupLayout() {
        self.title = Constants.aboutAppScreenTitle
        updateButton.layer.cornerRadius = 8
    }

    @IBAction func openSourceTap(_ sender: Any) {
        let openSourceVC = OpenSourceLicenseViewController(nibName: OpenSourceLicenseViewController.name(), bundle: nil)
        self.navigationController?.pushViewController(openSourceVC, animated: true)
    }
    
    @IBAction func updateTap(_ sender: Any) {
    }
    
}
