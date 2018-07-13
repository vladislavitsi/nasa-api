//
//  FullScreenImageViewController.swift
//  nasa-api
//
//  Created by Uladzislau Kleshchanka on 6/26/18.
//  Copyright © 2018 Uladzislau Kleshchanka. All rights reserved.
//

import UIKit

public class FullScreenImageViewController: UIPageViewController {
    
    public var previewBars = PreviewBar()
    var initialImageView: UIImageView?
    var viewToHide: UIView?
    var statusBarShouldBeHidden = false
    var imagePreviewViewControllers = [ImagePreviewViewController]()
    var images: [UIImage]? {
        didSet {
            updateImagePreviewViewControllers(for: images!)
        }
    }
    
    //    MARK: Initializers
    init() {
        super.init(transitionStyle: .scroll,
                   navigationOrientation: .horizontal,
                   options: [UIPageViewControllerOptionInterPageSpacingKey: 20])
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
        modalPresentationCapturesStatusBarAppearance = true
        dataSource = self
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateImagePreviewViewControllers(for images: [UIImage]) {
        var imagePreviewViewControllers = [ImagePreviewViewController]()
        for (number, image) in images.enumerated() {
            imagePreviewViewControllers.append(ImagePreviewViewController(with: image, controller: self, shouldAppearAnimated: number == 0))
        }
        self.imagePreviewViewControllers = imagePreviewViewControllers
        setViewControllers([imagePreviewViewControllers.first!], direction: .forward, animated: false)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        self.viewToHide?.alpha = 0.01
        UIView.animate(withDuration: 0.3) { [unowned self] in
            self.view.backgroundColor = .black
            self.previewBars.applyToFullScreenView(self)
            self.previewBars.showBars()
        }
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 5,
                       options: [.allowAnimatedContent],
                       animations: { [unowned self] in
            self.imagePreviewViewControllers.first!.initialLocateView()
        })
    }
    
    func dissmiss() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.allowAnimatedContent], animations: { [unowned self] in
            self.viewToHide?.alpha = 1
            self.view.alpha = 0.0
            self.statusBar(shouldBeHidden: false)
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: { [unowned self] _ in
            self.presentingViewController?.dismiss(animated: false)
        })
    }
}

//    MARK: Status Bar settings
extension FullScreenImageViewController {
    override public var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    public override var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden
    }
    private func statusBar(shouldBeHidden: Bool) {
        statusBarShouldBeHidden = shouldBeHidden
        setNeedsStatusBarAppearanceUpdate()
    }
}

//    MARK: FullScreenControllerProtocol
extension FullScreenImageViewController: FullScreenControllerProtocol {
    func getInitialImageFrame() -> CGRect? {
        return initialImageView?.globalFrame
    }
    
    func didTap() {
        previewBars.changeState()
    }
    
    func didDoubleTap() {
    }
    
    func apply(alpha: CGFloat) {
        view.backgroundColor = view.backgroundColor?.withAlphaComponent(alpha)
        
    }
    
    func didSwipeBack() {
        dissmiss()
    }
    
    func getPageScrollView() -> UIScrollView! {
        for view in view.subviews {
            if let scrollView = view as? UIScrollView {
                return scrollView
            }
        }
        return nil
    }
    
}

//    MARK: UIPageViewControllerDataSource
extension FullScreenImageViewController: UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard let imagePreviewViewController = viewController as? ImagePreviewViewController else {
            return nil
        }
        guard let newIndex = imagePreviewViewControllers.index(of: imagePreviewViewController),
            newIndex != 0 else {
            return nil
        }
        return imagePreviewViewControllers[newIndex-1]
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let imagePreviewViewController = viewController as? ImagePreviewViewController else {
            return nil
        }
        guard let newIndex = imagePreviewViewControllers.index(of: imagePreviewViewController),
            newIndex != imagePreviewViewControllers.count-1 else {
                return nil
        }
        return imagePreviewViewControllers[newIndex+1]
    }
}
