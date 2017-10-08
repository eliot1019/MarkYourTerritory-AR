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
    var isBlur = false
    var textIsShown = false
    var postView = UITextView()
    var captionUnderline = UIView()
    var isUsingKeyboard = false
    var submitButton = UIButton()
    var threeDButton = UIButton()
    var userText: String = ""
    var blurView = UIVisualEffectView()
    var geoQueryTimer: Timer!
    var testPin = Pin(id: Utilities.getDateString(isoFormat: true), lat: 37.86727740, lon: -122.25776656, type: PinType.text, user: "eliot")
    
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
            NetworkClient.shared.setGeoFireLocation(pin: self.testPin, firebaseID: pinId, completion: { error in
                guard error == nil else {
                    return
                }
            })
        })
        //geoQueryTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.getUserLocation), userInfo: nil, repeats: true)
        
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
    
    @objc func submitButtonClicked(_ sender: UIButton!) {
        postView.resignFirstResponder()
        self.view.endEditing(true)
        blurView.removeFromSuperview()
        self.isBlur = false
        postView.removeFromSuperview()
        self.textIsShown = false
        userText = postView.text!
        captionUnderline.removeFromSuperview()
        submitButton.removeFromSuperview()
        threeDButton.removeFromSuperview()
        let annotationNode = LocationAnnotationNode(location: nil, theText: userText)
        annotationNode.scaleRelativeToDistance = true
        sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode)
    }
    
    @objc func threeDButtonClicked(_ sender: UIButton!) {
        if threeDButton.isSelected {
            print("false")
            threeDButton.isSelected = false
        } else {
            print("true")
            threeDButton.isSelected = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        
        if let touch = touches.first {
            if isUsingKeyboard {
                self.view.endEditing(true)
                isUsingKeyboard = !isUsingKeyboard
            } else {
                isUsingKeyboard = !isUsingKeyboard
            }
            
            if touch.view != nil {
                if !self.isBlur {
                    let blur = UIBlurEffect(style: .dark)
                    blurView = UIVisualEffectView(effect: blur)
                    blurView.frame = self.view.bounds
                    blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    self.view.addSubview(blurView)
                    self.isBlur = true
                }

                //Test Geofire shit
                NetworkClient.shared.updateGeoQuery(lat: testPin.lat, lon: testPin.lon)

                if !textIsShown {
    //                captionTextView.text = captionPlaceHolder
                    postView = UITextView(frame: CGRect(x: 30, y: (view.frame.height / 2) - 50, width: view.frame.width - 60, height: 100))
                    postView.textColor = UIColor.white
                    postView.backgroundColor = UIColor.clear
                    postView.tintColor = UIColor.white
                    postView.layer.shadowOffset = CGSize(width: 0, height: 0)
                    postView.layer.shadowOpacity = 0.6
                    postView.layer.shadowRadius = 0.5
                    postView.becomeFirstResponder()
                    postView.isScrollEnabled = false
                    postView.isScrollEnabled = false
                    postView.font = UIFont.boldSystemFont(ofSize: 15)
                    postView.textContainer.maximumNumberOfLines = 4
                    view.addSubview(postView)
                    self.textIsShown = true
                }
                
                submitButton = UIButton(frame: CGRect(x: view.frame.width * 3/4 - 15, y: 30, width: 67, height: 29))
                submitButton.layoutIfNeeded()
                submitButton.setTitle("Post", for: .normal)
                submitButton.setTitleColor(UIColor.black, for: .normal)
                submitButton.layer.cornerRadius = 5
                submitButton.addTarget(self, action: #selector(submitButtonClicked(_:)), for: .touchUpInside)
                submitButton.backgroundColor = UIColor.white
                view.addSubview(submitButton)
                
                threeDButton = UIButton(frame: CGRect(x: 20, y: 30, width: 150, height: 30))
                threeDButton.layoutIfNeeded()
                threeDButton.setTitle("Enable 3D", for: .normal)
                threeDButton.setTitle("Enable 2D", for: .selected)
                threeDButton.setTitleColor(UIColor.black, for: .normal)
                threeDButton.layer.cornerRadius = 5
                threeDButton.addTarget(self, action: #selector(threeDButtonClicked(_:)), for: .touchUpInside)
                threeDButton.backgroundColor = UIColor.white
                
                
                view.addSubview(threeDButton)
                
                captionUnderline = UIView(frame: CGRect(x: 30, y: (view.frame.height / 2) + 30, width: view.frame.width - 60, height: 2))
                captionUnderline.backgroundColor = UIColor.red
                view.addSubview(captionUnderline)
                
                //To move the textfield up or down
                func animateTextView(textView: UITextView, up: Bool){
                    let movementDistance:CGFloat = (-150)
                    let movementDuration: Double = 0.3
                    
                    var movement:CGFloat = 0
                    if up{
                        movement = movementDistance
                    }
                    else{
                        movement = -movementDistance
                    }
                    UIView.beginAnimations("animateTextField", context: nil)
                    UIView.setAnimationBeginsFromCurrentState(true)
                    UIView.setAnimationDuration(movementDuration)
                    self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
                    UIView.commitAnimations()
                }
                
                let location = touch.location(in: self.view)
                
                //let annotationNode = LocationAnnotationNode(location: nil, image: image)
                // TODO populate theText (uncomment below 3 lines)
                // let annotationNode = LocationAnnotationNode(location: nil, String: theText)
                // annotationNode.scaleRelativeToDistance = true
                // sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode)
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

