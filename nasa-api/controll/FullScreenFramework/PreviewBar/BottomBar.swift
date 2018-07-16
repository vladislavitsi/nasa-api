//
//  BottomBar.swift
//  nasa-api
//
//  Created by Uladzislau Kleshchanka on Jul/11/2018.
//  Copyright © 2018 Uladzislau Kleshchanka. All rights reserved.
//

import UIKit

class BottomBar: AbstractBar {
    
}


class AbstractBar {
    let view = UIView()
    
    init() {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    }
}
