//
//  Weather.swift
//  Weather
//
//  Created by Deepesh Gairola on 18/11/18.
//  Copyright © 2018 Deepesh Gairola. All rights reserved.
//

import Foundation
struct Weather : Codable{
    
    var id:Int?
    var weather_state_name: String?
    var weather_state_abbr: String?
    var wind_direction_compass: String?
    var applicable_date: String?
    var min_temp : Float?
    var max_temp : Float?
    var the_temp : Float?
    var wind_speed : Float?
    var wind_direction : Float?
    var air_pressure :Float?
    var humidity : Int?
    var visibility : Float?
    var predictability :Int?
}
