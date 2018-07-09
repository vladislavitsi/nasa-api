//
//  TopBar.swift
//  nasa-api
//
//  Created by Uladzislau Kleshchanka on Jul/09/2018.
//  Copyright © 2018 Uladzislau Kleshchanka. All rights reserved.
//

import UIKit

class TopBar: UIView {
    
    private let backButton = UIButton()
    private let stackView = UIStackView()
    private let fromLabel = UILabel()
    private let ofLabel = UILabel()
    private let toLabel = UILabel()
    private let optionsButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        backButton.setTitle("←", for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 7),
            backButton.topAnchor.constraint(equalTo: topAnchor),
            backButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.spacing = 7
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        fromLabel.textColor = .white
        ofLabel.textColor = .white
        toLabel.textColor = .white
        
        fromLabel.text = "1"
        fromLabel.textAlignment = .right
        ofLabel.text = "Of"
        ofLabel.textAlignment = .center
        toLabel.text = "1"
        toLabel.textAlignment = .left
        
        stackView.addArrangedSubview(fromLabel)
        stackView.addArrangedSubview(ofLabel)
        stackView.addArrangedSubview(toLabel)

        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        optionsButton.setTitle("⋮", for: .normal)
        optionsButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(optionsButton)
        NSLayoutConstraint.activate([
            optionsButton.rightAnchor.constraint(equalTo: rightAnchor, constant: 7),
            optionsButton.topAnchor.constraint(equalTo: topAnchor),
            optionsButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
