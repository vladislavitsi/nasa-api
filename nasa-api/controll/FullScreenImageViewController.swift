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
        
        var l = imageView.frame.intersection(imageView.superview!.superview!.frame)
        
        viewController.initialFrame = imageView.convert(imageView.bounds, to: UIApplication.shared.keyWindow)
        viewController.image = imageView.image
        
        viewController.imageViewToHide = imageView
        return viewController
    }
}


class FullScreenImageViewController: UIViewController {
    var imageView: UIImageView!
    var scrollView: UIScrollView!
    
    fileprivate var imageBackgroundView: UIView!
    
    fileprivate var initialFrame: CGRect?
    fileprivate var image: UIImage?
    fileprivate var imageViewToHide: UIImageView!
    
    override var prefersStatusBarHidden: Bool {
        return false
        
    }
    
    override func loadView() {

        
//        Root View
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
//        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
//        imageView.isHidden = true
        imageView = imageViewToHide
        
        UIView *subView = self.viewWithManySubViews;
        UIGraphicsBeginImageContextWithOptions(subView.bounds.size, YES, 0.0f);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [subView.layer renderInContext:context];
        UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImageView *snapshotImageView = [[UIImageView alloc] initWithImage:snapshotImage];
    }
    
    var newFrame: CGRect?
    
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
        UIView.animate(withDuration: 0.2, animations: { [unowned self] in

            //            NSLayoutConstraint.activate([
            //                self.imageView.centerYAnchor.constraint(equalTo: (self.imageBackgroundView?.centerYAnchor)!),
            //                self.imageView.widthAnchor.constraint(equalTo: (self.imageBackgroundView?.widthAnchor)!),
            //                self.imageView.leadingAnchor.constraint(equalTo: (self.imageBackgroundView?.leadingAnchor)!),
            //                self.imageView.trailingAnchor.constraint(equalTo: (self.imageBackgroundView?.trailingAnchor)!),
            //                self.imageView.heightAnchor.constraint(equalToConstant: (self.imageView.image?.size.height)!)
            //                ])
            self.imageView.frame = self.newFrame!
            self.view.backgroundColor = UIColor.black.withAlphaComponent(1.0)
        }, completion: { [unowned self] _ in
            self.scrollView.delegate = self
        })
    }
    

    @objc func tapped(_ recognizer: UITapGestureRecognizer) {
        scrollView.zoomWithAnimation()
    }
    
    func dissmiss() {
        presentingViewController?.dismiss(animated: true)
        imageViewToHide?.alpha = 1.0
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
        scrollView.maximumZoomScale = 2.0
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
        print(scrollView.zoomScale)
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
    
    func zoomWithAnimation(to scale: CGFloat) {
        UIView.animate(withDuration: 0.4) { [unowned self] in
            self.zoomScale = scale
        }
    }
}
