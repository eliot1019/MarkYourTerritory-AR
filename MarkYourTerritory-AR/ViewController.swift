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

class ViewController: UIViewController, UITextFieldDelegate{
    var sceneLocationView = SceneLocationView()
<<<<<<< HEAD
    var isBlur = false
    var textIsShown = false
    var textField = UITextField()
    var blurView = UIVisualEffectView()
=======
    var geoQueryTimer: Timer!
    var testPin = Pin(id: "testid", lat: 37.86727740, lon: -122.25776656, type: PinType.text, user: "eliot")
>>>>>>> 3375301ee61129da278a66345527b96365738412
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneLocationView.run()
        self.textField.delegate = self
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
                if !self.isBlur {
                    let blur = UIBlurEffect(style: .dark)
                    blurView = UIVisualEffectView(effect: blur)
                    blurView.frame = self.view.bounds
                    blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    self.view.addSubview(blurView)
                    self.isBlur = true
                }
                
                if !textIsShown {
                    textField = UITextField(frame: CGRect(x: UIScreen.main.bounds.width * (1/3), y: UIScreen.main.bounds.height / 2, width: UIScreen.main.bounds.width - 20, height: 0.1 * UIScreen.main.bounds.height))
                    textField.layoutIfNeeded()
                    textField.layer.shadowRadius = 2.0
                    textField.textColor = UIColor.white
                    textField.layer.masksToBounds = true
                    textField.placeholder = "insert text"
                    textField.becomeFirstResponder()
                    self.view.addSubview(textField)
                    self.textIsShown = true
                }
                
                let location = touch.location(in: self.view)
                
//                let textField = UITextField.text(keyBoardShit)
                
                //let annotationNode = LocationAnnotationNode(location: nil, image: image)
//                let annotationNode = LocationAnnotationNode(location: nil, String: textField)
//                annotationNode.scaleRelativeToDistance = true
//                sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode)
                
                let location = touch.location(in: self.view)
                
                //let theText = UITextField.text(keyBoardShit)
                
                //let annotationNode = LocationAnnotationNode(location: nil, image: image)
                // TODO populate theText (uncomment below 3 lines)
                // let annotationNode = LocationAnnotationNode(location: nil, String: theText)
                // annotationNode.scaleRelativeToDistance = true
                // sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode)
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        blurView.removeFromSuperview()
        self.isBlur = false
        textField.removeFromSuperview()
        self.textIsShown = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        blurView.removeFromSuperview()
        self.isBlur = false
        textField.removeFromSuperview()
        self.textIsShown = false
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    @objc func getUserLocation() {
        if let currentLocation = sceneLocationView.currentLocation() {
            DispatchQueue.main.async {
                //print(currentLocation)
            }
        }
    }
    

}
