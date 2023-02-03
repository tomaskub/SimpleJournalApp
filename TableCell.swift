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
    
    var constraintsWithImage: [NSLayoutConstraint]?
    var constraintsWithoutImage: [NSLayoutConstraint]?
    
    let label: UILabel = {
        let label = UILabel()
        label.text = "Sample cell text check"
        label.textColor = UIColor(named: "ComplementColor")
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let myImageView: UIImageView = {
       let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initConstraints()
        
        contentView.backgroundColor = UIColor(named: "DominantColor")
        contentView.layer.cornerRadius = contentView.bounds.height * 0.5
        contentView.addSubview(label)
        contentView.addSubview(myImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func initConstraints() {
        
        constraintsWithImage = [
            myImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -contentView.frame.width / 7 - 10),
            myImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            myImageView.widthAnchor.constraint(equalToConstant: contentView.frame.width - 20),
            myImageView.heightAnchor.constraint(equalToConstant: 6 * contentView.frame.height / 7),
            label.topAnchor.constraint(equalTo: myImageView.bottomAnchor, constant: 10),
            label.heightAnchor.constraint(equalToConstant: contentView.frame.height * 0.85),
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ]
        constraintsWithoutImage = [
            label.heightAnchor.constraint(equalToConstant: contentView.frame.height * 0.6),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ]
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        //        Inset the content view frame of the cell
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10.0, left: 10, bottom: 10, right: 10))
        if let cwoi = constraintsWithoutImage, let cwi = constraintsWithImage {
            if myImageView.image != nil {
                NSLayoutConstraint.deactivate(cwoi)
                NSLayoutConstraint.activate(cwi)
            } else {
                NSLayoutConstraint.deactivate(cwi)
                NSLayoutConstraint.activate(cwoi)
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        myImageView.image = nil
        
    }
    public func configureCell(with text: String) {
        label.text = text
    }
}
