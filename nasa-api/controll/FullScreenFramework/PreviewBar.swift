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

    private var isHidden = true
    
    init() {
        let navigationItem = UINavigationItem(title: "Well...")
        let backButton = UIBarButtonItem(barButtonSystemItem: .stop, target: nil, action: nil)
        navigationItem.leftBarButtonItem = backButton
        topNavigationBar.translatesAutoresizingMaskIntoConstraints = false
        topNavigationBar.setItems([navigationItem], animated: false)
        UINavigationBar.appearance().barTintColor = UIColor.black.withAlphaComponent(0.5)
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        UIToolbar.appearance().barTintColor = .black
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        bottomNavigationBar.translatesAutoresizingMaskIntoConstraints = false
        UIApplication.shared.statusBarStyle = .lightContent
        UIApplication.shared.isStatusBarHidden = true
        hideBars()
    }
    
    func applyToFullScreenView(_ view: UIView) {
        let statusBarFillingView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 20))
        statusBarFillingView.translatesAutoresizingMaskIntoConstraints = false
        statusBarFillingView.backgroundColor = .black
        
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
            topNavigationBar.topAnchor.constraint(equalTo: statusBarFillingView.bottomAnchor),
            topNavigationBar.leadingAnchor.constraint(equalTo: statusBarFillingView.leadingAnchor),
            topNavigationBar.trailingAnchor.constraint(equalTo: statusBarFillingView.trailingAnchor)
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
    }
    
    func hideBars() {
        topNavigationBar.alpha = 0
        bottomNavigationBar.alpha = 0
        isHidden = true
    }
    
    func changeState() {
        let action = self.isHidden ? self.showUpBars : self.hideBars
        UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
            action()
        })
    }
}
