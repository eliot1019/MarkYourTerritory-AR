//
//  Pin.swift
//  MarkYourTerritory-AR
//
//  Created by Eliot Han on 10/7/17.
//  Copyright © 2017 Eliot Han. All rights reserved.
//

import Foundation

enum PinType : String, Codable {
    case pic
    case text
}

struct Pin: Codable {
    var id: String
    var lat: Double
    var lon: Double
    var type: PinType
    var user: String
    
//    init(dict: [String: AnyObject]) {
//        if let id = dict["id"] as? String {
//            self.id = id
//        }
//        if let lat = dict["lat"] as? Double {
//            self.lat = lat
//        }
//        if let long = dict["lon"] as? Double {
//            self.lon = lon
//        }
//        if let type = dict["type"] as? String {
//            self.type = type
//        }
//        if let user = dict["user"] as? String {
//            self.user = user
//        }
//    }
    
    
}

extension Pin: Serializable {
    var properties: Array<String> {
        return ["id", "lat", "lon", "type", "user"]
    }
    
    func valueForKey(key: String) -> Any? {
        switch key {
        case "id":
            return id
        case "lat":
            return lat
        case "lon":
            return lon
        case "type":
            return type.rawValue
        case "user":
            return user
        default:
            return nil
        }
    }
    
}
