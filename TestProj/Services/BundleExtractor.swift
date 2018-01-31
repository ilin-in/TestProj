//
//  BundleExtractor.swift
//  TestProj
//
//  Created by Ilya Ilin on 1/30/18.
//  Copyright © 2018 Ilya Ilin. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift
import ObjectMapper

class BundleExtractor {
    class func extractLocations<T:Object>(type: T.Type, JSONfile: String) -> Observable<[T]> where T:Mappable {
        return Observable.create({ (observer) -> Disposable in
            if let resourceURL = Bundle.main.url(forResource: JSONfile, withExtension: nil) {
                do {
                    let data = try Data(contentsOf: resourceURL)
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    if let rootObject = (json as? [String: Any]), let objects = Mapper<T>().mapArray(JSONObject: rootObject["locations"])  {
                        observer.onNext(objects)
                    }
                    observer.onCompleted()
                }
                catch let err {
                    observer.onError(err)
                }
            }
            return Disposables.create()
        }).observeOn(SerialDispatchQueueScheduler(qos: .userInteractive))
    }
}
