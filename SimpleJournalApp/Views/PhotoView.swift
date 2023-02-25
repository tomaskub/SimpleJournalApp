//
//  PhotoView.swift
//  SimpleJournalApp
//
//  Created by Tomasz Kubiak on 2/4/23.
//

import UIKit

class PhotoView: UIView {
    
    private var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = ContentMode.scaleAspectFit
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
    
    private let inset: CGFloat = 10
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(named: K.Colors.dominant)
        addSubview(imageView)
        addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: inset),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -inset),
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: inset),
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)])
        imageView.layer.cornerRadius = 10
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(_ image: UIImage) {
        imageView.image = image
        
    }
    
}
