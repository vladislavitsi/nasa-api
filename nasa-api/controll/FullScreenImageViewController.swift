//
//  FullScreenImageViewController.swift
//  nasa-api
//
//  Created by Uladzislau Kleshchanka on 6/26/18.
//  Copyright © 2018 Uladzislau Kleshchanka. All rights reserved.
//

import UIKit

extension FullScreenImageViewController {
    
    static func newViewController(for imageView: UIImageView, cutBy overView: UIView) -> UIViewController {
        let viewController = FullScreenImageViewController()
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.initialFrame = imageView.convert(imageView.bounds, to: UIApplication.shared.keyWindow)
        viewController.initialFrame = imageView.frame.intersection(overView.bounds)
        viewController.initialImage = imageView.snapshot(of: viewController.initialFrame)
        viewController.originImageView = imageView
        return viewController
    }
    
    static func imageWithView(_ view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        view.layer.render(in: context)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}


class FullScreenImageViewController: UIViewController {
    private var imageView: UIImageView!
    private var scrollView: UIScrollView!
    
    fileprivate var imageBackgroundView: UIView!
    
    fileprivate var initialFrame: CGRect?
    fileprivate var initialImage: UIImage?
    fileprivate var originImageView: UIImageView!
    
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
        guard let imageBackgroundView = imageBackgroundView else {return}
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
        imageView.contentMode = .scaleAspectFit
        imageView.image = initialImage
        
//        let fadeAnim:CABasicAnimation = CABasicAnimation(keyPath: "contents")
//        fadeAnim.fromValue = initialImage
//        fadeAnim.toValue   = self.originImageView.image
//        fadeAnim.duration  = 0.8         //smoothest value
//        imageView.layer.add(fadeAnim, forKey: "contents");
    }
    
    var newFrame: CGRect?
    
    override func viewDidLoad() {
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTapGestureRecognizer)

        let viewFrame = UIApplication.shared.keyWindow!.frame
        let newWidth = viewFrame.size.width
        let newHeight = originImageView.frame.height * newWidth / originImageView.frame.width
        let originX = CGFloat(0.0)
        let originY = CGFloat(viewFrame.size.height / 2.0 - newHeight / 2.0)
        newFrame = CGRect(x: originX, y: originY, width: newWidth, height: newHeight)
    }

    
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.originImageView.alpha = 0.01
        UIView.transition(with: imageView,
                          duration: 0.5,
                          options: [.transitionFlipFromTop],
                          animations: {
                            self.imageView.image = self.originImageView.image
                            self.imageView.frame = self.newFrame!
                            self.view.backgroundColor = UIColor.black.withAlphaComponent(1.0)
        }) { (_) in
            self.scrollView.delegate = self
        }

    }
    

    
    
    @objc func tapped(_ recognizer: UITapGestureRecognizer) {
        scrollView.zoomWithAnimation()
    }
    
    func dissmiss() {
        presentingViewController?.dismiss(animated: true)
        originImageView.alpha = 1.0
    }
}

extension UIView {
    
    /// Create snapshot
    ///
    /// - parameter rect: The `CGRect` of the portion of the view to return. If `nil` (or omitted),
    ///                   return snapshot of the whole view.
    ///
    /// - returns: Returns `UIImage` of the specified portion of the view.
    
    func snapshot(of rect: CGRect? = nil) -> UIImage? {
        // snapshot entire view
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let wholeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // if no `rect` provided, return image of whole view
        
        guard let image = wholeImage, let rect = rect else { return wholeImage }
        
        // otherwise, grab specified `rect` of image
        
        let scale = image.scale
        let scaledRect = CGRect(x: rect.origin.x * scale, y: rect.origin.y * scale, width: rect.size.width * scale, height: rect.size.height * scale)
        guard let cgImage = image.cgImage?.cropping(to: scaledRect) else { return nil }
        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
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
