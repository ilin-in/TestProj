//
//  LocationTableViewCell.swift
//  TestProj
//
//  Created by Ilya Ilin on 1/30/18.
//  Copyright © 2018 Ilya Ilin. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class LocationTableViewCell: UITableViewCell {
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    
    var location: Location? = nil {
        didSet {
            guard let location = location else { return }
            lblTitle.text = location.name
            lblDistance.text = location.distanceString
            lblStatus.isHidden = !location.isDefault
        }
    }
}
