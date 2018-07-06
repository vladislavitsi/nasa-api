//
//  FullScreenImageViewController.swift
//  nasa-api
//
//  Created by Uladzislau Kleshchanka on 6/26/18.
//  Copyright © 2018 Uladzislau Kleshchanka. All rights reserved.
//

import UIKit

public extension FullScreenImageViewController {
    
    //    MARK: Factory method
    
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

public class FullScreenImageViewController: UIViewController {
    
    //    MARK: View's outlets
    
    var imageView: UIImageView!
    var scrollView: ScrollView!
    var imageBackgroundView: UIView!
    var previewBars = PreviewBar()
    
    override public var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    //    MARK: Properties
    
    fileprivate var initialFrame: CGRect = CGRect.zero
    fileprivate var image: UIImage
    fileprivate var imageViewToHide: UIImageView?
    
    private lazy var verticalConstraints: [NSLayoutConstraint] = []
    private lazy var horizontalConstraints: [NSLayoutConstraint] = []
    
    //    MARK: Initializers
    
    init(with image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    //    MARK: UIViewController overriden methods
    
//    Setting up View Controller
    override public func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.clear
        
        scrollView = ScrollView.getCustomScrollView()
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.heightAnchor.constraint(equalTo: view.heightAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        imageBackgroundView = UIView()
        scrollView.addSubview(imageBackgroundView)
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
        imageBackgroundView.addSubview(imageView)
    }
    
    override public func viewDidLoad() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        tapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
        scrollView.addGestureRecognizer(doubleTapGestureRecognizer)
        scrollView.addGestureRecognizer(tapGestureRecognizer)
        previewBars.applyToFullScreenView(view)
}

    
    override public func viewDidAppear(_ animated: Bool) {
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

        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        UIView.transition(with: imageView, duration: 0.3, options: [.allowAnimatedContent], animations: { [unowned self] in
            self.imageView.widthAnchor.constraint(equalTo: self.imageView.heightAnchor, multiplier: self.image.size.ratio()).isActive = true
            self.locateImageConstraints(with: UIScreen.main.bounds.size)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(1.0)
            self.view.layoutIfNeeded()
            self.previewBars.showUpBars()
        }, completion: { [unowned self] _ in
            self.scrollView.delegate = self
        })
    }
    
//    public override var preferredStatusBarStyle: UIStatusBarStyle {
//        return
//    }
    
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        locateImageConstraints(with: size)
    }
    
    //    MARK: Private methods
    
    func locateImageConstraints(with size: CGSize) {
        if size.ratio() > image.size.ratio() {
            imageBackgroundView.removeConstraints(verticalConstraints)
            NSLayoutConstraint.activate(horizontalConstraints)
        } else {
            imageBackgroundView.removeConstraints(horizontalConstraints)
            NSLayoutConstraint.activate(verticalConstraints)
        }
        self.scrollView.zoomScale = 1.0
    }

    @objc private func doubleTapped(_ recognizer: UITapGestureRecognizer) {
        scrollView.zoomWithAnimation()
    }
    
    @objc private func tapped(_ recognizer: UITapGestureRecognizer) {
//      There gonna be a cool view with buttons and labels
        previewBars.changeState()
    }
    
    func dissmiss() {
        scrollView.delegate = nil
        UIView.transition(with: imageView, duration: 0.3, options: [.allowAnimatedContent], animations: {[unowned self] in
            self.imageViewToHide?.alpha = 1.0
            self.view.alpha = 0.0
        }, completion: { [unowned self] _ in
            self.presentingViewController?.dismiss(animated: false)
        })
    }
}

//  MARK: FullScreenImageViewController implementation of UIScrollViewDelegate
extension FullScreenImageViewController: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if abs(scrollView.contentOffset.y) > 100 && scrollView.zoomScale == 1 {
            dissmiss()
        }
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
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
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if abs(velocity.y) > 0.5 && scrollView.zoomScale == 1 {
            dissmiss()
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var alpha = CGFloat(1.0)
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            let yOffset = abs(scrollView.contentOffset.y)
            alpha = 1 - 0.005 * (yOffset < 100 ? yOffset : 100)
            previewBars.hideBars()
        }
        view.backgroundColor = view.backgroundColor?.withAlphaComponent(alpha)
    }
}


