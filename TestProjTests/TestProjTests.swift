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
        self.measure {
            let locationsViewModel = LocationsViewModel()
            locationsViewModel.locations.subscribe(onNext: { (results) in
                if results.count > 0 {
                    itemsExpectation.fulfill()
                }
            }).disposed(by: disposeBag)
        }
        
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
        Observable.from(object: realm.object(ofType: Location.self, forPrimaryKey: locationName)!).subscribe( onNext: { (location) in
            if location.note == testNote {
                updateNoteExpectation.fulfill()
            }
        }).disposed(by: disposeBag)
        let viewModel = NoteViewModel(locationName: locationName)
        viewModel.updateNote(newNote: testNote)
        wait(for: [updateNoteExpectation], timeout: 4)
    }
}
