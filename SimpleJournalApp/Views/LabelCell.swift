//
//  TableCell.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 2/2/23.
//

import UIKit

class LabelCell: UITableViewCell {
    
    static let identifier = "LabelCell"
    var constraintsWithoutImage: [NSLayoutConstraint] = []
    var cornerRadius: CGFloat = 10
    
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
        contentView.addSubview(label)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func initConstraints() {
        let height = contentView.frame.height
        
        
        constraintsWithoutImage = []
        
        
        constraintsWithoutImage = [
            
            
        ]
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5.0, left: 10, bottom: 5, right: 10))
        contentView.layer.cornerRadius = cornerRadius
        NSLayoutConstraint.activate(
            [label.heightAnchor.constraint(equalToConstant: contentView.frame.height * 0.6),
             label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
             label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)])
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    public func configureCell(with text: String) {
        label.text = text
    }
}
