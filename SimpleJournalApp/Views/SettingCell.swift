//
//  SettingCell.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 11/19/22.
//

import UIKit

@IBDesignable class SettingCell: UITableViewCell {
    
    
    enum iconType {
        case clock
        case book
        case calendar
    }
    
    static let identifier = "SettingCell"
    
    @IBInspectable var iconSystemName: String = "key.horizontal"
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Sample Setting"
        label.textColor = .black // UIColor(named: "ComplementColor")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let icon: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .black
        return view
    }()
    private let button: UIButton = {
       let button = UIButton()
        button.setTitle("button", for: .normal)
        button.setImage(UIImage(systemName: "book"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.layer.cornerRadius = 5
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 5
        
        
//        contentView.backgroundColor = .red //UIColor(named: "ComplementColor")
        //Set up appearance of the cell
        contentView.layer.cornerRadius = contentView.bounds.height * 0.5
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowRadius = 5.0
        label.backgroundColor = .blue
        contentView.addSubview(label)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        contentView.addSubview(button)
        icon.frame = CGRect(x: 0, y: 0, width: 75, height: 50)
        icon.contentMode = .scaleAspectFit
//        icon.image = UIImage(systemName: iconSystemName)
        contentView.addSubview(icon)
        addSubview(toggleSwitch)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //Icon view contraints
        
        icon.image = UIImage(systemName: iconSystemName)
        icon.heightAnchor.constraint(equalToConstant: contentView.frame.height - 10).isActive = true
        icon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        icon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        icon.widthAnchor.constraint(equalToConstant: icon.frame.height).isActive = true
        
        //Label title view contraints
        label.heightAnchor.constraint(equalToConstant: contentView.frame.height - 10 ).isActive = true
        label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10).isActive = true
        label.widthAnchor.constraint(equalToConstant: 150).isActive = true
        label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        // button constraints
        button.heightAnchor.constraint(equalToConstant: contentView.frame.height - 10).isActive = true
        button.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10).isActive = true
        button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
//        button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 50).isActive = true
        
        toggleSwitch.leadingAnchor.constraint(equalTo: button.trailingAnchor).isActive = true
        toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
    }
    func configureCell(iconImage: UIImage, labelText: String){//} , buttonImage: UIImage){
        label.text = labelText
//        icon.image = iconImage
        
        
//        button.imageView?.image = buttonImage
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
