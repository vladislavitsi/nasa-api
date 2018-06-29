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
    
    private let apodDAO: ApodDAO = ApodDAOImpl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        apodDAO.getData { [unowned self] apodData in
            self.titleView.text = apodData.title
            self.dateView.text = apodData.date
            self.descriptionView.text = apodData.description
            self.copyrightView.text = "© " + (apodData.copyrightInfo ?? " ") 
        }
        
        apodDAO.getImage { [unowned self] image in
            self.imageView.image = image
        }

        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openImage)))
    }
    
    @objc func openImage() {
        let fullScreenImageViewController = FullScreenImageViewController.newViewController(for: imageView)
        present(fullScreenImageViewController, animated: false)
    }
}
