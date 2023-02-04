//
//  PhotoCell.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 2/2/23.
//

import Foundation
import UIKit

class PhotoCell: UITableViewCell {
    
    
    
    let identifier = "PhotoCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
