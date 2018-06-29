//
//  PresentTransitionAnimator.swift
//  nasa-api
//
//  Created by Uladzislau Kleshchanka on 6/27/18.
//  Copyright © 2018 Uladzislau Kleshchanka. All rights reserved.
//

import UIKit

class PresentTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 1.0
    var presenting = true
    var originFrame = CGRect.zero
    var imageView: UIImageView?
    
    var dismissCompletion: (()->Void)?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        imageView?.alpha = 0.01
        let containerView = transitionContext.containerView

        let foregroundView = presenting ? transitionContext.view(forKey: .to)! : transitionContext.view(forKey: .from)!
        
        let initialFrame = presenting ? imageView!.frame : foregroundView.frame
        let finalFrame = presenting ? foregroundView.frame : imageView!.frame
        
        let xScaleFactor = presenting ?
            initialFrame.width / finalFrame.width :
            finalFrame.width / initialFrame.width
        
        let yScaleFactor = presenting ?
            initialFrame.height / finalFrame.height :
            finalFrame.height / initialFrame.height
        
        let scaleTransform = CGAffineTransform(scaleX: xScaleFactor, y: yScaleFactor)
        
        if presenting {
            foregroundView.transform = scaleTransform
            foregroundView.center = CGPoint(
                x: initialFrame.midX,
                y: initialFrame.midY)
            foregroundView.clipsToBounds = true
        }
        
        containerView.addSubview(foregroundView)
        containerView.bringSubview(toFront: foregroundView)
        
        UIView.animate(withDuration: duration, delay:0.0,
                       usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0,
                       animations: {
                        foregroundView.transform = self.presenting ? CGAffineTransform.identity : scaleTransform
                        foregroundView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
        }, completion: { _ in
            if !self.presenting {
                self.dismissCompletion?()
                self.imageView?.alpha = 1.0
            }
            transitionContext.completeTransition(true)
        })

    }
}
