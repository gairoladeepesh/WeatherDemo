//
//  CitiesListTableTableViewController.swift
//  Weather
//
//  Created by Deepesh Gairola on 18/11/18.
//  Copyright © 2018 Deepesh Gairola. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class CitiesListTableViewController: UITableViewController,NVActivityIndicatorViewable, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let model = WeatherModel()
    var cities =  Array<Any>()
    
    var objWeather = Weather()
    var objLocation:[Location]?
    var selectedLocation: Location?
    var defaultCities = ["Gothenburg", "Stockholm", "Mountain View", "London", "New York", "Berlin"]
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = "Cities"
        self.prepareActivityIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
                self.objWeather = Weather()
                self.getCitiesData()
    }
    
    func getCitiesData()  {
        startAnimating()
        model.getAllCities(completionBlock: {results in
            self.cities = results
            self.stopAnimating()
        })
    }
    
    func prepareActivityIndicator()  {
        NVActivityIndicatorView.DEFAULT_TEXT_COLOR = .black
        NVActivityIndicatorView.DEFAULT_BLOCKER_MESSAGE = "Loading results !"
        NVActivityIndicatorView.DEFAULT_BLOCKER_MESSAGE_FONT = UIFont.boldSystemFont(ofSize: 18)
        NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE = CGSize(width: 50, height: 50)
        NVActivityIndicatorView.DEFAULT_BLOCKER_BACKGROUND_COLOR = .white
        NVActivityIndicatorView.DEFAULT_TYPE = .lineScale
        NVActivityIndicatorView.DEFAULT_COLOR = .lightGray
    }
    
    @IBAction func setupData(_ sender: Any) {
        
        startAnimating()
        self.model.deleteAllData(completionBlock:{success in
            for city in self.defaultCities{
                self.model.createNewCity(city: city, woeid: "")
            }
            self.getCitiesData()
            self.tableView.reloadData()
            self.stopAnimating()
        })
    }
    
    @IBAction func addNewCity(_ sender: Any) {
        showAlertWithTextField()
    }
    
    func showAlertWithTextField() {
        let alertController = UIAlertController(title: "Add City", message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Add", style: .default) { (_) in
            if let txtField = alertController.textFields?.first, let text = txtField.text {
                //                self.startAnimating()
                self.model.getLocationInfo(city: text, completionBlock: { location  in
                    self.objLocation = location
                    self.preparePickerView()
                })
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter City Name"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func preparePickerView()  {
        let message = "\n\n\n\n\n\n"
        let alert = UIAlertController(title: "Please Select City", message: message, preferredStyle: UIAlertController.Style.actionSheet)
        alert.isModalInPopover = true
        
        let pickerView = UIPickerView(frame: CGRect(x: 5, y: 20, width: 400, height: 140))
        //set the pickers datasource and delegate
        pickerView.delegate = self
        pickerView.dataSource = self
        
        //Add the picker to the alert controller
        alert.view.addSubview(pickerView)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {(alert: UIAlertAction!) -> Void in
            //Perform Action
            let selectedRow = pickerView.selectedRow(inComponent: 0)
            self.model.updateCityInfo(location: self.objLocation![selectedRow])
            self.model.getAllCities(completionBlock: {results in
                self.cities = results
                self.tableView.reloadData()
                self.stopAnimating()
            })
        })
        alert.addAction(okAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(cancelAction)
        self.parent!.present(alert, animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.objLocation!.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.objLocation![row].title
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedLocation = self.objLocation![row]
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cities.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "citiesCell", for: indexPath)
        cell.textLabel?.text = (cities[indexPath.row] as AnyObject).value(forKey: "name") as? String
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Check woeid
        if let woeid = (cities[indexPath.row] as AnyObject).value(forKey: "woeid") as? String {
            // If present use this woeid to search for the weather
            model.getCityWeatherInfo(woeid: woeid, completionBlock: {weather in
                self.objWeather = weather
                self.performSegue(withIdentifier: "showWeatherDetails", sender: self)
            })
        }else{
            // if missing, make a call to find woeid of this city, save to Data base. Once saved make a call to search weather
            model.getLocationInfo(city: ((cities[indexPath.row] as AnyObject).value(forKey: "name") as? String)!, completionBlock: { location  in
                self.model.updateCityInfo(location: location.first!)
                self.model.getCityWeatherInfo(woeid: "\(location.first!.woeid)", completionBlock: { weather in
                    self.objWeather = weather
                    self.performSegue(withIdentifier: "showWeatherDetails", sender: self)
                })
            })
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWeatherDetails" {
            
            let controller = segue.destination as! WeatherUpdatesViewController
            controller.weather = self.objWeather
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var segueAction = Bool()
        
        if (identifier == "showWeatherDetails") {
            
            if self.objWeather.weather_state_abbr != nil{
                segueAction = true
            }else{
                segueAction = false
            }
        }
        return segueAction
    }
}
