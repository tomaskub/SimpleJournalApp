//
//  TableCell.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 2/2/23.
//

import UIKit

class LabelCell: UITableViewCell {
    
    
    
    let identifier = "TableCell"
    
    
    var isShowingImage: Bool = false
    
    
    var constraintsWithImage: [NSLayoutConstraint] = []
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
    
    let myImageView: UIImageView = {
       let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = ContentMode.scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor(named: "DominantColor")
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
        let height = contentView.frame.height
        
        constraintsWithImage = []
        constraintsWithoutImage = []
        
        constraintsWithImage = [
            myImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            myImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            myImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
//            myImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -140 ),
            label.topAnchor.constraint(equalTo: myImageView.bottomAnchor, constant: height * 0.04) ,
            label.heightAnchor.constraint(equalToConstant: height * 0.12),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -height * 0.04),
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ]
        
        constraintsWithoutImage = [
            myImageView.widthAnchor.constraint(equalToConstant: 0),
            myImageView.heightAnchor.constraint(equalToConstant: 0),
            label.heightAnchor.constraint(equalToConstant: contentView.frame.height * 0.6),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ]
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5.0, left: 10, bottom: 5, right: 10))
        
//        if constraintsWithImage.isEmpty || constraintsWithoutImage.isEmpty {
            initConstraints()
//        }
        
            if isShowingImage {
                NSLayoutConstraint.deactivate(constraintsWithoutImage)
                NSLayoutConstraint.activate(constraintsWithImage)
            } else {
                NSLayoutConstraint.deactivate(constraintsWithImage)
                NSLayoutConstraint.activate(constraintsWithoutImage)
            }
        contentView.layer.cornerRadius = cornerRadius
        myImageView.layer.cornerRadius = contentView.layer.cornerRadius - 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        myImageView.image = nil
        isShowingImage = false
        
    }
    public func configureCell(with text: String) {
        label.text = text
    }
}
