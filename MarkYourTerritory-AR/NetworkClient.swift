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

//Singleton class for Networking
//To call a function, use shared --> NetworkClient.shared.func()

class NetworkClient: NSObject {
    static let shared = NetworkClient()
    
    var ref: DatabaseReference!

    override init() {
        super.init()
        
        ref = Database.database().reference()
        
    }
    
    ///Completion passes back a string of the newly created pin id
    ///If post fails, String is nil
    func postPin(pin: Pin, completion: @escaping (String?) -> Void) {
        let childRef = self.ref.child("pins").childByAutoId()
        let pinId = childRef.key
        print("ref: \(ref)")
        print("childRef: \(childRef)")

        //childRef.setValue()
        childRef.setValue(pin.toDictionary(), withCompletionBlock: {(error, snapshot) in
            guard error == nil else {
                print(error?.localizedDescription as Any)
                completion(nil)
                return
            }
            print("Completed postPin successfully")
            completion(pinId)
            
        })
        
    }
    
    func setGeoFireLocation(pin: Pin, firebaseID: String, completion: @escaping (Error?) -> Void) {
        
        geoFire.setLocation(CLLocation(latitude: 37.86727740, longitude: -122.25776656), forKey: firebaseID) { (error) in
            if (error != nil) {
                println("An error occured: \(error)")
                completion(error)
            } else {
                println("Saved location successfully!")
                completion(nil)
            }
        }

    }
    
    
}
