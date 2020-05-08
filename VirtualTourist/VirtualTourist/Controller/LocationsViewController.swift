//
//  LocationsViewController.swift
//  VirtualTourist
//
//  Created by Tony Mackay on 07/05/2020.
//  Copyright © 2020 ViewModel Software. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class LocationsViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController: DataController!
    var pins: [Pin] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMapRegion()
        loadPins()
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        recognizer.numberOfTapsRequired = 1
        recognizer.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(recognizer)
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        saveMapRegion()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            print("didSelect (Lat: \(annotation.coordinate.latitude) Long: \(annotation.coordinate.longitude)")
        }
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
    
    @objc func handleLongPress(recognizer: UIGestureRecognizer) {
        if recognizer.state != .began { return }
        let touchPoint = recognizer.location(in: mapView)
        
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        addPinToMap(latitude: coordinate.latitude, longitude: coordinate.longitude)

        let pin = Pin(context: dataController.viewContext)
        pin.longitude = coordinate.longitude
        pin.latitude = coordinate.latitude
        dataController.saveContext()
    }
    
    func loadPins() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        //fetchRequest.sortDescriptors = []
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            pins = result
            for pin in pins {
                addPinToMap(latitude: pin.latitude, longitude: pin.longitude)
            }
        }
    }
    
    func addPinToMap(latitude: Double, longitude: Double) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapView.addAnnotation(annotation)
    }
}
