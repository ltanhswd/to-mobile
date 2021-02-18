//
//  ConnectingDialogViewController.swift
//  FlipToMobile
//
//  Created by NgoQuangThinh on 24/12/2020.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import UIKit

class ConnectingDialogViewController: UIViewController {

    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    
    var cancelConnectDelegate: CancelConnectionProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        setupLayout()
    }
    
    func setupLayout() {
        dialogView.layer.cornerRadius = 14
        cancelButton.layer.cornerRadius = cancelButton.layer.frame.height / 2
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }
    
    @IBAction func cancelButtonTap(_ sender: Any) {
        dismiss(animated: true)
        cancelConnectDelegate?.cancelConnect()
    }
    
}
