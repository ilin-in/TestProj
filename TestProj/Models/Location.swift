//
//  Location.swift
//  TestProj
//
//  Created by Ilya Ilin on 1/30/18.
//  Copyright © 2018 Ilya Ilin. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class Location: Object, Mappable {
    @objc dynamic var name = ""
    @objc dynamic var lat: Double = 0
    @objc dynamic var lng: Double = 0
    @objc dynamic var isDefault: Bool = true
    @objc dynamic var distanceString: String? = nil
    @objc dynamic var distance: Double = 0
    @objc dynamic var note: String? = nil
    
    override class func primaryKey() -> String? {
        return "name"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        lat <- map["lat"]
        lng <- map["lng"]
    }
}
