//
//  ApodData.swift
//  nasa-api
//
//  Created by Uladzislau Kleshchanka on 6/26/18.
//  Copyright © 2018 Uladzislau Kleshchanka. All rights reserved.
//

import UIKit

struct ApodData {
    var title: String?
    var date: String?
    var description: String?
    var copyrightInfo: String?
    
    var imagePath: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case date
        case description = "explanation"
        case copyrightInfo = "copyright"
        case image = "url"
    }
}

extension ApodData: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let title = try? values.decode(String.self, forKey: .title)
        let date = try? values.decode(String.self, forKey: .date)
        let description = try? values.decode(String.self, forKey: .description)
        let copyrightInfo = try? values.decode(String.self, forKey: .copyrightInfo)
        let imagePath = try? values.decode(String.self, forKey: .image)
        self.init(title: title, date: date, description: description, copyrightInfo: copyrightInfo, imagePath: imagePath)
    }
}
