//
//  PreviewBar.swift
//  nasa-api
//
//  Created by Uladzislau Kleshchanka on Jul/06/2018.
//  Copyright © 2018 Uladzislau Kleshchanka. All rights reserved.
//

import UIKit


class PreviewBar {
    
    private let statusBarFillingView = UIView()
    private let topBar = TopBar()
    private let bottomBar = UIView()
    private var viewController: FullScreenImageViewController? = nil
    private var isHidden = true
    
    init() {
        statusBarFillingView.translatesAutoresizingMaskIntoConstraints = false
        statusBarFillingView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        topBar.translatesAutoresizingMaskIntoConstraints = false
        topBar.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        hideBars()
    }
    
    func applyToFullScreenView(_ viewController: FullScreenImageViewController) {
        self.viewController = viewController
        guard let view = self.viewController?.view else {
            return
        }
        view.addSubview(statusBarFillingView)
        NSLayoutConstraint.activate([
            statusBarFillingView.topAnchor.constraint(equalTo: view.topAnchor),
            statusBarFillingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statusBarFillingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statusBarFillingView.heightAnchor.constraint(equalToConstant: 20)
        ])
        statusBarFillingView.alpha = 1
        
        view.addSubview(topBar)
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: statusBarFillingView.bottomAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 44)
        ])
        view.addSubview(bottomBar)
        NSLayoutConstraint.activate([
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func showStatusBar() {
        viewController?.statusBarShouldBeHidden = false
        viewController?.setNeedsStatusBarAppearanceUpdate()
    }
    
    func showBars() {
        statusBarFillingView.alpha = 1
        topBar.alpha = 1
        bottomBar.alpha = 1
        isHidden = false
        showStatusBar()
    }
    
    func hideStatusBar() {
        viewController?.statusBarShouldBeHidden = true
        viewController?.setNeedsStatusBarAppearanceUpdate()
    }
    
    func hideBars() {
        statusBarFillingView.alpha = 0
        topBar.alpha = 0
        bottomBar.alpha = 0
        isHidden = true
        hideStatusBar()
    }
    
    func changeState() {
        let action = self.isHidden ? self.showBars : self.hideBars
        UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
            action()
        })
    }
}
