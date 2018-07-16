//
//  PreviewBarProtocol.swift
//  nasa-api
//
//  Created by Uladzislau Kleshchanka on Jul/16/2018.
//  Copyright © 2018 Uladzislau Kleshchanka. All rights reserved.
//

import UIKit

protocol PreviewBarDelegate: class {
    func backButtonPressed()
    func actionButtonPressed()
    func imageCount() -> Int
    func currentImageNumber() -> Int
    func setStatusBar(isHidden: Bool)
}

public protocol PreviewBarInteface {
    var topBarView: UIView { get }
    var bottomBarView: UIView { get }
    var currentCounterLabel: UILabel { get }
    var ofCounterLabel: UILabel { get }
    var toCounterLabel: UILabel { get }
    var backButton: UIButton { get }
    var actionButton: UIButton { get }
    
    func didChangePage()
    func set(actionSheet: UIAlertController)
    func setPreviewBar(isHidden: Bool)
}

protocol TopBarDelegate: class {
    func backButtonPressed()
    func actionButtonPressed()
}
