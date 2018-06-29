//
//  APOD.swift
//  nasa-api
//
//  Created by Uladzislau Kleshchanka on 6/26/18.
//  Copyright © 2018 Uladzislau Kleshchanka. All rights reserved.
//

import UIKit

 let requestUrl = "https://api.nasa.gov/planetary/apod?api_key=Xz7tIHEX8vfajGgEWh162j7aaIoiTeATYcsbptGU"

protocol ApodDAO { 
    func getData(with completion: @escaping (ApodData) -> Void )
    func getImage(with completion: @escaping (UIImage) -> Void )
}
