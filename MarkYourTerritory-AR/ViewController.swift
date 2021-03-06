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
import MapKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var sceneLocationView = SceneLocationView()
    var isBlur = false
    var textIsShown = false
    var postView = UITextView()
    var captionUnderline = UIView()
    var isUsingKeyboard = false
    var submitButton = UIButton()
    var threeDButton = UIButton()
    var userText: String = ""
    var user: String = "Anonymous"
    var blurView: UIView?
    var geoQueryTimer: Timer!
    //var testPin = Pin(id: Utilities.getDateString(isoFormat: true), lat: 37.86727740, lon: -122.25776656, type: PinType.text, user: "eliot")
    
    var mapView = MKMapView()
    var mapButton = UIButton()
    var showMapView = false
    var userAnnotation: MKPointAnnotation?
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneLocationView.delegate = self
        
        let text = SCNText(string: "Leave Your Mark!", extrusionDepth: 1)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red:0.12, green:0.85, blue:0.82, alpha:1.0)
        text.materials = [material]
        let node = SCNNode()
        node.position = SCNVector3(x: 0.0, y: 0.02, z: -0.1)
        node.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
        node.geometry = text
        sceneLocationView.scene.rootNode.addChildNode(node)
        
        sceneLocationView.autoenablesDefaultLighting = true
        
        sceneLocationView.run()
        view.addSubview(sceneLocationView)

        geoQueryTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateUserLocation), userInfo: nil, repeats: true)
        
        
        mapButton.frame = CGRect(
            x: 0,
            y: self.view.frame.size.height - 65,
            width: 57,
            height: 57)
        mapButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        mapButton.addTarget(self, action: #selector(mapPressed), for: .touchUpInside)
        mapButton.setImage(UIImage(named: "map"), for: .normal)
        view.addSubview(mapButton)
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.alpha = 0
        view.addSubview(mapView)
       // mapView.isHidden = true
        
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Pick a name or stay Anonymous!", message: nil, preferredStyle: .alert)
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Anonymous"
            }
            let doneAction = UIAlertAction(title: "Ok", style: .cancel, handler: { alert -> Void in
                let firstTextField = alertController.textFields![0] as UITextField
                self.user = firstTextField.text ?? self.user
                if firstTextField.text == "" {
                    self.user = "Anonymous"
                }
            })
            alertController.addAction(doneAction)
            self.present(alertController, animated: true, completion: nil)
        }
       
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
        
        
        mapView.frame = CGRect(
            x: 0,
            y: self.view.frame.size.height / 2,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height / 2)
    }
    
    @objc func submitButtonClicked(_ sender: UIButton!) {
        postView.resignFirstResponder()
        self.view.endEditing(true)
        self.isBlur = false
        self.textIsShown = false
        userText = postView.text!
        
        dismissBlur()

        let annotationNode = LocationAnnotationNode(location: nil, theText: userText)
        annotationNode.scaleRelativeToDistance = true
        sceneLocationView.addLocationNodeForCurrentPosition(locationNode: annotationNode)
        
        //Creates object in firebase with geofire calls
        if let currentLocation = sceneLocationView.currentLocation() {
            let pin = Pin(time: Utilities.getDateString(isoFormat: true), lat: currentLocation.coordinate.latitude, lon: currentLocation.coordinate.longitude, type: .text, user: self.user, data: userText)
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
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: pin.lat, longitude:pin.lon)
                    annotation.subtitle = pin.user
                    self.mapView.addAnnotation(annotation)
                })
            })
        }
    }
    
    @objc func dismissBlur() {
        if let b = blurView {
            for sub in b.subviews {
                sub.removeFromSuperview()
            }
            b.removeFromSuperview()
        }
        self.isBlur = false
        self.textIsShown = false

        
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

                let location = touch.location(in: self.view)
                if showMapView && location.y > view.frame.height/2{
                    return
                }
                
                if !self.isBlur {
                    if let b = blurView {
                        dismissBlur()
                    }
                    self.blurView = UIView()
                    self.blurView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
                    self.blurView?.frame = self.view.bounds
                    self.blurView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissBlur))
                    self.blurView?.addGestureRecognizer(tap)
                    self.view.addSubview(self.blurView!)
                    self.isBlur = true
                }


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
                    blurView?.addSubview(postView)
                    self.textIsShown = true
                }
                

                submitButton = UIButton(frame: CGRect(x: view.frame.width - 45, y: 10, width: 40, height: 40))
                submitButton.layoutIfNeeded()
                submitButton.setImage(UIImage(named: "paint"), for: .normal)

                submitButton.addTarget(self, action: #selector(submitButtonClicked(_:)), for: .touchUpInside)
                blurView?.addSubview(submitButton)
                
                threeDButton = UIButton(frame: CGRect(x: 10, y: 10, width: 40, height: 40))
                threeDButton.layoutIfNeeded()
                threeDButton.setImage(UIImage(named: "3d"), for: .normal)
                threeDButton.setImage(UIImage(named: "3d-selected"), for: .selected)
                threeDButton.addTarget(self, action: #selector(threeDButtonClicked(_:)), for: .touchUpInside)
                blurView?.addSubview(threeDButton)

                
                captionUnderline = UIView(frame: CGRect(x: 30, y: (view.frame.height / 2) + 30, width: view.frame.width - 60, height: 2))
                captionUnderline.backgroundColor = UIColor(red:0.12, green:0.85, blue:0.82, alpha:1.0)
                blurView?.addSubview(captionUnderline)
                
                
                
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
                print("Altitude", currentLocation.altitude)
                
                //MapView stuff
                if self.userAnnotation == nil {
                    self.userAnnotation = MKPointAnnotation()
                    self.mapView.addAnnotation(self.userAnnotation!)
                }
                
                UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                    self.userAnnotation?.coordinate = currentLocation.coordinate
                }, completion: nil)
                
                //center map on user location
                UIView.animate(withDuration: 0.45, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                    self.mapView.setCenter(self.userAnnotation!.coordinate, animated: false)
                }, completion: {
                    _ in
                    self.mapView.region.span = MKCoordinateSpan(latitudeDelta: 0.0005, longitudeDelta: 0.0005)
                })
                
                
                //Update geoquery center
                NetworkClient.shared.updateGeoQuery(lat: currentLocation.coordinate.latitude, lon: currentLocation.coordinate.longitude, currentAlt: currentLocation.altitude - 0.2,callback: { pinLocationNode, pin in
                    
                    print("Adding location Node to sceneView")
                    self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode)
                    
                    //Add annotations to map
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: pin.lat, longitude:pin.lon)
                    annotation.subtitle = pin.user
                    self.mapView.addAnnotation(annotation)
                    
                })
                
            }
        }
    }

    @objc func mapPressed() {
        DispatchQueue.main.async {
            if !self.showMapView {
                //mapView.isHidden = true
                UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                    self.mapButton.frame = CGRect(
                        x: 0, y: self.view.frame.size.height - (self.view.frame.size.height/2) - 65, width: 57, height: 57)
                    self.mapView.alpha = 0.8
                }, completion: nil)
            } else {
                //mapView.isHidden = false
                UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                    self.mapButton.frame = CGRect(
                        x: 0,
                        y: self.view.frame.size.height - 65,
                        width: 57,
                        height: 57)
                    self.mapView.alpha = 0
                }, completion: nil)
            }
            self.showMapView = !self.showMapView
            print("showMapView is \(self.showMapView)")
        }
    }
}


//MARK: MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        if let pointAnnotation = annotation as? MKPointAnnotation {
            let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
            
            if pointAnnotation == self.userAnnotation {
                marker.displayPriority = .required
                marker.glyphImage = UIImage(named: "user")
            } else {
                marker.displayPriority = .required
                marker.markerTintColor = UIColor(hue: 0.267, saturation: 0.67, brightness: 0.77, alpha: 1.0)
                marker.glyphImage = UIImage(named: "compass")
            }
            
            return marker
        }
        
        return nil
    }
}
