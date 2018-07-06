//
//  ImageViewExtension.swift
//  nasa-api
//
//  Created by Uladzislau Kleshchanka on Jul/05/2018.
//  Copyright © 2018 Uladzislau Kleshchanka. All rights reserved.
//

import UIKit

extension UIImageView {
    static func getCustomImageView(for image: UIImage, initialFrame: CGRect) -> UIImageView {
        let imageView = UIImageView(frame: initialFrame)
        imageView.isUserInteractionEnabled = true
        imageView.isMultipleTouchEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        return imageView
    }
}
