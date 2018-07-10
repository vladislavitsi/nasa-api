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
    var previewBars = PreviewBar()
    
    
    //    MARK: Status Bar settings
    override public var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    public override var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden
    }
    
    //    MARK: Properties
    
    fileprivate var initialFrame: CGRect = CGRect.zero
    fileprivate var image: UIImage
    fileprivate var imageViewToHide: UIImageView?
    
    private lazy var portraitModeConstraints: [NSLayoutConstraint] = []
    private lazy var landscapeModeConstraints: [NSLayoutConstraint] = []
    
    var constraintX: NSLayoutConstraint!
    var constraintY: NSLayoutConstraint!
    
    var verticalGap: CGFloat = 0.0
    var horizontalGap: CGFloat = 0.0
    
    var statusBarShouldBeHidden = false
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    var initialCenter = CGPoint.zero
    
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
        
        portraitModeConstraints = [
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
        ]
        
        landscapeModeConstraints = [
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ]
        
        let imageViewToScrollViewTopSpaceConstraint = self.imageView.topAnchor.constraint(equalTo: self.scrollView.topAnchor)
        let imageViewToScrollViewBottomSpaceConstraint = self.imageView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor)
        let imageViewToScrollViewLeadingSpaceConstraint = self.imageView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor)
        let imageViewToScrollViewTrailingSpaceConstraint = self.imageView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor)
        imageViewToScrollViewTopSpaceConstraint.priority = .defaultHigh
        imageViewToScrollViewBottomSpaceConstraint.priority = .defaultHigh
        imageViewToScrollViewLeadingSpaceConstraint.priority = .defaultHigh
        imageViewToScrollViewTrailingSpaceConstraint.priority = .defaultHigh
        imageViewToScrollViewLeadingSpaceConstraint.isActive = true
        imageViewToScrollViewTrailingSpaceConstraint.isActive = true
        imageViewToScrollViewTopSpaceConstraint.isActive = true
        imageViewToScrollViewBottomSpaceConstraint.isActive = true
    }
    
    
    override public func viewDidLoad() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moved(_:)))
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        tapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
        doubleTapGestureRecognizer.require(toFail: panGestureRecognizer)
        scrollView.addGestureRecognizer(panGestureRecognizer)
        scrollView.addGestureRecognizer(doubleTapGestureRecognizer)
        scrollView.addGestureRecognizer(tapGestureRecognizer)
        previewBars.applyToFullScreenView(self)
}
    
    @objc func moved(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard gestureRecognizer.view != nil else {return}
        let piece = gestureRecognizer.view!
        let translation = gestureRecognizer.translation(in: piece.superview)
        if gestureRecognizer.state == .began {
            self.initialCenter = piece.center
        }
        if gestureRecognizer.state != .cancelled {
            previewBars.hideBars()
            let newCenter = CGPoint(x: initialCenter.x, y: initialCenter.y + translation.y)
            piece.center = newCenter
            var alpha = CGFloat(1.0)
            if piece.center != initialCenter {
                let yOffset = abs(translation.y)
                alpha = 1 - 0.005 * (yOffset < 100 ? yOffset : 100)
            }
            view.backgroundColor = view.backgroundColor?.withAlphaComponent(alpha)
        }
        if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled {
            if abs(gestureRecognizer.velocity(in: piece.superview).y) > 700 {
                dissmiss()
            }
            if abs(translation.y) > 120 {
                dissmiss()
            }
            UIView.animate(withDuration: 0.3) { [unowned self] in
                piece.center = self.initialCenter
                self.view.backgroundColor = self.view.backgroundColor?.withAlphaComponent(1)
            }
        }
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        imageViewToHide?.alpha = 0.01

        imageView.translatesAutoresizingMaskIntoConstraints = false

        let screenSize = UIApplication.shared.keyWindow!.frame.size
        let screenHeight = max(screenSize.height, screenSize.width)
        let screenWidth = min(screenSize.height, screenSize.width)
  
        verticalGap = (screenHeight - ceil(screenWidth/image.size.ratio()))/2
        horizontalGap = (screenHeight - ceil(screenWidth*image.size.ratio()))/2
        
        constraintY = imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
        constraintX = imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        
        UIView.transition(with: imageView, duration: 0.3, options: [.allowAnimatedContent], animations: { [unowned self] in
            self.view.backgroundColor = UIColor.black

            self.imageView.widthAnchor.constraint(equalTo: self.imageView.heightAnchor, multiplier: self.image.size.ratio()).isActive = true
            
            self.constraintY.isActive = true
            self.constraintX.isActive = true
            
            self.locateImageConstraints(with: UIScreen.main.bounds.size)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(1.0)
            
            self.previewBars.showBars()
        }, completion: { [unowned self] _ in
            self.scrollView.delegate = self
        })
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
        self.view.layoutIfNeeded()
    }

    @objc private func doubleTapped(_ recognizer: UITapGestureRecognizer) {
        scrollView.zoomWithAnimation()
    }
    
    @objc private func tapped(_ recognizer: UITapGestureRecognizer) {
        previewBars.changeState()
    }
    
    func dissmiss() {
        scrollView.delegate = nil
        UIView.transition(with: imageView, duration: 0.4, options: [.allowAnimatedContent], animations: {[unowned self] in
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
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale == 1 {
            panGestureRecognizer.isEnabled = true
        } else {
            panGestureRecognizer.isEnabled = false
        }
        centerZoomView()
    }
    
    private func centerZoomView() {
        if scrollView.frame.size.ratio() > image.size.ratio() {
            constraintX.constant = max((scrollView.bounds.size.width - imageView.frame.size.width)/2 - horizontalGap, -horizontalGap)
        } else {
            constraintY.constant = max((scrollView.bounds.size.height - imageView.frame.size.height)/2 - verticalGap, -verticalGap)
        }
        view.layoutIfNeeded()
    }
}

