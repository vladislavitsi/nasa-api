//
//  FullScreenImageViewController.swift
//  nasa-api
//
//  Created by Uladzislau Kleshchanka on 6/26/18.
//  Copyright © 2018 Uladzislau Kleshchanka. All rights reserved.
//

import UIKit

public class FullScreenImageViewController: UIPageViewController {
    
    //    MARK: View's outlets
    public var previewBars = PreviewBar()
    
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
//    public var imageDescription: String? {
//        set {
//            previewBars.imageDescription = newValue
//        }
//        get {
//            return previewBars.imageDescription
//        }
//    }
    
    fileprivate var initialFrame: CGRect = CGRect.zero
    fileprivate var imageViewToHide: UIImageView?
    var isScrollEnabled = true
    
    var images: [UIImage]? {
        didSet {
            updateImagePreviewViewControllers(for: images!)
        }
    }
    var statusBarShouldBeHidden = false
    var imagePreviewViewControllers = [ImagePreviewViewController]()
    //    MARK: Initializers
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: 20])
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
        dataSource = self
        
        modalPresentationCapturesStatusBarAppearance = true
        let proxy: UIPageControl = UIPageControl.appearance(whenContainedInInstancesOf: [FullScreenImageViewController.self])
        proxy.backgroundColor = .black
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //    MARK: UIViewController overriden methods
    func updateImagePreviewViewControllers(for images: [UIImage]) {
        var imagePreviewViewControllers = [ImagePreviewViewController]()
        for image in images {
            imagePreviewViewControllers.append(ImagePreviewViewController(with: image, parent: self))
        }
        self.imagePreviewViewControllers = imagePreviewViewControllers
        setViewControllers([imagePreviewViewControllers.first!], direction: .forward, animated: true, completion: nil)
    }
    
    override public func viewDidLoad() {
        view.backgroundColor = .black
        previewBars.applyToFullScreenView(self)
        previewBars.showBars()
}
    
    
    override public func viewDidAppear(_ animated: Bool) {
        imageViewToHide?.alpha = 0.01
    }
    
    //    MARK: Private methods
    
    func dissmiss() {
//        scrollView.delegate = nil
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.allowAnimatedContent], animations: { [unowned self] in
            self.imageViewToHide?.alpha = 1.0
            self.view.alpha = 0.0
            self.statusBarShouldBeHidden = false
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: { [unowned self] _ in
            self.presentingViewController?.dismiss(animated: false)
        })
    }
}

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

extension FullScreenImageViewController: UIPageViewControllerDelegate {
    
}
