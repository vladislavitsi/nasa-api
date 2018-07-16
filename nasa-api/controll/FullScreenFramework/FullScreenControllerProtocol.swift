//
//  FullScreenControllerProtocol.swift
//  nasa-api
//
//  Created by Uladzislau Kleshchanka on Jul/13/2018.
//  Copyright © 2018 Uladzislau Kleshchanka. All rights reserved.
//

import UIKit

protocol FullScreenControllerProtocol: class {
    func getPageScrollView() -> UIScrollView!
    func getInitialImageFrame() -> CGRect?
    func didTap()
    func didDoubleTap()
    func apply(alpha: CGFloat)
    func didSwipeBack()
    func didSwipe()
}
