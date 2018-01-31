//
//  LocationsViewModel.swift
//  TestProj
//
//  Created by Ilya Ilin on 1/30/18.
//  Copyright © 2018 Ilya Ilin. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import ObjectMapper
import RxRealm
import CoreLocation

class LocationsViewModel {
    let locations: Observable<Results<Location>>!
    fileprivate let disposeBag = DisposeBag()
    fileprivate let locationManager = CLLocationManager()
    fileprivate var location: Observable<CLLocation>? = nil
    fileprivate let utilityScheduler = ConcurrentDispatchQueueScheduler(qos: .utility)
    fileprivate var lastUsedCoord: CLLocation? = nil
    
    init() {
        let realm = try! Realm()
        let realmLocations = realm.objects(Location.self).sorted(byKeyPath: "distance", ascending: true)
        locations = Observable.collection(from: realmLocations)
        startUpdatingLocation()
        if realmLocations.count == 0 {
            appendInitialData()
        }
        
        Observable.combineLatest(locationManager.rx.didUpdateLocations.map { $0[0] }
            .filter { $0.horizontalAccuracy < kCLLocationAccuracyHundredMeters}, locations) { (coords, locs) -> String in
                print(1)
                return ""
        }.subscribe().disposed(by: disposeBag)
    }
    
    func addNewLocation(name: String, lat: Double, lng: Double) {
        let realm = try! Realm()
        let location = Location()
        location.isDefault = false
        location.lat = lat
        location.lng = lng
        location.name = name
        if let lastCoords = self.lastUsedCoord {
            location.distance = LocationsViewModel.getDistance(from: CLLocation(latitude: lat, longitude: lng), to: lastCoords)
            location.distanceString = LocationsViewModel.distanceFormat(distance: location.distance)
        }
        try! realm.write {
            realm.add(location)
        }
    }
    
    fileprivate func appendInitialData() {
        BundleExtractor.extractLocations(type: Location.self, JSONfile: "locations.json")
            .observeOn(utilityScheduler).subscribe(onNext: { (items) in
                let realm = try! Realm()
                try! realm.write {
                    realm.add(items, update: true)
                }
            }).disposed(by: disposeBag)
    }
    
    fileprivate func startUpdatingLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.rx.didUpdateLocations.map { $0[0] }
            .filter { $0.horizontalAccuracy < kCLLocationAccuracyHundredMeters}
            .observeOn(SerialDispatchQueueScheduler(qos: .userInteractive))
            .subscribe(onNext: { (location) in
                self.lastUsedCoord = location
                self.locationManager.stopUpdatingLocation()
                let realm = try! Realm()
                let realmLocations = realm.objects(Location.self)
                try! realm.write {
                    for realmLocation in realmLocations {
                        realmLocation.distance = LocationsViewModel.getDistance(from: CLLocation(latitude: realmLocation.lat, longitude: realmLocation.lng), to: location)
                        realmLocation.distanceString = LocationsViewModel.distanceFormat(distance: realmLocation.distance)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    fileprivate class func getDistance(from: CLLocation, to: CLLocation) -> CLLocationDistance {
        // TODO: Apply more accurate measuring
        return to.distance(from: from)
    }
    
    fileprivate class func distanceFormat(distance: CLLocationDistance) -> String {
        return String.init(format: NSLocalizedString("%.2f km", comment: ""), distance / 1000)
    }
}
