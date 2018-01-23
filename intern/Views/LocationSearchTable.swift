//
//  LocationSearchTable.swift
//  intern
//
//  Created by Jian Zhai on 2018/1/23.
//  Copyright © 2018年 Jian Zhai. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchTable : UITableViewController {
    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
}

extension LocationSearchTable : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
