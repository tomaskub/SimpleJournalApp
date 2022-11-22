//
//  SettingCell.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 11/19/22.
//

import UIKit

@IBDesignable class SettingCell: UITableViewCell {
    
    
    enum CellButtonType {
        case withChevronRight
        case withToggleSwitch
    }
    
    static let identifier = "SettingCell"
    var cellButtonType: CellButtonType
    var iconSystemName: String = "key.horizontal"
    
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
        view.image = UIImage(systemName: "multiply.circle")
        return view
    }()
    private let button: UIButton = {
       let button = UIButton()
//        button.setTitle("button", for: .normal)
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    private let cellContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.cellButtonType = .withChevronRight
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //Set up appearance of the cell
        
        //set up background color and corner radius
        cellContentView.layer.cornerRadius = contentView.frame.height * 0.5
        cellContentView.backgroundColor = UIColor(named: "ComplementColor")
        //set up shadow
        cellContentView.layer.shadowOffset = .zero
        cellContentView.layer.shadowColor = UIColor.black.cgColor
        cellContentView.layer.shadowRadius = 2.0
        cellContentView.layer.shadowOpacity = 0.5
        // set up constraints for cellContentView
        //TODO: add logic to change icon in the view
        //Setup icon image
        icon.image = UIImage(systemName: iconSystemName)
        icon.contentMode = .scaleAspectFit
        
        // add subviews
        contentView.addSubview(cellContentView)
        cellContentView.addSubview(label)
        cellContentView.addSubview(icon)
        //Build cell based on the cell type
        switch cellButtonType {
        case .withChevronRight:
            cellContentView.addSubview(button)
            setUpConstraints(first: icon, second: label, third: button)
        case .withToggleSwitch:
            cellContentView.addSubview(toggleSwitch)
            setUpConstraints(first: icon, second: label, third: toggleSwitch)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
//    TODO: remove bug with cell type not properly updating UI elements
    func configureCell(iconSystemName: String, labelText: String, cellType: CellButtonType){//} , buttonImage: UIImage){
        label.text = labelText
        icon.image = UIImage(systemName: iconSystemName)
        cellButtonType = cellType
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
        cellContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        cellContentView.topAnchor.constraint(equalTo: contentView.topAnchor, constant:  5).isActive = true
        cellContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
        cellContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        //set up constraints for first item
        first.centerYAnchor.constraint(equalTo: cellContentView.centerYAnchor).isActive = true
        first.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor, constant: 10.0).isActive = true
        first.widthAnchor.constraint(equalToConstant: contentView.frame.height - 10).isActive = true
        first.heightAnchor.constraint(equalToConstant: contentView.frame.height - 10).isActive = true
        // set up constraints for second item
        second.centerYAnchor.constraint(equalTo: cellContentView.centerYAnchor).isActive = true
        second.leadingAnchor.constraint(equalTo: first.trailingAnchor, constant: 10).isActive = true
        second.widthAnchor.constraint(equalToConstant: 150).isActive = true
        second.heightAnchor.constraint(equalToConstant: contentView.frame.height - 10 ).isActive = true
        // set up constraints for third item
        third.centerYAnchor.constraint(equalTo: cellContentView.centerYAnchor).isActive = true
//        third.leadingAnchor.constraint(equalTo: second.trailingAnchor).isActive = true
        third.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor, constant: -10).isActive = true
        third.heightAnchor.constraint(equalToConstant: contentView.frame.height).isActive = true
        
    }
}
