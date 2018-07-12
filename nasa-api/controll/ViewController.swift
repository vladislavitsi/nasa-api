//
//  ViewController.swift
//  nasa-api
//
//  Created by Uladzislau Kleshchanka on 6/26/18.
//  Copyright © 2018 Uladzislau Kleshchanka. All rights reserved.
//

import UIKit

class ViewController: UIViewController {    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var dateView: UILabel!
    @IBOutlet weak var descriptionView: UILabel!
    @IBOutlet weak var copyrightView: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: UIControlEvents.valueChanged)
        return refreshControl
    }()

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshData()
        refreshControl.endRefreshing()
    }
    
    private let apodDAO: ApodDAO = ApodDAOImpl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(refreshControl)
        
        refreshData()
        self.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openImage)))
        
    }
    
    func refreshData(_ completion: (() -> Void)? = nil) {
        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        apodDAO.getData { [unowned self] apodData in
            self.titleView.text = apodData.title
            self.dateView.text = apodData.date
            self.descriptionView.text = apodData.description
            self.copyrightView.text = "© " + (apodData.copyrightInfo ?? " ")
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        apodDAO.getImage { [unowned self] image in
            self.imageView.image = image
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
//            completion?()
        }
    }
    
    @objc func openImage() {
        let fullScreenImageViewController = FullScreenImageViewController.newViewController(for: imageView)
        fullScreenImageViewController.imageDescription = titleView.text
        fullScreenImageViewController.previewBars.topBar.pageCounter.isHidden = true
        present(fullScreenImageViewController, animated: false)
    }
}
