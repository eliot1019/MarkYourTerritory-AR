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
    var id: String = ""
    var lat: Double = 0.0
    var lon: Double = 0.0
    var type: PinType = .text
    var user: String = "Anon"
    var firebaseKey: String = ""
    
    var hashValue: Int {
        return firebaseKey.hashValue
    }
    
    static func == (lhs: Pin, rhs: Pin) -> Bool {
        return lhs.firebaseKey == rhs.firebaseKey
    }
    
    init(dict: [String: AnyObject]) {
        if let id = dict["id"] as? String {
            self.id = id
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
    }
    
    init(id: String, lat: Double, lon: Double, type: PinType, user:String) {
        self.id = id
        self.lat = lat
        self.lon = lon
        self.type = type
        self.user = user
        self.firebaseKey = ""
    }
    
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
