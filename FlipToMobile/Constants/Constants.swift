//
//  Constants.swift
//  TestSMB
//
//  Created by NgoQuangThinh on 14/12/2020.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    static let dateFormat = "MMM dd, yyyy hh:mm a"
    static let guestUser = "guest"
    static let serverIP = "192.168.49.1"
    static let serverIPTest = "10.1.14.175"
    
    static let downloadScreenTitle = "Dowload File"
    static let downloadedFileScreenTitle = "Downloaded file"
    static let aboutAppScreenTitle = "About App"
    static let connectManualScreenTitle = "Connect Manually"
    static let scanQRSreenTitle = "Scan QR Code"
    static let listFileScreenTitle = "List File"
    
    static let deleteButtonTitle = "Delete"
    static let cancelButtonTile = "Cancel"
    static let okButtonTitle = "OK"
    static let startDownloadButtonTitle = "Start download"
    static let resumeDownloadButtonTitle = "Resume download"
    static let closeButtonTitle = "Close"
    static let viewDownloadedButtonTitle = "View downloaded"
    
    static let deleteFileAlertTitle = "Delete file"
    static let unableOpenFileAlertTitle = "Unable to open file"
    static let connectErrorAlertTitle = "Connect error"
    static let invalidQRCodeAlertTitle = "Invalid QR code"
    static let notSupportFileIWB = "Not a file type supported by your mobile. You can open IWB file with your flip."
    static let invalidQRCode = "This code isn't working. Please try again using the QR code from your Flip."
    static let noFileFound = "No files found"
    static let askForDeleteFile = "Do you want to delete file(s)?"
    static let enterServerAndFolder = "Please enter server address and folder"
    static let enterWifiAndPassword = "Please enter Wifi name and password"
    static let connectWifiSuccess = "Connect Wi-Fi success"
    static let downloadFileError = "Error"
    static let downloadFileErrorMessage = "Download file error"
    static let downloadFileComplete = "Downloaded"
    static let wifiErrorDomain = "UnableConnectWifi"
    
    static let NEHotspotConfigurationErrorDomain = "NEHotspotConfigurationErrorDomain"
    
    static let iwbFileExtension = "iwb"
    static let htmlFileExtension = "html"
    static let pdfFileExtension = "pdf"
    static let openSourceHTMLFile = "openSource"
    static let pdfThumbnailIcon = "ic_mobile_pdf.png"
    static let iwbThumbnailIcon = "ic_mobile_iwb.png"
    static let selectedFile = "btn_mobile_select_sel"
    static let unselectedFile = "btn_mobile_select_nor"
    static let tempPdfFileName = "temp_doc.pdf"
    
    static let byteSize: Int64 = 1024
    static let kilobyteSize: Int64 = 1048576
    static let byteText = "Byte"
    static let kilobyteText = "KB"
    static let megabyteText = "MB"
    
    static let viewBackgroundColor = UIColor(red: 242, green: 242, blue: 247, alpha: 1)
}
