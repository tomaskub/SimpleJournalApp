//
//  ReminderTableViewCell.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 2/11/23.
//

import UIKit

protocol ReminderTableViewCellDelegate {
    func doneButtonTapped(sender: ReminderTableViewCell)
}

class ReminderTableViewCell: LabelCell {

    override class var identifier: String { return "ReminderCell" }
    var delegate: ReminderTableViewCellDelegate?
    
    let doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor(named: K.Colors.complement)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func doneButtonTapped() {
        delegate?.doneButtonTapped(sender: self)
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(doneButton)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            doneButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            doneButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            doneButton.heightAnchor.constraint(equalToConstant: contentView.bounds.height - 10)
        ])
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateDoneButtonConfiguration(for reminder: Reminder) {
        let symbolName = reminder.isComplete ? "circle.fill" : "circle"
//        self.doneButton.setImage(nil, for: .normal)
        let image = UIImage(systemName: symbolName)
        self.doneButton.setImage(image, for: .normal)
    }
    

}
