//
//  ScrollView.swift
//  nasa-api
//
//  Created by Uladzislau Kleshchanka on Jul/05/2018.
//  Copyright © 2018 Uladzislau Kleshchanka. All rights reserved.
//

import UIKit

class ScrollView: UIScrollView {
    static func getCustomScrollView() -> ScrollView {
        let scrollView = ScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.maximumZoomScale = 3.0
        scrollView.minimumZoomScale = 1.0
        return scrollView
    }
}

extension ScrollView {
    func zoomWithAnimation() {
        if zoomScale == maximumZoomScale {
            zoomWithAnimation(to: minimumZoomScale)
        } else {
            zoomWithAnimation(to: maximumZoomScale)
        }
    }
    
    private func zoomWithAnimation(to scale: CGFloat) {
        UIView.animate(withDuration: 0.4) { [unowned self] in
            self.zoomScale = scale
        }
    }
}

