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

class ViewController: UIViewController{
    var sceneLocationView = SceneLocationView()
    var isBlur = false
    var textIsShown = false
    var tField = UITextField()
    var userText:String = ""
    var blurView = UIVisualEffectView()
    var geoQueryTimer: Timer!
    //var testPin = Pin(id: Utilities.getDateString(isoFormat: true), lat: 37.86727740, lon: -122.25776656, type: PinType.text, user: "eliot")
    
    var mapView = MKMapView()
    var mapButton = UIButton()
    var showMapView = false
    var userAnnotation: MKPointAnnotation?

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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first {
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

//MARK: UITextFieldDelegate
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
