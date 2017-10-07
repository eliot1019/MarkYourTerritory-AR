//
//  ViewController.swift
//  MarkYourTerritory-AR
//
//  Created by Eliot Han on 10/7/17.
//  Copyright © 2017 Eliot Han. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreLocation

class ViewController: UIViewController {
    var sceneLocationView = SceneLocationView()
    var geoQueryTimer: Timer!
    var testPin = Pin(id: "testid", lat: 37.86727740, lon: -122.25776656, type: PinType.text, user: "eliot")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
        
        //Creating the postPin
        NetworkClient.shared.postPin(pin: testPin, completion: { pinId in
            guard let pinId = pinId else {
                print("Error creating pin in Firebase")
                return
            }
            print("Created pinId \(pinId)")
            
        })
        geoQueryTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.getUserLocation), userInfo: nil, repeats: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneLocationView.run()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneLocationView.pause()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneLocationView.frame = view.bounds

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first {
            if touch.view != nil {
<<<<<<< HEAD
                let location = touch.location(in: self.view)
                
                //let theText = UITextField.text(keyBoardShit)
                
                //let annotationNode = LocationAnnotationNode(location: nil, image: image)
                // TODO populate theText (uncomment below 3 lines)
                // let annotationNode = LocationAnnotationNode(location: nil, String: theText)
                // annotationNode.scaleRelativeToDistance = true
                // sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode)
=======
 
>>>>>>> 1895e42815f6d08c4df275d561030cb0159e4345
                
            }
        }
    }
    
    @objc func getUserLocation() {
        if let currentLocation = sceneLocationView.currentLocation() {
            DispatchQueue.main.async {
                //print(currentLocation)
            }
        }
    }
    

}
