//
//  MapViewController.swift
//  Terra
//
//  Created by Terra Team on 2017-03-11.
//  Copyright © 2017 Terra Inc. All rights reserved.
//

import UIKit
import MapKit

var locationsArr = [CustomPointAnnotation]()

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, UINavigationBarDelegate {

    @IBOutlet weak var map: MKMapView!

    @IBOutlet weak var locationButton: UIButton!

    @IBOutlet weak var navbar: UINavigationBar!

    var locationManager = CLLocationManager()

    var userLocation: CLLocation!

    var panGestureRecognizer: UIPanGestureRecognizer?

    var trackLocation = true

    var firstLocationUpdate = true

    var recycle: CustomPointAnnotation!

    var recycleView: MKPinAnnotationView!

    var trash: CustomPointAnnotation!

    var trashView: MKPinAnnotationView!

    var compost: CustomPointAnnotation!

    var compostView: MKPinAnnotationView!

    var other: CustomPointAnnotation!

    var otherView: MKPinAnnotationView!

    override func viewDidLoad() {
        super.viewDidLoad()

        navbar.delegate = self

        locationManager.delegate = self

        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        locationManager.requestWhenInUseAuthorization()

        locationManager.startUpdatingLocation()

        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didDragMap))

        panGestureRecognizer?.delegate = self

        map.addGestureRecognizer(panGestureRecognizer!)

        map.showsUserLocation = true

        recycle = CustomPointAnnotation()

        recycle.imageName = "recycle.png"

        recycle.coordinate = CLLocationCoordinate2D(latitude: 43.47, longitude: -80.54)

        recycle.title = "Recycle"

        recycleView = MKPinAnnotationView(annotation: recycle, reuseIdentifier: "pin")

        map.addAnnotation(recycleView.annotation!)

        trash = CustomPointAnnotation()

        trash.imageName = "trash.png"

        trash.coordinate = CLLocationCoordinate2D(latitude: 43.46, longitude: -80.55)

        trash.title = "Trash"

        trashView = MKPinAnnotationView(annotation: trash, reuseIdentifier: "pin")

        map.addAnnotation(trashView.annotation!)

        compost = CustomPointAnnotation()

        compost.imageName = "compost.png"

        compost.coordinate = CLLocationCoordinate2D(latitude: 43.464, longitude: -80.544)

        compost.title = "Compost"

        compostView = MKPinAnnotationView(annotation: compost, reuseIdentifier: "pin")

        map.addAnnotation(compostView.annotation!)

        other = CustomPointAnnotation()

        other.imageName = "other.png"

        other.coordinate = CLLocationCoordinate2D(latitude: 43.466, longitude: -80.546)

        other.title = "Special Disposal"

        otherView = MKPinAnnotationView(annotation: other, reuseIdentifier: "pin")

        map.addAnnotation(otherView.annotation!)

        locationsArr.append(recycle)
        locationsArr.append(trash)
        locationsArr.append(compost)
        locationsArr.append(other)

        //let distance = MKUserLocati

        let request = MKDirectionsRequest()

        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 40.203314, longitude: -8.410257), addressDictionary: nil))

        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 40.112808, longitude: -8.498689), addressDictionary: nil))

        request.requestsAlternateRoutes = false

        request.transportType = .walking

        let directions = MKDirections(request: request)

        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }

            for route in unwrappedResponse.routes {
                self.map.add(route.polyline)
                self.map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let reuseIdentifier = "pin"

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)

        if annotationView == nil {

            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)

            annotationView?.canShowCallout = true

        } else {

            annotationView?.annotation = annotation

        }

        if annotation is MKUserLocation {
            return nil
        }

        if let customPointAnnotation = annotation as? CustomPointAnnotation {

            annotationView?.image = UIImage(named: customPointAnnotation.imageName)

        }

        return annotationView
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        return true

    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if (trackLocation) {
            userLocation = locations[0]

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

            DispatchQueue.main.async(execute: {

                self.displayDistance(location: self.recycle, user: self.userLocation)
                self.displayDistance(location: self.trash, user: self.userLocation)
                self.displayDistance(location: self.compost, user: self.userLocation)
                self.displayDistance(location: self.other, user: self.userLocation)

            })
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

    func getDistanceKM(lat1: Float,lon1: Float,lat2: Float,lon2: Float) -> Float {

        let R: Float = 6371.0; // Radius of the earth in km

        let dLat: Float = deg2rad(deg: lat2 - lat1)  // deg2rad below

        let dLon: Float = deg2rad(deg: lon2 - lon1)

        let a: Float = sin(dLat/2.0) * sin(dLat/2.0) + cos(deg2rad(deg: lat1)) * cos(deg2rad(deg: lat2)) * sin(dLon/2.0) * sin(dLon/2.0)

        let c: Float = 2 * atan2(sqrt(a), sqrt(1-a));

        return R * c * 1000.0// Distance in m

    }

    func deg2rad(deg: Float) -> Float {

        return deg * (3.141592654 / 180.0)

    }

    func displayDistance(location: CustomPointAnnotation, user: CLLocation) {

        location.subtitle = "\(Int(round(getDistanceKM(lat1: Float(location.coordinate.latitude), lon1: Float(location.coordinate.longitude), lat2: Float(user.coordinate.latitude), lon2: Float(user.coordinate.longitude))))) m"

    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        let polylineRenderer = MKPolylineRenderer(overlay: overlay)

        polylineRenderer.strokeColor = UIColor.blue

        polylineRenderer.fillColor = UIColor.red

        polylineRenderer.lineWidth = 2

        return polylineRenderer

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
