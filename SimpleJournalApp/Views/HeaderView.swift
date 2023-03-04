//
//  HeaderView.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 3/2/23.
//

import UIKit

class HeaderView: UITableViewHeaderFooterView {
    
    static let identifier = "HeaderFooterView"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    let plusButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(systemName: "plus.circle")
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(named: K.Colors.dominant)
        button.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        return button
    }()
    
    let chevronButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(systemName: "chevron.up")
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(named: K.Colors.dominant)
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layoutUI() {
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(plusButton)
        contentView.addSubview(chevronButton)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            plusButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            plusButton.heightAnchor.constraint(equalToConstant: 28),
            plusButton.widthAnchor.constraint(equalTo: plusButton.heightAnchor),
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            chevronButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronButton.heightAnchor.constraint(equalToConstant: 28),
            chevronButton.trailingAnchor.constraint(equalTo: plusButton.leadingAnchor, constant: -20),
            chevronButton.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -68)
        ])
        
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
