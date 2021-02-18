//
//  DownloadedRollTableViewCell.swift
//  TestSMB
//
//  Created by iOS on 12/1/20.
//  Copyright © 2020 Tran Ngoc Tam. All rights reserved.
//

import UIKit

class DownloadedRollTableViewCell: UITableViewCell {

    @IBOutlet weak var rollImage: UIImageView!
    @IBOutlet weak var rollName: UILabel!
    @IBOutlet weak var rollDate: UILabel!
    @IBOutlet weak var rollSize: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configCell(file: File) {
        rollName.text = file.name ?? ""
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        rollDate.text = formatter.string(from: file.modified ?? Date())
        configRollSize(size: file.size ?? 0)
        setRollImage(name: file.name ?? "")
    }
    
    private func configRollSize(size: Int64) {
        if size > 0 && size <= Constants.byteSize {
            rollSize.text = "\(Float(size)) \(Constants.byteText)"
        } else if size > Constants.byteSize && size <= Constants.kilobyteSize {
            let sizeRounded = (Float(size) / Float(Constants.byteSize))
            rollSize.text = "\(String(format: "%.2f", sizeRounded)) \(Constants.kilobyteText)"
        } else {
            let sizeRounded = (Float(size) / Float(Constants.kilobyteSize))
            rollSize.text = "\(String(format: "%.2f", sizeRounded)) \(Constants.megabyteText)"
        }
    }
    
    private func setRollImage(url: URL) {
        let fileExtension = url.pathExtension
        if fileExtension == Constants.pdfFileExtension {
            let image = UIImage(named: Constants.pdfThumbnailIcon)
            rollImage.image = image
        } else if fileExtension == Constants.iwbFileExtension {
            let image = UIImage(named: Constants.iwbThumbnailIcon)
            rollImage.image = image
        }
    }
    
    private func setRollImage(name: String) {
        let fileExtension = name.components(separatedBy: ".").last
        if fileExtension == Constants.pdfFileExtension {
            let image = UIImage(named: Constants.pdfThumbnailIcon)
            rollImage.image = image
        } else if fileExtension == Constants.iwbFileExtension {
            let image = UIImage(named: Constants.iwbThumbnailIcon)
            rollImage.image = image
        }
    }
}
