//
//  TopBar.swift
//  nasa-api
//
//  Created by Uladzislau Kleshchanka on Jul/09/2018.
//  Copyright © 2018 Uladzislau Kleshchanka. All rights reserved.
//

import UIKit

class TopBar: AbstractBar {
    
    weak var previewBar: PreviewBar?
    weak var delegate: TopBarDelegate?
    
    let backButton = UIButton()
    let pageCounter = PageCounter()
    let actionButton = UIButton(type: UIButtonType.custom)
    
    override init() {
        super.init()
        backButton.setImage(UIImage(named: "Back arrow"), for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 7),
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            backButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5),
            backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor, multiplier: 1)
        ])
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        
        pageCounter.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(pageCounter)
        NSLayoutConstraint.activate([
            pageCounter.topAnchor.constraint(equalTo: view.topAnchor),
            pageCounter.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pageCounter.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        actionButton.setImage(UIImage(named: "Kebab menu"), for: .normal)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(actionButton)
        NSLayoutConstraint.activate([
            actionButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            actionButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            actionButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5),
            actionButton.widthAnchor.constraint(equalTo: actionButton.heightAnchor, multiplier: 1)
        ])
        
        actionButton.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
    }
    
    @objc func actionButtonPressed() {
        delegate?.actionButtonPressed()
    }
    
    @objc func backButtonPressed() {
        delegate?.backButtonPressed()
    }
    
}


