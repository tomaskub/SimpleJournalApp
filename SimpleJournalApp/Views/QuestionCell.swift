//
//  QuestionCell.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 11/13/22.
//

import UIKit

protocol QuestionCellDelegate: NSObject {
    func buttonPressed(sender: QuestionCell)
}

@IBDesignable class QuestionCell: UITableViewCell {
    
    weak var delegate: QuestionCellDelegate?
    
    static let identifier = "QuestionCell"
    @IBInspectable var buttonTitle: String = "Answer"
    // UI elements declaration
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Sample question text check"
        label.textColor = UIColor(named: "ComplementColor")
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let button: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "ComplementColor")
        button.setTitleColor(UIColor(named: "DominantColor"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor(named: "DominantColor")
        contentView.layer.cornerRadius = contentView.bounds.height * 0.5
        contentView.addSubview(label)
        contentView.addSubview(button)
        button.setTitle(buttonTitle, for: .normal)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //        Inset the content view frame of the cell
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10.0, left: 10, bottom: 10, right: 10))
        // Constraints for the label with question
        label.heightAnchor.constraint(equalToConstant: contentView.frame.height * 0.6).isActive = true
        label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentView.layer.cornerRadius).isActive = true
        label.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: 10).isActive = true
        //      Constraints for the button
        button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        //TODO: check apple HIG for the guidline on the height of the button
        button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        button.widthAnchor.constraint(equalToConstant: contentView.frame.width * 0.2).isActive = true
        //      set the corner radius for the button
        button.layer.cornerRadius = button.frame.height / 4
    }
    
    @objc func buttonPressed(){
        delegate?.buttonPressed(sender: self)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    public func configureCell(questionText: String) {
        label.text = questionText
    }

}
