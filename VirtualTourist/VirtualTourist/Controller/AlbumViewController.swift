//
//  AlbumViewController.swift
//  VirtualTourist
//
//  Created by Tony Mackay on 07/05/2020.
//  Copyright © 2020 ViewModel Software. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}

class AlbumViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let reuseIdentifier = "photoCollectionViewCell"
    var dataController: DataController!
    var pin: Pin!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad (Lat: \(pin.latitude) Long: \(pin.longitude))")
        addPinToMap(latitude: pin.latitude, longitude: pin.longitude)
        
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        setupFetchedResultsController()
        downloadAndStorePhotos()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }

    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait
        }
    }
    
    @IBAction func newCollectionTapped(_ sender: Any) {
        print("newCollectionTapped")
        let photosToDelete = fetchedResultsController.fetchedObjects ?? []
        for photoToDelete in photosToDelete {
            guard let indexPath = fetchedResultsController.indexPath(forObject: photoToDelete) else { break }
            deletePhoto(indexPath: indexPath)
        }
        downloadAndStorePhotos()
    }
    
    func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortByDate: NSSortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortByDate]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func addPinToMap(latitude: Double, longitude: Double) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        // zoom to user location
        let regionRadius: CLLocationDistance = 10000
        let viewRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(viewRegion, animated: false)
    }
    
    func downloadAndStorePhotos() {
        guard let photos = fetchedResultsController.fetchedObjects else { return }
        if photos.count == 0 {
            
            let page = Int(pin.page) + 1
            print("no local photos - search for URLS on Flickr page \(page)")
            
            FlickrClient.search(latitude: pin.latitude, longitude: pin.longitude, page: page) { response, error in
                guard let response = response else { return }
                for photo in response.photos.photo {
                    let newPhoto = Photo(context: self.dataController.viewContext)
                    newPhoto.creationDate = Date()
                    newPhoto.url = photo.url
                    newPhoto.pin = self.pin
                }
                self.pin.page = Int64(page)
                self.dataController.saveContext()
            }
        } else {
            print("Found \(photos.count) local photos")
        }
    }
    
    func deletePhoto(indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(photoToDelete)
        dataController.saveContext()
    }
    
    
    var ops: [BlockOperation] = []

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                ops.append(BlockOperation(block: { [weak self] in
                    self?.collectionView.insertItems(at: [newIndexPath!])
                }))
            case .delete:
                ops.append(BlockOperation(block: { [weak self] in
                    self?.collectionView.deleteItems(at: [indexPath!])
                }))
            case .update:
                ops.append(BlockOperation(block: { [weak self] in
                    self?.collectionView.reloadItems(at: [indexPath!])
                }))
            case .move:
                ops.append(BlockOperation(block: { [weak self] in
                    self?.collectionView.moveItem(at: indexPath!, to: newIndexPath!)
                }))
            @unknown default:
                break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({ () -> Void in
            for op: BlockOperation in self.ops { op.start() }
        }, completion: { (finished) -> Void in self.ops.removeAll() })
    }

    deinit {
        for o in ops { o.cancel() }
        ops.removeAll()
    }
}

extension AlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        
        let photo = fetchedResultsController.object(at: indexPath)
        if let imageData = photo.image {
            cell.imageView.image = UIImage(data: imageData)
        } else {
            // try to download image
            FlickrClient.download(url: photo.url ?? "") { data, error in
                guard let data = data else { return }
                photo.image = data
                self.dataController.saveContext()
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        deletePhoto(indexPath: indexPath)
    }
}
