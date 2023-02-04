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
    
    private let inset: CGFloat = 10
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(named: K.Colors.dominant)
        addSubview(imageView)
    }
    
    override func layoutSubviews() {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: inset),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -inset),
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(_ image: UIImage) {
        imageView.image = image
    }
    
}
