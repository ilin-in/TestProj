//
//  TestProjTests.swift
//  TestProjTests
//
//  Created by Ilya Ilin on 1/30/18.
//  Copyright © 2018 Ilya Ilin. All rights reserved.
//

import XCTest
import RealmSwift
import RxSwift
import RxRealm
import CoreLocation
@testable import TestProj

class TestProjTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExtractingLocations() {
        let itemsExpectation = expectation(description: "Extract locations")
        let disposeBag = DisposeBag()
        let _ = LocationsViewModel()
        let realm = try! Realm()
        Observable.collection(from: realm.objects(Location.self)).skip(1).subscribe(onNext: { results in
            XCTAssert(results.count > 0)
            itemsExpectation.fulfill()
        }).disposed(by: disposeBag)
    
        wait(for: [itemsExpectation], timeout: 4)
    }
    
    func testEditableNote() {
        let realm = try! Realm()
        let locationName = "Test name"
        let testNote = "Test Note"
        
        let loc = Location()
        loc.name = locationName
        try! realm.write {
            realm.add(loc)
        }
        
        let updateNoteExpectation = expectation(description: "Update note")
        let disposeBag = DisposeBag()
        Observable.from(object: realm.object(ofType: Location.self, forPrimaryKey: locationName)!, emitInitialValue: false).subscribe( onNext: { (location) in
            XCTAssert(location.note == testNote)
            updateNoteExpectation.fulfill()
        }).disposed(by: disposeBag)
        let viewModel = NoteViewModel(locationName: locationName)
        viewModel.updateNote(newNote: testNote)
        wait(for: [updateNoteExpectation], timeout: 4)
    }
    
    func testAddNewLocation() {
        let locationName = "Test name"
        let locationCoords = CLLocationCoordinate2D(latitude: -33.897233, longitude: 151.193440)
        
        let locationsViewModel = LocationsViewModel()
        locationsViewModel.addNewLocation(name: locationName, lat: locationCoords.latitude, lng: locationCoords.longitude)
        
        let realm = try! Realm()
        let location = realm.object(ofType: Location.self, forPrimaryKey: locationName)
        XCTAssertNotNil(location)
        XCTAssertEqual(location?.name, locationName)
        XCTAssertEqual(location?.lat, locationCoords.latitude)
        XCTAssertEqual(location?.lng, locationCoords.longitude)
    }
}
