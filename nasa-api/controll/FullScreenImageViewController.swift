//
//  FullScreenImageViewController.swift
//  nasa-api
//
//  Created by Uladzislau Kleshchanka on 6/26/18.
//  Copyright © 2018 Uladzislau Kleshchanka. All rights reserved.
//

import UIKit

extension FullScreenImageViewController {
    static func newViewController(for imageView: UIImageView) -> UIViewController {
        let viewController = FullScreenImageViewController()
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.initialFrame = imageView.convert(imageView.bounds, to: UIApplication.shared.keyWindow)
        viewController.image = imageView.image
        
        viewController.imageViewToHide = imageView
        return viewController
    }
}


class FullScreenImageViewController: UIViewController {
    private var imageView: UIImageView!
    private var scrollView: UIScrollView!
    private var imageBackgroundView: UIView!
    
    fileprivate var initialFrame: CGRect?
    fileprivate var image: UIImage?
    fileprivate var imageViewToHide: UIImageView!
    
    override var prefersStatusBarHidden: Bool {
        return false
        
    }
    
    
    private var newFrame: CGRect?
    private var token: NSObjectProtocol?
    
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.clear
        
        let scrollView = UIScrollView.getCustomScrollView()
        view.addSubview(scrollView)
        self.scrollView = scrollView
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true

        imageBackgroundView = UIView()
        guard let imageBackgroundView = imageBackgroundView else {
            return
        }
        imageBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(imageBackgroundView)
        imageBackgroundView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        imageBackgroundView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
        imageBackgroundView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        imageBackgroundView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        imageBackgroundView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        imageBackgroundView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true

        
        imageView = UIImageView(frame: (initialFrame)!)
        imageBackgroundView.addSubview(imageView)
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleToFill
        imageView.image = image
    }

    override func viewDidLoad() {
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTapGestureRecognizer)
        
        let oldFrame = imageView.frame
        let viewFrame = UIApplication.shared.keyWindow!.frame
        let newWidth = viewFrame.size.width
        let newHeight = oldFrame.height * newWidth / oldFrame.width
        let originX = CGFloat(0.0)
        let originY = CGFloat(viewFrame.size.height / 2.0 - newHeight / 2.0)
        newFrame = CGRect(x: originX, y: originY, width: newWidth, height: newHeight)
    }

    override func viewDidAppear(_ animated: Bool) {
        self.imageViewToHide?.alpha = 0.01
        imageView.isHidden = false
        UIView.transition(with: imageView, duration: 0.3, options: [.allowAnimatedContent], animations: {[unowned self] in
            self.imageView.frame = self.newFrame!
            self.view.backgroundColor = UIColor.black.withAlphaComponent(1.0)
        }, completion: { [unowned self] _ in
            self.imageView.translatesAutoresizingMaskIntoConstraints = false
            self.imageView.leftAnchor.constraint(equalTo: self.imageBackgroundView.leftAnchor).isActive = true
            self.imageView.rightAnchor.constraint(equalTo: self.imageBackgroundView.rightAnchor).isActive = true
            self.imageView.centerYAnchor.constraint(equalTo: self.imageBackgroundView.centerYAnchor).isActive = true
            self.imageView.widthAnchor.constraint(greaterThanOrEqualTo: self.imageView.heightAnchor, multiplier: 4.0/3.0).isActive = true
            
            self.token = NotificationCenter.default.addObserver(forName: .UIDeviceOrientationDidChange, object: nil, queue: nil) { _ in
                if UIDevice.current.orientation.isLandscape {
                    self.imageView.leftAnchor.constraint(equalTo: self.imageBackgroundView.leftAnchor).isActive = false
                    self.imageView.rightAnchor.constraint(equalTo: self.imageBackgroundView.rightAnchor).isActive = false
                    self.imageView.topAnchor.constraint(equalTo: self.imageBackgroundView.topAnchor).isActive = true
                    self.imageView.bottomAnchor.constraint(equalTo: self.imageBackgroundView.bottomAnchor).isActive = true
                } else {
                    self.imageView.leftAnchor.constraint(equalTo: self.imageBackgroundView.leftAnchor).isActive = true
                    self.imageView.rightAnchor.constraint(equalTo: self.imageBackgroundView.rightAnchor).isActive = true
                    self.imageView.topAnchor.constraint(equalTo: self.imageBackgroundView.topAnchor).isActive = false
                    self.imageView.bottomAnchor.constraint(equalTo: self.imageBackgroundView.bottomAnchor).isActive = false
                }
            }
            self.scrollView.delegate = self
        })

    }
    

    @objc func tapped(_ recognizer: UITapGestureRecognizer) {
        scrollView.zoomWithAnimation()
    }
    
    func dissmiss() {
        scrollView.delegate = nil
        UIView.transition(with: imageView, duration: 0.3, options: [.allowAnimatedContent], animations: {[unowned self] in
            self.imageView.alpha = 0.0
            self.imageViewToHide?.alpha = 1.0
            self.view.alpha = 0.0
        }, completion: { [unowned self] _ in
            self.presentingViewController?.dismiss(animated: false)
            NotificationCenter.default.removeObserver(self.token as Any)
            self.imageViewToHide?.alpha = 1.0
        })
    }
}

class ScrollView: UIScrollView {
    override var adjustedContentInset: UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
}

extension UIScrollView {
    fileprivate static func getCustomScrollView() -> UIScrollView {
        let scrollView = ScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.maximumZoomScale = 5.0
        scrollView.minimumZoomScale = 1.0
        return scrollView
    }
}

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
    }
    
    func centerZoomView() {
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

fileprivate extension UIScrollView {
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
