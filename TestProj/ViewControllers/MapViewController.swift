//
//  MapViewController.swift
//  TestProj
//
//  Created by Ilya Ilin on 1/31/18.
//  Copyright © 2018 Ilya Ilin. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import RxMKMapView
import RxSwift
import RxGesture

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    let viewModel = LocationsViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.centerCoordinate = CLLocationCoordinate2D(latitude: -33.795905, longitude: 151.211848)
        
        viewModel.locations.map { results in
            self.mapView.removeAnnotations(self.mapView.annotations)
            return results.map({ location in
                let annotation = MKPointAnnotation()
                annotation.title = location.name
                annotation.coordinate = CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
                return annotation
            }
        )}
        .bind(to: mapView.rx.annotations).disposed(by: disposeBag)
        
        mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didLongPressOnMap(sender:))))
    }
    
    @objc func didLongPressOnMap(sender: UILongPressGestureRecognizer) {
        guard sender.state == .ended else  { return }
        let location = self.mapView.convert(sender.location(in: self.mapView), toCoordinateFrom: self.mapView)
        showLocationNameRequest(location: location)
    }
    
    func showLocationNameRequest(location: CLLocationCoordinate2D) {
        let alertController = UIAlertController(title: NSLocalizedString("Please provide a name", comment: ""), message: nil, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default, handler: {
            alert -> Void in
            if let locationName = alertController.textFields?.first?.text {
                self.viewModel.addNewLocation(name: locationName, lat: location.latitude, lng: location.longitude)
            }
        })
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)
        alertController.addTextField { $0.placeholder = NSLocalizedString("Location name", comment: "") }
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
}

class LocationAnnotation: NSObject, MKAnnotation {
    var location: Location? = nil
    var coordinate: CLLocationCoordinate2D {
        if let location = location {
            return CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
        }
        return CLLocationCoordinate2D()
    }
    
    var title: String? {
        return location?.name
    }
    
    init(location: Location) {
        super.init()
        self.location = location
    }
}
