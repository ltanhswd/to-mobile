//
//  DownloadedViewController.swift
//  TestSMB
//
//  Created by Phùng Minh Nhật on 10/29/20.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import UIKit
import AMSMB2
import RxSwift
import RxCocoa

class DownloadedViewController: UIViewController {

    private var downloadedVM: DownloadedViewModel?
    private var disposeBag: DisposeBag = DisposeBag()
    private var documentURL:URL!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupObserver()
        setupTableViewData()
        setupLongPressTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func setDocumentURL(url: URL){
        documentURL = url
    }
    
    private func setupObserver() {
        downloadedVM = DownloadedViewModel(directoryUrl: documentURL)
        disposeBag = DisposeBag()
        
        downloadedVM?.listDownloadedFile.asObservable().subscribe(onNext: { [weak self] (files) in
            if files.count == 0 {
                self?.showUIWhenNoItemDownloaded()
                self?.toolBar.isHidden = true
                self?.tableView.setEditing(false, animated: true)
                self?.navigationItem.rightBarButtonItem = nil
                
            } else {
                self?.tableView.isHidden = false
                self?.view.bringSubviewToFront(self?.tableView ?? UIView())
            }
        }).disposed(by: disposeBag)
        
        tableView.rx.itemDeleted.subscribe(onNext: { [weak self] (indexPath) in
            let alert = UIAlertController(title: Constants.deleteFileAlertTitle, message: Constants.askForDeleteFile, preferredStyle: .alert)
            let cancel = UIAlertAction(title: Constants.cancelButtonTile, style: .cancel, handler: nil)
            let delete = UIAlertAction(title: Constants.deleteButtonTitle, style: .default) { [weak self] _ in
                self?.downloadedVM?.removerItem(indexPath: indexPath)
            }
            alert.addAction(cancel)
            alert.addAction(delete)
            self?.present(alert, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext: { [weak self] (indexPath) in
            if !(self?.tableView.isEditing ?? false) {
                if let pdfURL = self?.downloadedVM?.contents[indexPath.row] {
                    let fileExtension = pdfURL.pathExtension
                    if fileExtension == Constants.iwbFileExtension {
                        self?.showAlertAction(title: Constants.unableOpenFileAlertTitle, message: Constants.notSupportFileIWB)
                        self?.tableView.deselectRow(at: indexPath, animated: false)
                    } else {
                        let pdfView = PDFViewController()
                        pdfView.setFileUrl(fileURL: pdfURL)
                        self?.tableView.deselectRow(at: indexPath, animated: false)
                        self?.navigationController?.pushViewController(pdfView, animated: true)
                    }
                }
            }
        }).disposed(by: disposeBag)
        
        searchBar.rx.text.orEmpty.subscribe(onNext: { [weak self] fileName in
            self?.downloadedVM?.searchFile(fileName: fileName)
        }).disposed(by: disposeBag)
    }
    
    private func setupTableViewData() {
        tableView.delegate = self
        downloadedVM?.listDownloadedFile.asObservable().bind(to: tableView.rx.items) {[weak self] (tableView, row, file) -> UITableViewCell in
            let cell = Bundle.main.loadNibNamed(DownloadedRollTableViewCell.name(), owner: self, options: nil)?.first as? DownloadedRollTableViewCell
            cell?.configCell(file: file)
            return cell ?? UITableViewCell()
        }.disposed(by: disposeBag)
    }
    
    private func setupLayout() {
        searchBar.clipsToBounds = true
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView()
        tableView.clipsToBounds = true
        self.title = Constants.downloadedFileScreenTitle
        //Hide bottom toolbar border
        toolBar.clipsToBounds = true
        toolBar.backgroundColor = view.backgroundColor
    }
    
    @IBAction func shareButtonTap(_ sender: Any) {
        showShareSheet()
    }
    
    @IBAction func trashButtonTap(_ sender: Any) {
        if let indexPaths = tableView.indexPathsForSelectedRows {
            if indexPaths.count > 0 {
                let alert = UIAlertController(title: Constants.deleteFileAlertTitle, message: Constants.askForDeleteFile, preferredStyle: .alert)
                let cancel = UIAlertAction(title: Constants.cancelButtonTile, style: .cancel, handler: nil)
                let delete = UIAlertAction(title: Constants.deleteButtonTitle, style: .default) { [weak self] _ in
                    for indexPath in indexPaths {
                        self?.downloadedVM?.removerItem(indexPath: indexPath)
                    }
                    self?.tableView.setEditing(false, animated: true)
                }
                alert.addAction(cancel)
                alert.addAction(delete)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
     
    private func showUIWhenNoItemDownloaded() {
        tableView.isHidden = true
        let noFileLabel = UILabel()
        noFileLabel.text = Constants.noFileFound
        self.view.addSubview(noFileLabel)
        noFileLabel.translatesAutoresizingMaskIntoConstraints = false
        noFileLabel.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        noFileLabel.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor).isActive = true
    }
    
    private func showAlertAction(title: String, message: String) {
        let alert = UIAlertController(title: title  , message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: Constants.okButtonTitle, style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    private func showShareSheet() {
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            var filesToShare = [NSURL]()
            for indexPath in selectedIndexPaths {
                if let fileURL = downloadedVM?.contents[indexPath.row].path {
                    filesToShare.append(NSURL(fileURLWithPath: fileURL))
                }
            }
            let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
            present(activityViewController, animated: true)
            activityViewController.completionWithItemsHandler = { (activityType, completed, arrayReturnedItems, error) in
                if completed {
                    print("share completed")
                    return
                } else {
                    print("cancel")
                }
                if let shareError = error {
                    print("error while sharing: \(shareError.localizedDescription)")
                }
            }
        }
    }
    
    private func setupLongPressTableView() {
        let longPressGuesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        tableView.addGestureRecognizer(longPressGuesture)
    }
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if !tableView.isEditing {
            if sender.state == UIGestureRecognizer.State.began {
                let touchPoint = sender.location(in: tableView)
                if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                    tableView.setEditing(true, animated: true)
                    tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                }
                let cancelButton = UIBarButtonItem(title: Constants.cancelButtonTile, style: .plain, target: self, action: #selector(cancelButtonTap))
                navigationItem.rightBarButtonItem = cancelButton
                toolBar.isHidden = false
            }
        }
    }
    
    @objc func cancelButtonTap() {
        toolBar.isHidden = true
        tableView.setEditing(false, animated: true)
        navigationItem.rightBarButtonItem = nil
    }
}

extension DownloadedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
