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

class ViewController: UIViewController{
    var sceneLocationView = SceneLocationView()
    var isBlur = false
    var textIsShown = false
    var tField = UITextField()
    var userText:String = ""
    var blurView = UIVisualEffectView()
    var geoQueryTimer: Timer!
    //var testPin = Pin(id: Utilities.getDateString(isoFormat: true), lat: 37.86727740, lon: -122.25776656, type: PinType.text, user: "eliot")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneLocationView.run()
        view.addSubview(sceneLocationView)

        geoQueryTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateUserLocation), userInfo: nil, repeats: true)

        
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

                if !self.isBlur {
                    let blur = UIBlurEffect(style: .dark)
                    blurView = UIVisualEffectView(effect: blur)
                    blurView.frame = self.view.bounds
                    blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    self.view.addSubview(blurView)
                    self.isBlur = true
                }


                
                if !textIsShown {
                    tField = UITextField(frame: CGRect(x: UIScreen.main.bounds.width * (1/3), y: UIScreen.main.bounds.height / 2, width: UIScreen.main.bounds.width - 20, height: 0.1 * UIScreen.main.bounds.height))
                    tField.layoutIfNeeded()
                    tField.adjustsFontSizeToFitWidth = true
                    tField.adjustsFontSizeToFitWidth = true
                    tField.returnKeyType = .done
                    tField.layer.shadowRadius = 2.0
                    tField.textColor = UIColor.white
                    tField.layer.masksToBounds = true
                    tField.placeholder = "insert text"
                    tField.becomeFirstResponder()
                    tField.delegate = self
                    self.view.addSubview(tField)
                    self.textIsShown = true
                }
                
                //let location = touch.location(in: self.view)
                
                //let annotationNode = LocationAnnotationNode(location: nil, image: image)
                // TODO populate theText (uncomment below 3 lines)
                // let annotationNode = LocationAnnotationNode(location: nil, String: theText)
                // annotationNode.scaleRelativeToDistance = true
                // sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode)
            }
        }
    }
    
    ///Updates location and calls updateGeoQuery
    @objc func updateUserLocation() {
        if let currentLocation = sceneLocationView.currentLocation() {
            DispatchQueue.main.async {
                //print(currentLocation)
                print("test", currentLocation.altitude)
                NetworkClient.shared.updateGeoQuery(lat: currentLocation.coordinate.latitude, lon: currentLocation.coordinate.longitude, currentAlt: currentLocation.altitude - 0.2,callback: { pinLocationNode in
                    
                    print("Adding location Node to sceneView")
                    self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode)

                })

            }
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("made it here fam")
        textField.resignFirstResponder()
        self.view.endEditing(true)
        blurView.removeFromSuperview()
        self.isBlur = false
        textField.removeFromSuperview()
        self.textIsShown = false
        userText = textField.text!
        let annotationNode = LocationAnnotationNode(location: nil, theText: userText)
        annotationNode.scaleRelativeToDistance = true
        sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode)
        
        
        //might want to split this off into helper function or move elsewhere
        if let currentLocation = sceneLocationView.currentLocation() {
            let pin = Pin(time: Utilities.getDateString(isoFormat: true), lat: currentLocation.coordinate.latitude, lon: currentLocation.coordinate.longitude, type: .text, user: "Anon", data: userText)
            NetworkClient.shared.postPin(pin: pin, completion: { pinId in
                guard let pinId = pinId else {
                    print("Error creating pin in Firebase")
                    return
                }
                
                print("Created pinId \(pinId)")
                NetworkClient.shared.setGeoFireLocation(pin: pin, firebaseID: pinId, completion: { error in
                    guard error == nil else {
                        return
                    }
                })
            })
        }
       
        
        return true
    }
}
