//
//  SettingCell.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 11/19/22.
//

import UIKit

@IBDesignable class SettingCell: UITableViewCell {
    
    
    enum CellType {
        case withChevronRight
        case withToggleSwitch
    }
    
    static let identifier = "SettingCell"
    var cellType: CellType
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
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.cellType = .withToggleSwitch
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Define background view
        self.backgroundColor = .white
        self.layer.cornerRadius = 5
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 5
        
        
        //Set up appearance of the cell
        contentView.layer.cornerRadius = contentView.bounds.height * 0.5
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowRadius = 5.0
        label.backgroundColor = .blue
        contentView.addSubview(label)
        icon.image = UIImage(systemName: iconSystemName)
        icon.frame = CGRect(x: 0, y: 0, width: 75, height: 50)
        icon.contentMode = .scaleAspectFit
        contentView.addSubview(icon)
        //Build cell based on the cell type
        switch cellType {
        case .withChevronRight:
            addSubview(button)
            setUpConstraints(first: icon, second: label, third: button)
        case .withToggleSwitch:
            addSubview(toggleSwitch)
            setUpConstraints(first: icon, second: label, third: toggleSwitch)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configureCell(iconImage: UIImage, labelText: String){//} , buttonImage: UIImage){
        label.text = labelText
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setUpConstraints(first: UIView, second: UIView, third: UIView){
        //set up constraints for first item
        first.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        first.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10.0).isActive = true
        first.widthAnchor.constraint(equalToConstant: contentView.frame.height - 10).isActive = true
        first.heightAnchor.constraint(equalToConstant: contentView.frame.height - 10).isActive = true
        // set up constraints for second item
        second.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        second.leadingAnchor.constraint(equalTo: first.trailingAnchor, constant: 10).isActive = true
        second.widthAnchor.constraint(equalToConstant: 150).isActive = true
        second.heightAnchor.constraint(equalToConstant: contentView.frame.height - 10 ).isActive = true
        // set up constraints for third item
        third.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        third.leadingAnchor.constraint(equalTo: second.trailingAnchor).isActive = true
        third.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        third.heightAnchor.constraint(equalToConstant: contentView.frame.height).isActive = true
        
    }
}
