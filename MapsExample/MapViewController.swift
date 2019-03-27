//
//  ViewController.swift
//  MapsExample
//
//  Created by LOWCOST on 27/03/19.
//  Copyright © 2019 pagseguro. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var timer: Timer?
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.addAnnotation(mapView.userLocation)
        
        mapView.delegate = self
        locationManager.delegate = self
        searchBar.delegate = self
        
        enableLocationServices()
        
//        let GCLocation = CLLocation(latitude: -23.570991, longitude: -46.6520747)
//        addPin(title: "Google Campus", location: GCLocation)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !Locations.myPlaces.isEmpty {
            _ = Locations.myPlaces.compactMap { item in
                self.addPin(title: item.placemark.name, location: item.placemark.location)
            }
        }
    }
    
    func enableLocationServices() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        switch CLLocationManager.authorizationStatus() {
        case .denied, .restricted:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
    
    func addPin(title:String?, location: CLLocation?) {
        guard let location = location else { return }
        
        let pin = MKPointAnnotation()
        pin.title = title
        pin.coordinate = location.coordinate
        
        mapView.addAnnotation(pin)
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last, let lat = locations.last?.coordinate.latitude, let log = locations.last?.coordinate.longitude else {
            return
        }
        
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let viewRegion = MKCoordinateRegion(center: loc.coordinate, span: span)
        
        mapView.setRegion(viewRegion, animated: true)
        
        print("****")
        print("\(lat) \(log)")
        
        Locations.region = mapView.region
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch CLLocationManager.authorizationStatus() {
        case .denied, .restricted:
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
    
    @objc func searchLocations() {
        guard let mapView = mapView, let text = searchBar.text else { return }
        
        let request = MKLocalSearch.Request()
        
        Locations.region = mapView.region
        
        request.naturalLanguageQuery = text
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { (response, _) in
            guard let response = response else {
                return
            }
            
            let annotationToRemove = mapView.annotations.filter { $0 !== mapView.userLocation }
            mapView.removeAnnotations(annotationToRemove)
            
            _ = response.mapItems.compactMap { item in
                self.addPin(title: item.placemark.name, location: item.placemark.location)
            }
            
            self.view.endEditing(true)
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("didSelect")
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        print(userLocation.coordinate)
    }
}

extension MapViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        timer?.invalidate()
        
        
        timer = Timer.scheduledTimer(timeInterval: 0.8,
                                     target: self,
                                     selector: #selector (searchLocations),
                                     userInfo: nil,
                                     repeats: false)
    }
}
