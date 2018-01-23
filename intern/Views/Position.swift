//
//  Position.swift
//  intern
//
//  Created by Jian Zhai on 2018/1/23.
//  Copyright © 2018年 Jian Zhai. All rights reserved.
//

import Foundation
import MapKit
import Contacts

class Position: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    var willBeSaved = true
    
    init(title: String, locationName: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
}
