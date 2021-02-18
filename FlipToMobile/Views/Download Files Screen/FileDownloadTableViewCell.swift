//
//  FileDownloadTableViewCell.swift
//  TestSMB
//
//  Created by iOS on 12/4/20.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import UIKit

class FileDownloadTableViewCell: UITableViewCell {

    
    @IBOutlet weak var fileTypeImange: UIImageView!
    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var selectImange: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configCell(file: File) {
        fileName.text = file.name
        setRollImage(fileName: file.path ?? "")
    }
    
    func setRollImage(fileName: String) {
        let fileExtension = fileName.components(separatedBy: ".").last
        if fileExtension == Constants.pdfFileExtension {
            fileTypeImange.image = UIImage(named: Constants.pdfThumbnailIcon)
        } else if fileExtension == Constants.iwbFileExtension {
            fileTypeImange.image = UIImage(named: Constants.iwbThumbnailIcon)
        }
    }
    
}
