//
//  TopBar.swift
//  nasa-api
//
//  Created by Uladzislau Kleshchanka on Jul/09/2018.
//  Copyright © 2018 Uladzislau Kleshchanka. All rights reserved.
//

import UIKit

public class TopBar: UIView {
    
    weak var previewBar: PreviewBar?
    
    private let backButton = UIButton()
    private let pageCounter = PageCounter()
    public let optionsButton = UIButton(type: UIButtonType.custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        //backButton.setTitle("←", for: .normal)
        backButton.setImage(UIImage(named: "Back arrow"), for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 7),
            backButton.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            backButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor, multiplier: 1)
        ])
        backButton.addTarget(self, action: #selector(backButtonPressed(_:)), for: .touchUpInside)
        
        pageCounter.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(pageCounter)
        NSLayoutConstraint.activate([
            pageCounter.topAnchor.constraint(equalTo: topAnchor),
            pageCounter.bottomAnchor.constraint(equalTo: bottomAnchor),
            pageCounter.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        optionsButton.setImage(UIImage(named: "Kebab menu"), for: .normal)
        optionsButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(optionsButton)
        NSLayoutConstraint.activate([
            optionsButton.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
            optionsButton.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            optionsButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            optionsButton.widthAnchor.constraint(equalTo: optionsButton.heightAnchor, multiplier: 1)
        ])
        
        optionsButton.addTarget(self, action: #selector(pressed), for: .touchUpInside)
    }
    
    @objc func pressed() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        actionSheet.addAction(cancelAction)
        previewBar?.showActionSheet(actionSheet)
    }
    
    @objc func backButtonPressed(_ button: UIButton) {
        previewBar?.backButtonPressed(button)
    }
    
}
