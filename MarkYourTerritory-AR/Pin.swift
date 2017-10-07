//
//  Pin.swift
//  MarkYourTerritory-AR
//
//  Created by Eliot Han on 10/7/17.
//  Copyright © 2017 Eliot Han. All rights reserved.
//

import Foundation


struct Pin {
    var id: String = ""
    var lat: Double = 0.0
    var long: Double = 0.0
    var type: String = "text"
    var user:String = "Anon"
    
    init(dict: [String: AnyObject]) {
        if let id = dict["id"] as? String {
            self.id = id
        }
        if let lat = dict["lat"] as? Double {
            self.lat = lat
        }
        if let long = dict["long"] as? Double {
            self.long = long
        }
        if let type = dict["type"] as? String {
            self.type = type
        }
        if let user = dict["user"] as? String {
            self.user = user
        }
    }
    
    
}
