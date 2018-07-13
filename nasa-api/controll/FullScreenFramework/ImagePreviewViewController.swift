//
//  ImagePreviewViewController.swift
//  nasa-api
//
//  Created by Uladzislau Kleshchanka on Jul/12/2018.
//  Copyright © 2018 Uladzislau Kleshchanka. All rights reserved.
//

import UIKit

class ImagePreviewViewController: UIViewController {

    private weak var fullScreenImageController: FullScreenControllerProtocol?
    private let image: UIImage
    private var imageView: UIImageView!
    private var scrollView: ScrollView!
    private var constraintX: NSLayoutConstraint!
    private var constraintY: NSLayoutConstraint!
    private lazy var portraitModeConstraints: [NSLayoutConstraint] = []
    private lazy var landscapeModeConstraints: [NSLayoutConstraint] = []
    private var verticalGap: CGFloat = 0.0
    private var horizontalGap: CGFloat = 0.0
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var initialCenter = CGPoint.zero
    private let shouldAppearAnimated: Bool
    private var pageScrollView: UIScrollView?
    private var dimensionIsLocked = false
    
    init (with image: UIImage, controller: FullScreenControllerProtocol, shouldAppearAnimated: Bool = false) {
        self.image = image
        fullScreenImageController = controller
        self.shouldAppearAnimated = shouldAppearAnimated
        pageScrollView = fullScreenImageController?.getPageScrollView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func computeConstraints() {
        portraitModeConstraints = [
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
        ]
        landscapeModeConstraints = [
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ]
        
        let imageViewToScrollViewConstraints = [
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
        ]
        imageViewToScrollViewConstraints.forEach { constraint in
            constraint.priority = .defaultHigh
            constraint.isActive = true
        }
        
        let screenSize = UIApplication.shared.keyWindow!.frame.size
        let screenHeight = max(screenSize.height, screenSize.width)
        let screenWidth = min(screenSize.height, screenSize.width)
        verticalGap = (screenHeight - ceil(screenWidth/image.size.ratio()))/2
        horizontalGap = (screenHeight - ceil(screenWidth*image.size.ratio()))/2
        
        constraintY = imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
        constraintX = imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
    }
    
    override func loadView() {
        view = UIView()
        
        scrollView = ScrollView.getCustomScrollView()
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.heightAnchor.constraint(equalTo: view.heightAnchor),
        ])
        
        let initialFrame = shouldAppearAnimated ? fullScreenImageController?.getInitialImageFrame() : CGRect.zero
        imageView = UIImageView.getCustomImageView(for: image, initialFrame: initialFrame)
        scrollView.addSubview(imageView)
        
        computeConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if shouldAppearAnimated == false {
            initialLocateView()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        scrollView.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        tapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moved(_:)))
        panGestureRecognizer.delegate = self
        scrollView.addGestureRecognizer(panGestureRecognizer)
        scrollView.addGestureRecognizer(doubleTapGestureRecognizer)
        scrollView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        scrollView.zoomScale = 1.0
    }
    
//    update constraints when orientation changed
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        updateImageConstraints(with: size)
    }
    
    func initialLocateView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: image.size.ratio()),
            constraintY,
            constraintX
        ])
        updateImageConstraints(with: UIScreen.main.bounds.size)
    }
    
    func updateImageConstraints(with size: CGSize) {
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

    private func centerZoomView() {
        if scrollView.frame.size.ratio() > image.size.ratio() {
            constraintX.constant = max((scrollView.bounds.size.width - imageView.frame.size.width)/2 - horizontalGap, -horizontalGap)
        } else {
            constraintY.constant = max((scrollView.bounds.size.height - imageView.frame.size.height)/2 - verticalGap, -verticalGap)
        }
        view.layoutIfNeeded()
    }
}

extension ImagePreviewViewController {
    @objc private func tapped(_ recognizer: UITapGestureRecognizer) {
        fullScreenImageController?.didTap()
    }
    
    @objc private func doubleTapped(_ recognizer: UITapGestureRecognizer) {
        scrollView.zoomWithAnimation()
        fullScreenImageController?.didDoubleTap()
    }
    
    @objc func moved(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard gestureRecognizer.view != nil else {return}
        let piece = gestureRecognizer.view!
        let translation = gestureRecognizer.translation(in: piece.superview)
        if gestureRecognizer.state == .began {
            self.initialCenter = piece.center
        }
        if abs(translation.x) > 20 && abs(translation.y) < 20 {
            if !dimensionIsLocked {
                gestureRecognizer.isEnabled = false
                dimensionIsLocked = true
            }
        }
        if abs(translation.y) > 20 && abs(translation.x) < 20 {
            if !dimensionIsLocked {
                pageScrollView?.isScrollEnabled = false
                dimensionIsLocked = true
            }
        }
        
        if gestureRecognizer.state != .cancelled {
            piece.center = CGPoint(x: initialCenter.x, y: initialCenter.y + translation.y)
            let yOffset = abs(translation.y)
            let alpha = 1 - 0.003 * (yOffset < 150 ? yOffset : 150)
            fullScreenImageController?.apply(alpha: alpha)
        }
        if gestureRecognizer.state == .ended {
            if abs(gestureRecognizer.velocity(in: piece.superview).y) > 700 {
                fullScreenImageController?.didSwipeBack()
            }
            if abs(translation.y) > 150 {
                fullScreenImageController?.didSwipeBack()
            }
        }
        if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled || gestureRecognizer.state == .failed {
            gestureRecognizer.isEnabled = true
            pageScrollView?.isScrollEnabled = true
            dimensionIsLocked = false
            UIView.animate(withDuration: 0.2) { [unowned self] in
                piece.center = self.initialCenter
                self.fullScreenImageController?.apply(alpha: 1.0)
            }
        }
    }
}

extension ImagePreviewViewController: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        panGestureRecognizer.isEnabled = scrollView.zoomScale == 1
        centerZoomView()
    }
}

extension ImagePreviewViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}