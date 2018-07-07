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
        viewController.modalPresentationCapturesStatusBarAppearance = true
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
//    var imageBackgroundView: UIView!
    var previewBars = PreviewBar()
    
    override public var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    //    MARK: Properties
    
    fileprivate var initialFrame: CGRect = CGRect.zero
    fileprivate var image: UIImage
    fileprivate var imageViewToHide: UIImageView?
    
    private lazy var portraitModeConstraints: [NSLayoutConstraint] = []
    private lazy var landscapeModeConstraints: [NSLayoutConstraint] = []
    
    var statusBarShouldBeHidden = false
    
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
        view.backgroundColor = UIColor.black
        
        scrollView = ScrollView.getCustomScrollView()
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.heightAnchor.constraint(equalTo: view.heightAnchor),
        ])

        imageView = UIImageView.getCustomImageView(for: image, initialFrame: initialFrame)
        scrollView.addSubview(imageView)

        let imageViewToScrollViewTopSpaceConstraint = self.imageView.topAnchor.constraint(equalTo: self.scrollView.topAnchor)
        let imageViewToScrollViewBottomSpaceConstraint = self.imageView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor)
        imageViewToScrollViewTopSpaceConstraint.priority = UILayoutPriority(rawValue: 500)
        imageViewToScrollViewBottomSpaceConstraint.priority = UILayoutPriority(rawValue: 500)

        portraitModeConstraints = [
            self.imageView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
            self.imageView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
            imageViewToScrollViewTopSpaceConstraint,
            imageViewToScrollViewBottomSpaceConstraint
        ]
        
        let imageViewToScrollViewLeadingSpaceConstraint = self.imageView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor)
        let imageViewToScrollViewTrailingSpaceConstraint = self.imageView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor)
        imageViewToScrollViewLeadingSpaceConstraint.priority = UILayoutPriority(rawValue: 500)
        imageViewToScrollViewTrailingSpaceConstraint.priority = UILayoutPriority(rawValue: 500)
        
        landscapeModeConstraints = [
            self.imageView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            self.imageView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
            imageViewToScrollViewLeadingSpaceConstraint,
            imageViewToScrollViewTrailingSpaceConstraint
        ]
    }
    
    override public func viewDidLoad() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        tapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
        scrollView.addGestureRecognizer(doubleTapGestureRecognizer)
        scrollView.addGestureRecognizer(tapGestureRecognizer)
        previewBars.applyToFullScreenView(self)
}

    var constraintX: NSLayoutConstraint!
    var constraintY: NSLayoutConstraint!
    
    override public func viewDidAppear(_ animated: Bool) {
        self.imageViewToHide?.alpha = 0.01

        self.imageView.translatesAutoresizingMaskIntoConstraints = false

        UIView.transition(with: imageView, duration: 0.3, options: [.allowAnimatedContent], animations: { [unowned self] in
            self.imageView.widthAnchor.constraint(equalTo: self.imageView.heightAnchor, multiplier: self.image.size.ratio()).isActive = true
            
            self.constraintY = self.imageView.centerYAnchor.constraint(equalTo: self.scrollView.centerYAnchor)
            self.constraintY.isActive = true
            self.constraintX = self.imageView.centerXAnchor.constraint(equalTo: self.scrollView.centerXAnchor)
            self.constraintX.isActive = true
            
            self.locateImageConstraints(with: UIScreen.main.bounds.size)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(1.0)
            self.view.layoutIfNeeded()
            self.previewBars.showUpBars()
        }, completion: { [unowned self] _ in
            self.scrollView.delegate = self
        })
    }
    
    public override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    public override var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden
    }
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        locateImageConstraints(with: size)
    }
    
    //    MARK: Private methods
    
    func locateImageConstraints(with size: CGSize) {
        if size.ratio() > image.size.ratio() {
            scrollView.removeConstraints(portraitModeConstraints)
            NSLayoutConstraint.activate(landscapeModeConstraints)
        } else {
            scrollView.removeConstraints(landscapeModeConstraints)
            NSLayoutConstraint.activate(portraitModeConstraints)
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
            self.statusBarShouldBeHidden = false
            self.setNeedsStatusBarAppearanceUpdate()
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

    }
    
    private func centerZoomView() {
//        if imageView.frame.size.width > scrollView.bounds.size.width {
//            // enable
//            constraintX.isActive = true
//        } else {
//            // disable
//            constraintX.isActive = false
//        }
        if imageView.frame.size.height < scrollView.bounds.size.height {
            // enable
            constraintY.isActive = true
        } else {
            // disable
            constraintY.isActive = false
        }
        view.layoutIfNeeded()
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
        }
        view.backgroundColor = view.backgroundColor?.withAlphaComponent(alpha)
    }
}

