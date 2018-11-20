//
//  WeatherUpdatesViewController.swift
//  Weather
//
//  Created by Deepesh Gairola on 18/11/18.
//  Copyright © 2018 Deepesh Gairola. All rights reserved.
//

import UIKit

class WeatherUpdatesViewController: UIViewController {
    
    @IBOutlet weak var weatherState: UIImageView!
    @IBOutlet weak var lblWeatherState: UILabel!
    @IBOutlet weak var lblTemp: UILabel!
    @IBOutlet weak var lblMxMinTemp: UILabel!
    @IBOutlet weak var lblHumidity: UILabel!
    
    var weather = Weather()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureWeather()
        
        self.title = "Details"
    }
    
    func configureWeather()  {
        
        let imageUrl = "\(WeatherModel().imageURL)\(self.weather.weather_state_abbr!).png"
        self.lblWeatherState.text = self.weather.weather_state_name!
        
        self.lblTemp.text = String(format:"Temp  %.1f°", self.weather.the_temp!)
        self.lblMxMinTemp.text = String(format:"Max  %.1f° Min %.1f°",self.weather.max_temp!, self.weather.min_temp!)
        self.lblHumidity.text = "Humidity \(self.weather.humidity!)%"
        self.weatherState.imageFromServerURL(urlString: imageUrl, defaultImage: "wait.png")
    }
}
