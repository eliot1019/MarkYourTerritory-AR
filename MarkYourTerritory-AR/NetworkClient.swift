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
    var geoFire: GeoFire!
    var circleQuery: GFCircleQuery?
    var pins = Set<Pin>()
    
    override init() {
        super.init()
        
        ref = Database.database().reference()
        geoFire = GeoFire(firebaseRef: ref)
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
    
    func getPin(firebaseKey: String, completion: @escaping (Pin?) -> Void) {
        let pinsRef = self.ref.child("pins")
        pinsRef.child(firebaseKey).observeSingleEvent(of: .value, with: { snapshot in
            guard let dict = snapshot.value as? NSDictionary else {
                print("No pin for key \(firebaseKey)")
                completion(nil)
                return
            }
            //print(dict)
            var pin = Pin(dict: dict as! [String : AnyObject])
            pin.firebaseKey = firebaseKey
            completion(pin)
            
        })
    }
    
    func setGeoFireLocation(pin: Pin, firebaseID: String, completion: @escaping (Error?) -> Void) {
        
        geoFire.setLocation(CLLocation(latitude: pin.lat, longitude: pin.lon), forKey: firebaseID) { (error) in
            if (error != nil) {
                print("An error occured: \(String(describing: error))")
                completion(error)
            } else {
                print("Saved location successfully!")
                completion(nil)
            }
        }

    }
    
    /// Observes pins created in a 200m radius around a center
    ///If its the first time you call this, it creates circlequery and starts observing. Otherwise, it just updates the center
    ///Callback is a function that will take a node and add it to sceneLocationView
    func updateGeoQuery(lat: Double, lon: Double, currentAlt: Double = 5, callback: @escaping (LocationAnnotationNode) -> Void) {
        let center = CLLocation(latitude: lat, longitude: lon)

        //If first call, we init circleQuery
        if self.circleQuery == nil {
            // Query locations at coord with a radius of 200 meters
            self.circleQuery = geoFire.query(at: center, withRadius: 0.2)
            self.circleQuery!.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
                print("Key '\(key)' entered the search area and is at location '\(location)'")
                self.getPin(firebaseKey: key, completion: { pin in
                    guard let pin = pin else { return }
                    let wasNotInSet = self.pins.insert(pin) //returns tuple --> read doc if confused
                    if wasNotInSet.inserted {
                        print("Inserting pin \(pin.firebaseKey) into set")
                        print("Creating annotation node")

                        //Create a AnnotationNode
                        let pinCoord = CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.lon)
                        
                        let pinLocation = CLLocation(coordinate: pinCoord, altitude: currentAlt)
                        let testPinImage = UIImage(named: "bear")!
                        let pinLocationNode = LocationAnnotationNode(location: pinLocation, image: testPinImage)
                        pinLocationNode.continuallyAdjustNodePositionWhenWithinRange = false
                        pinLocationNode.scaleRelativeToDistance = true
                        callback(pinLocationNode)
                    }
                })
            })
        }
        
        //The center of the search area. Update this value to update the query. Events are triggered for any keys that move in or out of the search area.
        self.circleQuery!.center = center
        
    }
    
}
