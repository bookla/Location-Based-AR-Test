//
//  PlaceAnnotation.swift
//  AR TEST
//
//  Created by Book Lailert on 30/6/20.
//  Copyright © 2020 Book Lailert. All rights reserved.
//

import Foundation
import MapKit

class PlaceAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let index: Int?
    
    init(location: CLLocationCoordinate2D, title: String, index:Int) {
        self.coordinate = location
        self.title = title
        self.index = index
        
        super.init()
    }
}
