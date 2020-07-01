//
//  pinAnchor.swift
//  AR TEST
//
//  Created by Book Lailert on 1/7/20.
//  Copyright © 2020 Book Lailert. All rights reserved.
//

import Foundation
import ARKit


extension ARAnchor {
    struct pinInfo {
        static var _name:String = "TEST PIN"
    }
    
    var name:String {
        get {
            return pinInfo._name
        }
        set(newName) {
            pinInfo._name = newName
        }
    }
}

