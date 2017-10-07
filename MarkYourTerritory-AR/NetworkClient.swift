//
//  NetworkClient.swift
//  MarkYourTerritory-AR
//
//  Created by Eliot Han on 10/7/17.
//  Copyright © 2017 Eliot Han. All rights reserved.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseInstanceID

class NetworkClient: NSObject {
    var ref: DatabaseReference!

    
    override init() {
        ref = Database.database().reference()

    }
    
    func createPin(pin: Pin, completion: @escaping () -> Void) {
        
    }
    
    
}
