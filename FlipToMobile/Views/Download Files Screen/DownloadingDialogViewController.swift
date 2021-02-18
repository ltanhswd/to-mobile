//
//  DownloadingDialogViewController.swift
//  TestSMB
//
//  Created by NgoQuangThinh on 16/12/2020.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import UIKit
import AMSMB2

class DownloadingDialogViewController: UIViewController {

    @IBOutlet weak var downloadDialog: UIView!
    @IBOutlet weak var downloadedFileLabel: UILabel!
    @IBOutlet weak var totalFileLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var downloadProgessBar: UIProgressView!
    @IBOutlet weak var donwloadingLabel: UILabel!
    
    private var downloadedFile: Int = 0
    private var downloadFileViewModel: DownloadFileViewModel?
    private var isCompleteDownload = false
    
    var totalByte: Int64 = 1
    var downloadedByte: Int64 = 0
    var savedByteArray: [Int64] = []
    var totalFile: Int = 0
    var downloadService: DownloadServiceProtocol?
    var listFileDownload: [File] = []
    weak var handleAfterDownloadDelegate: HandleAfterDownloadProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startDownloadListFile(listFile: self.listFileDownload)
    }
    
    private func setupData() {
        if let downloadService = downloadService {
            downloadFileViewModel = DownloadFileViewModel(downloadService: downloadService)
            downloadFileViewModel?.setDownloadDelegate(delegate: self)
        }
    }
    
    private func startDownloadListFile(listFile: [File]) {
        if listFile.count > 0 {
            downloadFileViewModel?.startDownloadFileList(listFile: listFile)
            savedByteArray = [Int64](repeating: 0, count: listFile.count)
        }
    }
    
    private func setupLayout() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        downloadDialog.layer.cornerRadius = 20
        cancelButton.layer.cornerRadius = cancelButton.layer.frame.height / 2
        downloadProgessBar.progress = Float(Float(downloadedByte)/Float(totalByte))
        totalFileLabel.text = "\(totalFile)"
        downloadedFileLabel.text = "\(downloadedFile)"
    }
    
    @IBAction func cancelButtonTap(_ sender: Any) {
        if isCompleteDownload {
            dismiss(animated: true) { [weak self] in
                self?.handleAfterDownloadDelegate?.openDownloadedScreen()
            }
            isCompleteDownload = false
        } else {
            downloadFileViewModel?.cancelDownloadFileList()
            dismiss(animated: true)
        }
    }
}

extension DownloadingDialogViewController: DownloadingProtocol {
    
    func updateFileDownloadedNumber() {
        downloadedFile += 1
        DispatchQueue.main.async { [weak self] in
            self?.downloadedFileLabel.text = "\(self?.downloadedFile ?? 0)"
            if self?.downloadedFile == self?.totalFile {
                self?.isCompleteDownload = true
                self?.cancelButton.setTitle(Constants.viewDownloadedButtonTitle, for: .normal)
                self?.donwloadingLabel.text = "Download complete"
            }
        }
    }
    
    func updateByteDownloadedNumber(downloadedByte: Int64) {
        self.savedByteArray[downloadedFile] = downloadedByte
        self.downloadedByte = savedByteArray.reduce(0, +)
        let progress = Float (Float(self.downloadedByte) / Float(totalByte))
        DispatchQueue.main.async { [weak self] in
            self?.downloadProgessBar.progress = progress
        }
    }
    
    func handleError(error: Error) {
        downloadFileViewModel?.cancelDownloadFileList()
        DispatchQueue.main.async { [weak self] in
            self?.dismiss(animated: true) {
                self?.handleAfterDownloadDelegate?.showErrorDialog(error: error)
            }
        }
    }
}
