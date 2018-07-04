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
        guard let image = imageView.image else {
            fatalError("image is not found")
        }
        let viewController = FullScreenImageViewController(with: image)
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overFullScreen
        
        viewController.initialFrame = imageView.convert(imageView.bounds, to: UIApplication.shared.keyWindow)
        viewController.image = image
        
        viewController.imageViewToHide = imageView
        return viewController
    }
}


class FullScreenImageViewController: UIViewController {
    //    MARK: View's outlets
    private var imageView: UIImageView!
    private var scrollView: UIScrollView!
    private var imageBackgroundView: UIView!
    
    //    MARK: Properties
    fileprivate var initialFrame: CGRect = CGRect.zero
    fileprivate var image: UIImage
    fileprivate var imageViewToHide: UIImageView?
    
    private lazy var verticalConstraints: [NSLayoutConstraint] = []
    private lazy var horizontalConstraints: [NSLayoutConstraint] = {
        return [
            
        ]
    }()
    
    //    MARK: Initializers
    init(with image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //    MARK: UIViewController overriden methods
//    Setting up View Controller
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.clear
        
        let scrollView = UIScrollView.getCustomScrollView()
        self.scrollView = scrollView
        NSLayoutConstraint.activate([
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.heightAnchor.constraint(equalTo: view.heightAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])


        imageBackgroundView = UIView()
        guard let imageBackgroundView = imageBackgroundView else {
            return
        }
        imageBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageBackgroundView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            imageBackgroundView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            imageBackgroundView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageBackgroundView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageBackgroundView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            imageBackgroundView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])

        imageView = UIImageView.getCustomImageView(for: image, initialFrame: initialFrame)
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageBackgroundView)
        imageBackgroundView.addSubview(imageView)
    }
    
    override func viewDidLoad() {
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        verticalConstraints = [
            self.imageView.leftAnchor.constraint(equalTo: self.imageBackgroundView.leftAnchor),
            self.imageView.rightAnchor.constraint(equalTo: self.imageBackgroundView.rightAnchor),
            self.imageView.centerYAnchor.constraint(equalTo: self.imageBackgroundView.centerYAnchor)
        ]
        
        horizontalConstraints = [
            self.imageView.centerXAnchor.constraint(equalTo: self.imageBackgroundView.centerXAnchor),
            self.imageView.topAnchor.constraint(equalTo: self.imageBackgroundView.topAnchor),
            self.imageView.bottomAnchor.constraint(equalTo: self.imageBackgroundView.bottomAnchor)
        ]
        
        self.imageViewToHide?.alpha = 0.01

        UIView.transition(with: imageView, duration: 0.3, options: [.allowAnimatedContent], animations: { [unowned self] in
            self.imageView.frame = self.configureNewFrameForImage()
            self.view.backgroundColor = UIColor.black.withAlphaComponent(1.0)
        }, completion: { [unowned self] _ in
            self.imageView.translatesAutoresizingMaskIntoConstraints = false
            self.imageView.widthAnchor.constraint(equalTo: self.imageView.heightAnchor, multiplier: 4.0/3.0).isActive = true
            NSLayoutConstraint.activate(UIDevice.current.orientation.isPortrait ? self.verticalConstraints : self.horizontalConstraints)
            self.scrollView.delegate = self
        })
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            imageBackgroundView.removeConstraints(verticalConstraints)
            NSLayoutConstraint.activate(horizontalConstraints)
        } else {
            imageBackgroundView.removeConstraints(horizontalConstraints)
            NSLayoutConstraint.activate(verticalConstraints)
        }
        self.scrollView.zoomScale = 1.0
    }

    //    MARK: Private methods
    private func configureNewFrameForImage() -> CGRect {
        let oldFrame = imageView.frame
        let viewFrame = UIApplication.shared.keyWindow!.frame
        var newHeight = CGFloat(0)
        var newWidth = CGFloat(0)
        var originX = CGFloat(0)
        var originY = CGFloat(0)
        if UIDevice.current.orientation.isLandscape {
            newHeight = viewFrame.size.height
            newWidth = oldFrame.width / oldFrame.height * newHeight
            originX = CGFloat(viewFrame.size.width / 2.0 - newWidth / 2.0)
            originY = CGFloat(0)
        } else {
            newWidth = viewFrame.size.width
            newHeight = oldFrame.height * newWidth / oldFrame.width
            originX = CGFloat(0)
            originY = CGFloat(viewFrame.size.height / 2.0 - newHeight / 2.0)
        }
        return CGRect(x: originX, y: originY, width: newWidth, height: newHeight)
    }

    @objc private func tapped(_ recognizer: UITapGestureRecognizer) {
        scrollView.zoomWithAnimation()
    }
    
    private func dissmiss() {
        scrollView.delegate = nil
        UIView.transition(with: imageView, duration: 0.3, options: [.allowAnimatedContent], animations: {[unowned self] in
            self.imageViewToHide?.alpha = 1.0
            self.view.alpha = 0.0
        }, completion: { [unowned self] _ in
            self.presentingViewController?.dismiss(animated: false)
        })
    }
}

class ScrollView: UIScrollView {
    override var adjustedContentInset: UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
}

extension UIImageView {
    fileprivate static func getCustomImageView(for image: UIImage, initialFrame: CGRect) -> UIImageView {
        let imageView = UIImageView(frame: initialFrame)
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        return imageView
    }
}

extension UIScrollView {
    fileprivate static func getCustomScrollView() -> UIScrollView {
        let scrollView = ScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.maximumZoomScale = 3.0
        scrollView.minimumZoomScale = 1.0
        return scrollView
    }
}

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
