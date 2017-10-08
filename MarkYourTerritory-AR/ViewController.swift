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

class ViewController: UIViewController {
    var sceneLocationView = SceneLocationView()
    var isBlur = false
    var textIsShown = false
    var postView = UITextView()
    var isUsingKeyboard = false
    var submitButton = UIButton()
    var threeDButton = UIButton()
    var userText: String = ""
    var user: String = "Anonymous"
    var blurView = UIVisualEffectView()
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
        sceneLocationView.run()
        view.addSubview(sceneLocationView)

        geoQueryTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.updateUserLocation), userInfo: nil, repeats: true)
        
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

        mapButton.frame = CGRect(
            x: 0,
            y: self.view.frame.size.height - 65,
            width: 57,
            height: 57)
        mapButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)

        
        
        mapView.frame = CGRect(
            x: 0,
            y: self.view.frame.size.height / 2,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height / 2)
    }
    
    @objc func submitButtonClicked(_ sender: UIButton!) {
        postView.resignFirstResponder()
        submitButton.removeFromSuperview()
        threeDButton.removeFromSuperview()
        self.view.endEditing(true)
        blurView.removeFromSuperview()
        self.isBlur = false
        postView.removeFromSuperview()
        self.textIsShown = false
        userText = postView.text!

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
                    let blur = UIBlurEffect(style: .dark)
                    blurView = UIVisualEffectView(effect: blur)
                    blurView.frame = self.view.bounds
                    blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    self.view.addSubview(blurView)
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
