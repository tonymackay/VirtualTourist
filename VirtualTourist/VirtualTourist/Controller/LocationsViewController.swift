//
//  LocationsViewController.swift
//  VirtualTourist
//
//  Created by Tony Mackay on 07/05/2020.
//  Copyright © 2020 ViewModel Software. All rights reserved.
//

import UIKit
import MapKit

class LocationsViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMapRegion()
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        saveMapRegion()
    }
    
    func saveMapRegion() {
        let latitude: Double = mapView.region.center.latitude
        let longitude: Double = mapView.region.center.longitude
        let latitudeDelta: Double = mapView.region.span.latitudeDelta
        let longitudeDelta: Double = mapView.region.span.longitudeDelta
        
        print("saveMapRegion (Lat: \(latitude) Long: \(longitude) LatDelta: \(latitudeDelta) LongDelta \(longitudeDelta)")
        
        UserDefaults.standard.set(latitude, forKey: Strings.latitude)
        UserDefaults.standard.set(longitude, forKey: Strings.longitude)
        UserDefaults.standard.set(latitudeDelta, forKey: Strings.latitudeDelta)
        UserDefaults.standard.set(longitudeDelta, forKey: Strings.longitudeDelta)
    }
    
    func loadMapRegion()
    {
        let latitude = UserDefaults.standard.double(forKey: Strings.latitude)
        let longitude = UserDefaults.standard.double(forKey: Strings.longitude)
        let latitudeDelta = UserDefaults.standard.double(forKey: Strings.latitudeDelta)
        let longitudeDelta = UserDefaults.standard.double(forKey: Strings.longitudeDelta)
        
        print("loadMapRegion (Lat: \(latitude) Long: \(longitude) LatDelta: \(latitudeDelta) LongDelta \(longitudeDelta)")
        
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
}
