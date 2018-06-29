//
//  ApodDAOImpl.swift
//  nasa-api
//
//  Created by Uladzislau Kleshchanka on 6/26/18.
//  Copyright © 2018 Uladzislau Kleshchanka. All rights reserved.
//

import UIKit
import Alamofire

extension ApodDAOImpl: ApodDAO {
    //    MARK: public interface
    
    func getData(with completion: @escaping (ApodData) -> Void) {
        getApodData { apodData in
            completion(apodData)
        }
    }
    
    func getImage(with completion: @escaping (UIImage) -> Void) {
        getApodData { apodData in
            guard let imagePath = apodData.imagePath else {
                return
            }
            ApodDAOImpl.downloadImage(from: imagePath, with: { image in
                completion(image)
            })
        }
    }
}

class ApodDAOImpl {

    //    MARK: private interface
    
    private var apodDataCache: ApodData?
    
    private func getApodData(with completion: @escaping (ApodData) -> Void) {
        if let apodData = apodDataCache {
            completion(apodData)
        } else {
            ApodDAOImpl.fetchData { apodData in
                completion(apodData)
            }
        }
    }
    
    private static func downloadImage(from url: String, with completion: @escaping (UIImage) -> Void) {
        Alamofire.request(url).responseData { response in
            guard let data = response.result.value,
                  let image = UIImage(data: data) else {
                return
            }
            completion(image)
        }
    }

    private static func fetchData(with completion: @escaping (ApodData) -> Void) {
        Alamofire.request(requestUrl).responseJSON { response in
            guard let data = response.data,
                  let apod = try? JSONDecoder().decode(ApodData.self, from: data) else {
                    print("Bad data, couldn't init apod")
                    return
            }
            completion(apod)
        }
    }

}

