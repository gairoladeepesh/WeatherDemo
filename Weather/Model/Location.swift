//
//  Location.swift
//  Weather
//
//  Created by Deepesh Gairola on 18/11/18.
//  Copyright © 2018 Deepesh Gairola. All rights reserved.
//

import Foundation

struct Location : Codable{
    
    var title : String
    var location_type: String
    var woeid:  Int
    var latt_long : String
    
}
