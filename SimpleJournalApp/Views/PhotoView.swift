//
//  PhotoView.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 2/4/23.
//

import UIKit

class PhotoView: UIView {
    
    private let spacing: CGFloat = 10
    
    private var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = ContentMode.scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: K.Colors.complement)
        label.font = UIFont.systemFont(ofSize: 17)
        label.text = "Photo of the day"
        return label
    }()
    
    let leftButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: "ComplementColor")
        button.setTitleColor(UIColor(named: "DominantColor"), for: .normal)
        button.setTitle("Change", for: .normal)
        return button
    }()
    
    let rightButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "ComplementColor")
        button.setTitleColor(UIColor(named: "DominantColor"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Delete", for: .normal)
        return button
    }()
    
    let centerButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: "ComplementColor")
        button.setTitleColor(UIColor(named: "DominantColor"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add photo", for: .normal)
        return button
    }()
    
    
    fileprivate func addSubviews() {
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(leftButton)
        addSubview(rightButton)
        addSubview(centerButton)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(named: K.Colors.dominant)
        addSubviews()
    }
    
    override func layoutSubviews() {
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: spacing),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -spacing),
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: spacing),
            imageView.heightAnchor.constraint(equalTo: widthAnchor)
        ])
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: spacing),
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)])
        if leftButton.superview != nil {
        NSLayoutConstraint.activate([
            leftButton.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: spacing),
            leftButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: spacing),
            leftButton.trailingAnchor.constraint(equalTo: imageView.centerXAnchor, constant: -spacing),
            leftButton.heightAnchor.constraint(equalToConstant: 55)])
        }
        if rightButton.superview != nil {
            NSLayoutConstraint.activate([
                rightButton.leadingAnchor.constraint(equalTo: imageView.centerXAnchor, constant: spacing),
                rightButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: spacing),
                rightButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -spacing),
                rightButton.heightAnchor.constraint(equalToConstant: 55)])
        }
        if centerButton.superview != nil {
            NSLayoutConstraint.activate([
                centerButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                centerButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                centerButton.heightAnchor.constraint(equalToConstant: 55),
                centerButton.widthAnchor.constraint(equalToConstant: (self.frame.width) / 2 - 4 * spacing)])
        }
        imageView.layer.cornerRadius = 10
        leftButton.layer.cornerRadius = 10
        rightButton.layer.cornerRadius = 10
        centerButton.layer.cornerRadius = 10
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(_ image: UIImage?) {
        imageView.image = image
        
    }
    
}
