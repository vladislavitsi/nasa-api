//
//  PreviewBar.swift
//  nasa-api
//
//  Created by Uladzislau Kleshchanka on Jul/06/2018.
//  Copyright © 2018 Uladzislau Kleshchanka. All rights reserved.
//

import UIKit


public class PreviewBar {
    
    weak var delegate: PreviewBarDelegate?
    private let statusBarFillingView = UIView()
    private let topBar = TopBar()
    private let bottomBar = BottomBar()
    private var isHidden = true
    
    init(on superview: UIView) {
        statusBarFillingView.translatesAutoresizingMaskIntoConstraints = false
        statusBarFillingView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        topBar.view.translatesAutoresizingMaskIntoConstraints = false
        topBar.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        topBar.previewBar = self
        topBar.delegate = self
        
        hideBars()
        
        superview.addSubview(statusBarFillingView)
        NSLayoutConstraint.activate([
            statusBarFillingView.topAnchor.constraint(equalTo: superview.topAnchor),
            statusBarFillingView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            statusBarFillingView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            statusBarFillingView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        superview.addSubview(topBar.view)
        NSLayoutConstraint.activate([
            topBar.view.topAnchor.constraint(equalTo: statusBarFillingView.bottomAnchor),
            topBar.view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            topBar.view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            topBar.view.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        superview.addSubview(bottomBar.view)
        NSLayoutConstraint.activate([
            bottomBar.view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            bottomBar.view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            bottomBar.view.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            bottomBar.view.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        if let pageCount = delegate?.imageCount() {
            topBar.pageCounter.toLabel.text = String(pageCount)            
        }
    }
    
    func showBars(animated: Bool = false) {
        let action = { [unowned self] in
            self.statusBarFillingView.alpha = 1
            self.topBar.view.alpha = 1
            self.bottomBar.view.alpha = 1
            self.isHidden = false
            self.delegate?.setStatusBar(isHidden: false)
        }
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
                action()
            })
        } else {
            action()
        }
    }
    
    func hideBars(animated: Bool = false) {
        let action = { [unowned self] in
            self.statusBarFillingView.alpha = 0
            self.topBar.view.alpha = 0
            self.bottomBar.view.alpha = 0
            self.isHidden = true
            self.delegate?.setStatusBar(isHidden: true)
        }
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
                action()
            })
        } else {
            action()
        }
    }
    
    func changeState() {
        let action = self.isHidden ? self.showBars : self.hideBars
        action(true)
    }
}

extension PreviewBar: PreviewBarInteface {
    public var topBarView: UIView {
        return topBar.view
    }
    
    public var bottomBarView: UIView {
        return bottomBar.view
    }
    
    public var currentCounterLabel: UILabel {
        return topBar.pageCounter.currentLabel
    }
    
    public var ofCounterLabel: UILabel {
        return topBar.pageCounter.ofLabel
    }
    
    public var toCounterLabel: UILabel {
        return topBar.pageCounter.toLabel
    }
    
    public var backButton: UIButton {
        return topBar.backButton
    }
    
    public var actionButton: UIButton {
        return topBar.actionButton
    }
    
    public func didChangePage() {
        if let newValue = delegate?.currentImageNumber() {
            topBar.pageCounter.setCurrent(number: String(newValue))
        }
    }
    
    public func set(actionSheet: UIAlertController) {
//        topBar.actionButton
    }
    
    public func setPreviewBar(isHidden: Bool) {
        isHidden ? hideBars() : showBars()
    }
}

extension PreviewBar: TopBarDelegate {
    func backButtonPressed() {
        delegate?.backButtonPressed()
    }
    
    func actionButtonPressed() {
        delegate?.actionButtonPressed()
    }
}
