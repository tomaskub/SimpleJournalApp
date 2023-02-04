//
//  PhotoCell.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 2/2/23.
//

import Foundation
import UIKit

protocol PhotoCellDelegate {
    func leftButtonTapped()
    func rightButtonTapped()
}

class PhotoCell: UITableViewCell {
    
    
    
    static let identifier = "PhotoCell"
    var cornerRadius: CGFloat = 10
    var delegate: PhotoCellDelegate?
    
    let myImageView: UIImageView = {
       let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = ContentMode.scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    private let leftButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "ComplementColor")
        button.setTitleColor(UIColor(named: "DominantColor"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Change", for: .normal)
        button.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)
        return button
    }()
    private let rightButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "ComplementColor")
        button.setTitleColor(UIColor(named: "DominantColor"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Delete", for: .normal)
        button.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func rightButtonTapped(){
        delegate?.rightButtonTapped()
    }
    @objc func leftButtonTapped(){
        delegate?.leftButtonTapped()
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor(named: "DominantColor")
        
        contentView.addSubview(myImageView)
        contentView.addSubview(leftButton)
        contentView.addSubview(rightButton)
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5.0, left: 10, bottom: 5, right: 10))

        let height = contentView.frame.height
        let inset = height * 0.04
        
        NSLayoutConstraint.activate([
                myImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
                myImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
                myImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
                leftButton.leadingAnchor.constraint(equalTo: myImageView.leadingAnchor),
                leftButton.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -inset),
                rightButton.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: inset),
                rightButton.trailingAnchor.constraint(equalTo: myImageView.trailingAnchor),
                leftButton.topAnchor.constraint(equalTo: myImageView.bottomAnchor, constant: inset),
                rightButton.topAnchor.constraint(equalTo: myImageView.bottomAnchor, constant: inset),
                leftButton.heightAnchor.constraint(equalToConstant: height * 0.12),
                rightButton.heightAnchor.constraint(equalToConstant: height * 0.12),
                leftButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset),
                rightButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset)
            ])
        contentView.layer.cornerRadius = cornerRadius
        for view in [myImageView, leftButton, rightButton] {
            view.layer.cornerRadius = contentView.layer.cornerRadius - 10
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        myImageView.image = nil
    }
    
}
