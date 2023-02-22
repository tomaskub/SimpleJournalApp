//
//  DetailReminderTableViewCell.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 2/9/23.
//

import UIKit

protocol DetailTableViewCellDelegate {
    func pickerEditingDidEnd(sender: DetailTableViewCell)
}

class DetailTableViewCell: UITableViewCell {

    static let identifier: String = "DetailTableViewCell"
    
    enum CellType {
        case withTextField
        case withPicker
    }
    
    var cellType: CellType
    var delegate: DetailTableViewCellDelegate?
    
    let textField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "text Field Placeholder"
        view.backgroundColor = .gray
        return view
    }()
    
    let picker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
//        picker.datePickerMode = .date
        picker.backgroundColor = .gray
        return picker
    }()
    private let icon: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .black
        view.image = UIImage(systemName: "multiply.circle")
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.cellType = .withTextField
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /* Updateconfig for state method - not implemented properly
    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        
        var contentConfig = defaultContentConfiguration().updated(for: state)
        contentConfig.text = "Hello World"
        contentConfig.image = UIImage(systemName: "bell")
        
        var backgroundConfig = backgroundConfiguration?.updated(for: state)
        backgroundConfig?.backgroundColor = .purple
        
        if state.isHighlighted || state.isSelected {
            backgroundConfig?.backgroundColor = .orange
            contentConfig.textProperties.color = .red
            contentConfig.imageProperties.tintColor = .yellow
        }
        contentConfiguration = contentConfig
        backgroundConfiguration = backgroundConfig
    }
     */

}
