//
//  PDFViewController.swift
//  TestSMB
//
//  Created by Phùng Minh Nhật on 10/28/20.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import UIKit
import PDFKit

class PDFViewController: UIViewController {

    private var pdfView = PDFView()
    private var fileURL: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let fileExtension = fileURL.pathExtension
        if fileExtension == Constants.pdfFileExtension {
            setupViewForPDF()
        } else {
            setupViewForOtherFile()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        pdfView.frame = self.view.frame
    }
    
    func setFileUrl(fileURL: URL) {
        self.fileURL = fileURL
    }
    
    func setupViewForPDF() {
        if let document = PDFDocument(url: fileURL!) {
            pdfView.document = document
            pdfView.autoScales = true
            pdfView.contentMode = .scaleAspectFit
        }
        self.view.addSubview(pdfView)
    }
    
    func setupViewForOtherFile() {
        let img = UIImage(contentsOfFile: fileURL.path)
        let pdfPage = PDFPage(image: img ?? UIImage())
        let pdfDoc = PDFDocument()
        pdfDoc.insert(pdfPage!, at: 0)
        let data = pdfDoc.dataRepresentation()
        let documentDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let docURL = documentDirectory.appendingPathComponent(Constants.tempPdfFileName)
        do {
            try data?.write(to: docURL)
            if let document = PDFDocument(url: docURL) {
                pdfView.document = document
                pdfView.autoScales = true
                pdfView.contentMode = .scaleAspectFit
            }
            self.view.addSubview(pdfView)
        } catch(let error){
           print("Error is \(error.localizedDescription)")
        }
    }
    
    deinit {
        let documentDirectory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let docURL = documentDirectory.appendingPathComponent(Constants.tempPdfFileName)
        do {
            if FileManager.default.fileExists(atPath: docURL.path) {
                try FileManager.default.removeItem(at: docURL)
            }
        } catch (let error) {
           print("Error is \(error.localizedDescription)")
        }
    }
}
