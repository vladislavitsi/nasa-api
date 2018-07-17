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
    func setStatusBar(isHidden: Bool)
}

public protocol FullScreenImagePreviewPublicInteface {
    var topBarView: UIView { get }
    var bottomBarView: UIView { get }
    var currentCounterLabel: UILabel { get }
    var ofCounterLabel: UILabel { get }
    var toCounterLabel: UILabel { get }
    var backButton: UIButton { get }
    var actionButton: UIButton { get }
    
    func setPreviewBar(isHidden: Bool)
}
