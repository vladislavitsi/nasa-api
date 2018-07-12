//
//  PagesCouner.swift
//  nasa-api
//
//  Created by Uladzislau Kleshchanka on Jul/11/2018.
//  Copyright © 2018 Uladzislau Kleshchanka. All rights reserved.
//

import UIKit

public class PageCounter: UIStackView {
    
    private static let defaultFont = UIFont(name: "Helvetica Neue", size: 20)
    
    private let fromLabel = UILabel()
    private let ofLabel = UILabel()
    private let toLabel = UILabel()
    
    private var labels: [UILabel]!
    
    public var font: UIFont {
        get {
            return labels.first!.font
        }
        set {
            labels.forEach { $0.font = newValue }
        }
    }
    
    public var textColor: UIColor {
        get {
            return labels.first!.textColor
        }
        set {
            labels.forEach { $0.textColor = newValue }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        labels = [fromLabel, ofLabel, toLabel]
        
        spacing = 7
        axis = .horizontal
        alignment = .fill
        distribution = .fillEqually
        
        font = PageCounter.defaultFont!
        
        fromLabel.textColor = .white
        ofLabel.textColor = .white
        toLabel.textColor = .white
        
        fromLabel.text = "1"
        fromLabel.textAlignment = .right
        ofLabel.text = "Of"
        ofLabel.textAlignment = .center
        toLabel.text = "1"
        toLabel.textAlignment = .left
        
        addArrangedSubview(fromLabel)
        addArrangedSubview(ofLabel)
        addArrangedSubview(toLabel)
    }
}
