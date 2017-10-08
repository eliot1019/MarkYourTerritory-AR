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

struct Pin: Codable, Hashable {
    // Currently is the ISO Date as a string. Not unique
    var time: String = ""
    var lat: Double = 0.0
    var lon: Double = 0.0
    var type: PinType = .text
    var user: String = "Anon"
    var data: String = "" //If type is text, this will be our data, otherwise url
    
    var firebaseKey: String = ""
    
    var hashValue: Int {
        return firebaseKey.hashValue
    }
    
    static func == (lhs: Pin, rhs: Pin) -> Bool {
        return lhs.firebaseKey == rhs.firebaseKey
    }
    
    init(dict: [String: AnyObject]) {
        if let time = dict["time"] as? String {
            self.time = time
        }
        if let lat = dict["lat"] as? Double {
            self.lat = lat
        }
        if let lon = dict["lon"] as? Double {
            self.lon = lon
        }
        if let type = dict["type"] as? String {
            self.type = PinType(rawValue: type) ?? .text
        }
        if let user = dict["user"] as? String {
            self.user = user
        }
        if let data = dict["data"] as? String {
            self.data = data
        }
        
    }
    
    init(time: String, lat: Double, lon: Double, type: PinType, user:String, data:String) {
        self.time = time
        self.lat = lat
        self.lon = lon
        self.type = type
        self.user = user
        self.data = data
        self.firebaseKey = ""
    }
    
}

extension Pin: Serializable {
    var properties: Array<String> {
        return ["time", "lat", "lon", "type", "user", "data"]
    }
    
    func valueForKey(key: String) -> Any? {
        switch key {
        case "time":
            return time
        case "lat":
            return lat
        case "lon":
            return lon
        case "type":
            return type.rawValue
        case "user":
            return user
        case "data":
            return data
        default:
            return nil
        }
    }
    
}
