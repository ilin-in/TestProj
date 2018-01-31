//
//  NoteViewModel.swift
//  TestProj
//
//  Created by Ilya Ilin on 1/31/18.
//  Copyright © 2018 Ilya Ilin. All rights reserved.
//

import Foundation
import RealmSwift
import RxRealm
import RxSwift

class NoteViewModel {
    let location: Observable<Location>
    fileprivate var locationObject: Location? = nil
    
    init(locationName: String) {
        let realm = try! Realm()
        if let location = realm.object(ofType: Location.self, forPrimaryKey: locationName) {
            self.locationObject = location
            self.location = Observable.from(object: location)
        }
        else {
            location = Observable.empty()
        }
    }
    
    func updateNote(newNote: String?) {
        let realm = try! Realm()
        try! realm.write {
            locationObject?.note = newNote
        }
    }
}
