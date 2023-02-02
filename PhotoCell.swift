//
//  PhotoCell.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 2/2/23.
//

import Foundation
import UIKit

class PhotoCell: TableCell {
    
    var isPresentingImage: Bool = false
    
    override static var identifier: String {
        return "PhotoCell"
    }
    
    let photoView: UIImageView = {
       let view = UIImageView()
        return view
    }()
    func setUpWithLabel(text: String) {
        self.configureCell(with: text)
    }
    func setUpWithPhoto(image: UIImage) {
        
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        if isPresentingImage == false {
            setUpWithLabel(text: "Placeholder")
        } else {
            
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
