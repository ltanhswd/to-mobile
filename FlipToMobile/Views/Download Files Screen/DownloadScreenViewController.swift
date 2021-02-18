//
//  DownloadScreenViewController.swift
//  TestSMB
//
//  Created by NgoQuangThinh on 15/12/2020.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import UIKit
import AMSMB2
import RxCocoa
import RxSwift
import RxDataSources
import NetworkExtension

class DownloadScreenViewController: UIViewController {

    @IBOutlet weak var listFileTableView: UITableView!
    @IBOutlet weak var downloadButton: UIButton!
    
    private var listFileVM: DownloadScreenViewModel?
    private var disposeBag = DisposeBag()
    private var isSelectedRowInSection: [[Bool]] = []
    private var selectedRowsInSection: [[Int]] = [[],[]]
    private var numberOfSelectedRow = 0
    private var isEnableDownloadButton = PublishSubject<Bool>()
    private weak var smbClient: AMSMB2?
    private var folderPath: String?
    private var fileService: FileServiceProtocol?
    private var ssidName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let rootVC = navigationController?.viewControllers.first {
            navigationController?.viewControllers = [rootVC, self]
        }
        if let fileService = self.fileService {
            listFileVM = DownloadScreenViewModel(fileService: fileService)
        }
        setupLayout()
        setupObserver()
        setupTableViewDataWithSection()
        listFileVM?.getListFile(at: folderPath ?? "")
    }
    
    func setService(smbClient: AMSMB2, fileService: FileServiceProtocol, folderPath: String, ssidName: String) {
        self.smbClient = smbClient
        self.fileService = fileService
        self.folderPath = folderPath
        self.ssidName = ssidName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func setupObserver() {
        listFileVM?.listFileWithSection.asObservable().subscribe(onNext: { [weak self] (listFile) in
            for list in listFile {
                let array = [Bool](repeating: false, count: list.items.count)
                self?.isSelectedRowInSection.append(array)
            }
        }).disposed(by: disposeBag)

        listFileTableView.rx.itemSelected.subscribe(onNext: { [weak self] (indexPath) in
            if let isSelected = self?.isSelectedRowInSection[indexPath.section][indexPath.row] {
                self?.isSelectedRowInSection[indexPath.section][indexPath.row] = !isSelected
                if !isSelected {
                    self?.selectedRowsInSection[indexPath.section].append(indexPath.row)
                    self?.numberOfSelectedRow += 1
                    self?.isEnableDownloadButton.onNext(true)
                    DispatchQueue.main.async {
                        let enableColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
                        self?.downloadButton.backgroundColor = enableColor
                    }
                } else {
                    if let indexOfIndexpath = self?.selectedRowsInSection[indexPath.section].firstIndex(of: indexPath.row) {
                        self?.selectedRowsInSection[indexPath.section].remove(at: indexOfIndexpath)
                        self?.numberOfSelectedRow -= 1
                        if (self?.numberOfSelectedRow)! < 1 {
                            self?.isEnableDownloadButton.onNext(false)
                            DispatchQueue.main.async {
                                let disableColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)
                                self?.downloadButton.backgroundColor = disableColor
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    self?.listFileTableView.reloadData()
                }
            }
        }).disposed(by: disposeBag)

        isEnableDownloadButton.bind(to: downloadButton.rx.isEnabled).disposed(by: disposeBag)
    }
    
    private func setupTableViewDataWithSection() {
        let dataSource = RxTableViewSectionedReloadDataSource<ListFileDownloadModel>(
          configureCell: { [weak self] dataSource, tableView, indexPath, item in
            let cell = Bundle.main.loadNibNamed(FileDownloadTableViewCell.name(), owner: self, options: nil)?.first as? FileDownloadTableViewCell
            cell?.configCell(file: item)
            if self?.isSelectedRowInSection[indexPath.section][indexPath.row] ?? false {
                cell?.selectImange.image = UIImage(named: Constants.selectedFile)
            } else {
                cell?.selectImange.image = UIImage(named: Constants.unselectedFile)
            }
            return cell ?? UITableViewCell()
        })
        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].headerTitle
        }
        listFileVM?.listFileWithSection.asObservable().bind(to: listFileTableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
    private func setupLayout() {
        self.title = Constants.downloadScreenTitle
        listFileTableView.delegate = self
        listFileTableView.tableFooterView = UIView()
        listFileTableView.allowsMultipleSelection = true
        downloadButton.layer.cornerRadius = 14
    }

    @IBAction func backButtonTap(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func downloadButtonTap(_ sender: Any) {
        if let listFileInSection = listFileVM?.listFileWithSection {
            var listDownloadFile: [File] = []
            var totalFileSize: Int64 = 0
            for section in 0..<listFileInSection.value.count {
                for row in selectedRowsInSection[section] {
                    listDownloadFile.append(listFileInSection.value[section].items[row])
                    totalFileSize += listFileInSection.value[section].items[row].size ?? 0
                }
            }
            if listDownloadFile.count > 0 {
                let downloadingDialog = DownloadingDialogViewController(nibName: DownloadingDialogViewController.name(), bundle: nil)
                downloadingDialog.modalPresentationStyle = .overFullScreen
                downloadingDialog.modalTransitionStyle = .crossDissolve
                downloadingDialog.totalFile = listDownloadFile.count
                downloadingDialog.totalByte = totalFileSize
                downloadingDialog.listFileDownload = listDownloadFile
                if let smbClient = self.smbClient {
                    downloadingDialog.downloadService = DownloadSMBService(smbClient: smbClient)
                }
                downloadingDialog.handleAfterDownloadDelegate = self
                present(downloadingDialog, animated: false)
            }
        }
    }
    
    deinit {
        NEHotspotConfigurationManager.shared.removeConfiguration(forSSID: ssidName ?? "")
    }
}

extension DownloadScreenViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension DownloadScreenViewController: HandleAfterDownloadProtocol {
    
    func showErrorDialog(error: Error) {
        let alert = UIAlertController(title: Constants.downloadFileError, message: Constants.downloadFileErrorMessage, preferredStyle: .alert)
        let ok = UIAlertAction(title: Constants.okButtonTitle, style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func openDownloadedScreen() {
        let downloadedVC = DownloadedViewController(nibName: DownloadedViewController.name(), bundle: nil)
        downloadedVC.setDocumentURL(url: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0])
        self.navigationController?.pushViewController(downloadedVC, animated: true)
    }
}
