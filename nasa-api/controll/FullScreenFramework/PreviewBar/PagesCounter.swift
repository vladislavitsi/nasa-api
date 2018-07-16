//
//  PagesCouner.swift
//  nasa-api
//
//  Created by Uladzislau Kleshchanka on Jul/11/2018.
//  Copyright © 2018 Uladzislau Kleshchanka. All rights reserved.
//

import UIKit

public class PageCounter: UIStackView {
    
    private static let defaultFont = UIFont(name: "Helvetica Neue", size: 20)!
    
    let currentLabel = UILabel()
    let ofLabel = UILabel()
    let toLabel = UILabel()
    
    private var labels: [UILabel]!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        labels = [currentLabel, ofLabel, toLabel]
        
        spacing = 7
        axis = .horizontal
        alignment = .fill
        distribution = .fillEqually
        
        currentLabel.text = "1"
        currentLabel.textAlignment = .right
        ofLabel.text = "Of"
        ofLabel.textAlignment = .center
        toLabel.text = "1"
        toLabel.textAlignment = .left
        
        labels.forEach { label in
            label.font = PageCounter.defaultFont
            label.textColor = .white
            addArrangedSubview(label)
        }
    }
    
    func setCurrent(number: String) {
        currentLabel.text = number
    }
}
