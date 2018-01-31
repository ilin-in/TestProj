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
    
    init() {
        let realm = try! Realm()
        let realmLocations = realm.objects(Location.self).sorted(byKeyPath: "distance", ascending: true)
        locations = Observable.collection(from: realmLocations)
        startUpdatingLocation()
        if realmLocations.count == 0 {
            appendInitialData()
        }
    }
    
    func addNewLocation(name: String, lat: Double, lng: Double) {
        let realm = try! Realm()
        let location = Location()
        location.isDefault = false
        location.lat = lat
        location.lng = lng
        location.name = name
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
        let scheduler = SerialDispatchQueueScheduler(qos: .userInteractive)
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.rx.didUpdateLocations.map { $0[0] }
            .filter { $0.horizontalAccuracy < kCLLocationAccuracyHundredMeters}
            .observeOn(scheduler)
            .subscribe(onNext: { (location) in
                let realm = try! Realm()
                let realmLocations = realm.objects(Location.self)
                try! realm.write {
                    for realmLocation in realmLocations {
                        // TODO: Include more accurate measuring
                        let distance = CLLocation(latitude: realmLocation.lat, longitude: realmLocation.lng).distance(from: location)
                        realmLocation.distance = distance
                        realmLocation.distanceString = String.init(format: NSLocalizedString("%.2f km", comment: ""), distance / 1000)
                    }
                }
                print(Thread.current.debugDescription)
            })
            .disposed(by: disposeBag)
    }
    
}
