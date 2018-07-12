//
//  ImagePreviewViewController.swift
//  nasa-api
//
//  Created by Uladzislau Kleshchanka on Jul/12/2018.
//  Copyright © 2018 Uladzislau Kleshchanka. All rights reserved.
//

import UIKit

class ImagePreviewViewController: UIViewController {

    weak var parentController: FullScreenImageViewController?
    
    private let image: UIImage
    var imageView: UIImageView!
    var scrollView: ScrollView!
    var constraintX: NSLayoutConstraint!
    var constraintY: NSLayoutConstraint!
    private lazy var portraitModeConstraints: [NSLayoutConstraint] = []
    private lazy var landscapeModeConstraints: [NSLayoutConstraint] = []
    var verticalGap: CGFloat = 0.0
    var horizontalGap: CGFloat = 0.0
    let initialFrame: CGRect?
    var panGestureRecognizer: UIPanGestureRecognizer!
    var initialCenter = CGPoint.zero
    
    init (with image: UIImage, parent: FullScreenImageViewController, _ initialFrame: CGRect? = nil) {
        self.image = image
        parentController = parent
        self.initialFrame = initialFrame
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        
        scrollView = ScrollView.getCustomScrollView()
        scrollView.alwaysBounceVertical = false

        
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.heightAnchor.constraint(equalTo: view.heightAnchor),
            ])
        
        imageView = UIImageView.getCustomImageView(for: image, initialFrame: CGRect.zero)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let screenSize = UIApplication.shared.keyWindow!.frame.size
        let screenHeight = max(screenSize.height, screenSize.width)
        let screenWidth = min(screenSize.height, screenSize.width)
        
        verticalGap = (screenHeight - ceil(screenWidth/image.size.ratio()))/2
        horizontalGap = (screenHeight - ceil(screenWidth*image.size.ratio()))/2
        
        constraintY = imageView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
        constraintX = imageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        
//        UIView.transition(with: imageView, duration: 0.3, options: [.allowAnimatedContent], animations: { [unowned self] in
        scrollView.backgroundColor = .clear
        
        self.imageView.widthAnchor.constraint(equalTo: self.imageView.heightAnchor, multiplier: self.image.size.ratio()).isActive = true
        
        self.constraintY.isActive = true
        self.constraintX.isActive = true
        
        self.locateImageConstraints(with: UIScreen.main.bounds.size)
        
//            }, completion: { [unowned self] _ in
        self.scrollView.delegate = self
//        })
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
    
    @objc private func tapped(_ recognizer: UITapGestureRecognizer) {
        parentController?.previewBars.changeState()
    }
    
    @objc private func doubleTapped(_ recognizer: UITapGestureRecognizer) {
        scrollView.zoomWithAnimation()
    }
    
    var contentSize: CGSize = CGSize.zero
    
    @objc func moved(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard gestureRecognizer.view != nil else {return}
        let piece = gestureRecognizer.view!
        let translation = gestureRecognizer.translation(in: piece.superview)
        if gestureRecognizer.state == .began {
            self.initialCenter = piece.center
        }
        if abs(translation.x) > 20 && abs(translation.y) < 10 {
            gestureRecognizer.isEnabled = false
        }

        if gestureRecognizer.state != .cancelled {
            parentController?.previewBars.hideBars(animated: true)
            let newCenter = CGPoint(x: initialCenter.x, y: initialCenter.y + translation.y)
            piece.center = newCenter
            if abs(piece.center.y - initialCenter.y) > 20 {
                if let scrollView = parentController?.view.superview as? UIScrollView {
                    contentSize = scrollView.contentSize
                    scrollView.contentSize = CGSize(width: UIApplication.shared.keyWindow!.frame.width, height: contentSize.height)
                }
            }
            var alpha = CGFloat(1.0)
            if piece.center != initialCenter {
                let yOffset = abs(translation.y)
                alpha = 1 - 0.003 * (yOffset < 150 ? yOffset : 150)
            }
            parentController?.view.backgroundColor = parentController?.view.backgroundColor?.withAlphaComponent(alpha)
        }
        if gestureRecognizer.state == .ended {
            gestureRecognizer.isEnabled = true
            if abs(gestureRecognizer.velocity(in: piece.superview).y) > 700 {
                parentController?.dissmiss()
            }
            if abs(translation.y) > 150 {
                parentController?.dissmiss()
            }
        }
        if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled {
            parentController?.isScrollEnabled = false
            UIView.animate(withDuration: 0.2) { [unowned self] in
                piece.center = self.initialCenter
                self.parentController?.view.backgroundColor = self.parentController?.view.backgroundColor?.withAlphaComponent(1)
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        scrollView.zoomScale = 1.0
    }
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        locateImageConstraints(with: size)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        panGestureRecognizer.isEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
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

}

extension ImagePreviewViewController: UIScrollViewDelegate {
    
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

extension ImagePreviewViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
