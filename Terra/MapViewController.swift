//
//  MapViewController.swift
//  Terra
//
//  Created by Terra Team on 2017-03-11.
//  Copyright © 2017 Terra Inc. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var locationButton: UIButton!
    
    var locationManager = CLLocationManager()
    
    var panGestureRecognizer : UIPanGestureRecognizer?
    
    var trackLocation = true
    var firstLocationUpdate = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
        
        map.showsUserLocation = true
        
        var trashAnnotation = MKPointAnnotation()
        
        var location = CLLocationCoordinate2D(latitude: 43.5, longitude: -80.5)
        
        trashAnnotation.coordinate = location
        
        map.addAnnotation(trashAnnotation)
        
        map.showsUserLocation = true
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didDragMap))
        panGestureRecognizer?.delegate = self
        map.addGestureRecognizer(panGestureRecognizer!)
        
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }


    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if (trackLocation) {
            let userLocation: CLLocation = locations[0]
            
            let latitude = userLocation.coordinate.latitude
            
            let longitude = userLocation.coordinate.longitude
            
            let latDelta: CLLocationDegrees = 0.000005
            
            let lonDelta: CLLocationDegrees = 0.000005
            
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
            
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let region = MKCoordinateRegion(center: location, span: span)
            
            if (firstLocationUpdate) {
                firstLocationUpdate = false
                self.map.setRegion(region, animated: false)
            } else {
                self.map.setRegion(region, animated: true)
            }
            
        }
        
    }
    
    @IBAction func locationButtonAction(_ sender: Any) {
        
        trackLocation = true
        
        locationButton.setImage(UIImage(named: "myLocation.png"), for: UIControlState.normal)
        
    }
    
    func didDragMap(_ gestureRecognizer: UIGestureRecognizer) {
        trackLocation = false
        
        locationButton.setImage(UIImage(named: "panMode.png"), for: UIControlState.normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

