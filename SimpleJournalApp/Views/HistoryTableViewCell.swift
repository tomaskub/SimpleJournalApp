//
//  HistoryTableViewCell.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 12/29/22.
//

import UIKit

@IBDesignable class HistoryTableViewCell: UITableViewCell {
    
    static let identifier = "HistoryCell"
    
    @IBInspectable var numberOfSummaryLines: Int = 3
    
    //MARK: UI element declaration
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Placeholder date"
        label.textColor = UIColor(named: K.Colors.complement)
        label.numberOfLines = 1
        return label
    }()
    private let summaryTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainer.maximumNumberOfLines = 3
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.isEditable = false
        textView.isSelectable = false 
        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor(named: K.Colors.dominant)
        textView.textColor = UIColor(named: K.Colors.complement)
        textView.contentMode = .topLeft
        return textView
    }()
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: K.Colors.dominant)
        view.layer.cornerRadius = 10
        return view
    }()
    
    private var myConstraints: [NSLayoutConstraint] = []
        
    
    //MARK: Initializers
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(containerView)
        containerView.addSubview(dateLabel)
        containerView.addSubview(summaryTextView)
        
        myConstraints = [
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            dateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            summaryTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            summaryTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            summaryTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            summaryTextView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)

        ]
        for constraint in myConstraints {
            constraint.priority = UILayoutPriority(750)
        }
        NSLayoutConstraint.activate(myConstraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configureCell(date: String, summary: String) {
        dateLabel.text = date
        summaryTextView.text = summary
    }
}
