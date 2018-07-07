//
//  PreviewBar.swift
//  nasa-api
//
//  Created by Uladzislau Kleshchanka on Jul/06/2018.
//  Copyright © 2018 Uladzislau Kleshchanka. All rights reserved.
//

import UIKit


class PreviewBar {
    
    private let topNavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
    private let bottomNavigationBar = UIToolbar()
    private var viewController: FullScreenImageViewController?
    private var isHidden = true
    
    init() {
        viewController = nil
        let navigationItem = UINavigationItem(title: "Well...")
        let backButton = UIBarButtonItem(barButtonSystemItem: .stop, target: nil, action: nil)
        navigationItem.leftBarButtonItem = backButton
        topNavigationBar.translatesAutoresizingMaskIntoConstraints = false
        topNavigationBar.setItems([navigationItem], animated: false)
        UINavigationBar.appearance().barTintColor = UIColor.black.withAlphaComponent(0.5)
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        UIToolbar.appearance().barTintColor = .black
        bottomNavigationBar.translatesAutoresizingMaskIntoConstraints = false
        hideBars()
    }
    
    func applyToFullScreenView(_ viewController: FullScreenImageViewController) {
        let statusBarFillingView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 20))
        statusBarFillingView.translatesAutoresizingMaskIntoConstraints = false
        statusBarFillingView.backgroundColor = .black
        self.viewController = viewController
        guard let view = self.viewController?.view else {
            return
        }
        view.addSubview(statusBarFillingView)
        NSLayoutConstraint.activate([
            statusBarFillingView.topAnchor.constraint(equalTo: view.topAnchor),
            statusBarFillingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statusBarFillingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statusBarFillingView.heightAnchor.constraint(equalToConstant: 0)
            ])
        statusBarFillingView.alpha = 0
        
        view.addSubview(topNavigationBar)
        NSLayoutConstraint.activate([
            topNavigationBar.topAnchor.constraint(equalTo: view.bottomAnchor),
            topNavigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topNavigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        view.addSubview(bottomNavigationBar)
        NSLayoutConstraint.activate([
            bottomNavigationBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomNavigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomNavigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
    }
    
    func showUpBars() {
        topNavigationBar.alpha = 1
        bottomNavigationBar.alpha = 1
        isHidden = false
        viewController?.statusBarShouldBeHidden = false
        viewController?.setNeedsStatusBarAppearanceUpdate()
    }
    
    func hideBars() {
        topNavigationBar.alpha = 0
        bottomNavigationBar.alpha = 0
        isHidden = true
        viewController?.statusBarShouldBeHidden = true
        viewController?.setNeedsStatusBarAppearanceUpdate()
    }
    
    func changeState() {
        let action = self.isHidden ? self.showUpBars : self.hideBars
        UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
            action()
        })
    }
}
