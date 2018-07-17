//
//  FSIViewControllerDelegate.swift
//  nasa-api
//
//  Created by Uladzislau Kleshchanka on Jul/17/2018.
//  Copyright © 2018 Uladzislau Kleshchanka. All rights reserved.
//

import UIKit

protocol FSIViewControllerDelegate: class {
    func didTap()
    func didDoubleTap()
    func didSwipeBack()
    func didChangePage()
}
