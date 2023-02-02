//
//  TableCell.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 2/2/23.
//

import UIKit

class TableCell: UITableViewCell {
    
    
    
    class var identifier: String {
        return "TableCell"
    } 
    
    
    let label: UILabel = {
        let label = UILabel()
        label.text = "Sample cell text check"
        label.textColor = UIColor(named: "ComplementColor")
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor(named: "DominantColor")
        contentView.layer.cornerRadius = contentView.bounds.height * 0.5
        contentView.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //        Inset the content view frame of the cell
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10.0, left: 10, bottom: 10, right: 10))
        // Constraints for the label with question
        label.heightAnchor.constraint(equalToConstant: contentView.frame.height * 0.6).isActive = true
        label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
//        label.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -2 * contentView.layer.cornerRadius).isActive = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    public func configureCell(with text: String) {
        label.text = text
    }
}
