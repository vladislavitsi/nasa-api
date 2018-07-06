//
//  FullScreenViewControllerScrollViewDelegate.swift
//  nasa-api
//
//  Created by Uladzislau Kleshchanka on Jul/05/2018.
//  Copyright © 2018 Uladzislau Kleshchanka. All rights reserved.
//

import UIKit

//  MARK: FullScreenImageViewController implementation of UIScrollViewDelegate
extension FullScreenImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if abs(scrollView.contentOffset.y) > 100 && scrollView.zoomScale == 1 {
            dissmiss()
        }
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerZoomView()
        view.bringSubview(toFront: imageView)
    }
    
    private func centerZoomView() {
        if imageView.frame.size.width < scrollView.bounds.size.width {
            imageView.frame.origin.x = (scrollView.bounds.size.width - imageView.frame.size.width) / 2.0;
            
        } else {
            imageView.frame.origin.x = 0.0;
        }
        
        if imageView.frame.size.height < scrollView.bounds.size.height {
            imageView.frame.origin.y = (scrollView.bounds.size.height - imageView.frame.size.height) / 2.0;
        } else {
            imageView.frame.origin.y = 0.0;
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if abs(velocity.y) > 0.5 && scrollView.zoomScale == 1 {
            dissmiss()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var alpha = CGFloat(1.0)
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            let yOffset = abs(scrollView.contentOffset.y)
            alpha = 1 - 0.005 * (yOffset < 100 ? yOffset : 100)
        }
        view.backgroundColor = view.backgroundColor?.withAlphaComponent(alpha)
    }
}
