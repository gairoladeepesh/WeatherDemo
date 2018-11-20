//
//  WeatherModel.swift
//  Weather
//
//  Created by Deepesh Gairola on 18/11/18.
//  Copyright © 2018 Deepesh Gairola. All rights reserved.
//

import Foundation
import CoreData

class WeatherModel: NSObject {
    
    let requestHandler = RequestHandler()
    var cities =  Array<Any>()
    let serverURLPrefix = "https://www.metaweather.com/api/"
    let imageURL = "https://www.metaweather.com/static/img/weather/png/64/"
    var defaultCities = ["Gothenburg", "Stockholm", "Mountain View", "London", "New York", "Berlin"]
    
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    }
    
    var nextDay: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let tomorrowDateString = dateFormatter.string(from: tomorrow)
        
        return tomorrowDateString
    }
    // MARK: - Core Data stack
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Weather")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func createNewCity(city: String, woeid: String) {
        
        let context = persistentContainer.viewContext
        let cityEntity = NSEntityDescription.entity(forEntityName: "Cities", in: context)
        
        let cityObject = NSManagedObject(entity: cityEntity!, insertInto: context)
        
        if city != "" {
            cityObject.setValue(city, forKeyPath: "name")
        }
        if woeid != "" {
            cityObject.setValue(woeid, forKeyPath: "woeid")
        }
        
        do {
            try context.save()
        } catch let error as NSError {
            print(error)
        }
        
    }
    
    func getAllCities(completionBlock: @escaping (Array<Any>) -> Void){
        
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cities")
        
        do {
            let result = try context.fetch(fetchRequest)
            self.cities.removeAll()
            for data in result as! [NSManagedObject]{
                
                let city = ["name": data.value(forKey: "name") as? String,
                            "woeid": data.value(forKey: "woeid") as? String
                ]
                self.cities.append(city)
            }
        } catch  {
            print("failed")
        }
        completionBlock(cities)
    }
    
    func getCityInfo(city: String) -> Array<Any>{
        
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cities")
        fetchRequest.predicate = NSPredicate(format: "name = %@", city)
        do {
            let result = try context.fetch(fetchRequest)
            self.cities.removeAll()
            for data in result as! [NSManagedObject]{
                
                let city = ["name": data.value(forKey: "name") as? String,
                            "woeid": data.value(forKey: "woeid") as? String
                ]
                self.cities.append(city)
            }
        } catch  {
            print("failed")
        }
        return cities
    }
    
    func deleteAllData(completionBlock: @escaping (Bool) -> Void)  {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cities")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            completionBlock(true)
        } catch {
            // let error as NSError : In case error string needs to be sent
            // TODO: handle the error
            completionBlock(false)
        }
    }
    func updateCityInfo(location: Location){
        
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cities")
        fetchRequest.predicate = NSPredicate(format: "name = %@", location.title)
        do {
            
            let result = try context.fetch(fetchRequest)
            
            if result.count > 0 {
                let objectUpdate = result[0] as! NSManagedObject
                
                objectUpdate.setValue(location.title, forKey: "name")
                objectUpdate.setValue("\(location.woeid)", forKey: "woeid")
                
            }else{
                self.createNewCity(city: location.title, woeid: "\(location.woeid)")
            }
            
            do {
                try context.save()
            } catch let error as NSError {
                print(error)
            }
        } catch  {
            print("failed")
        }
    }
    

    func getLocationInfo(city: String, completionBlock: @escaping ([Location]) -> Void) {
        
        let url = serverURLPrefix+"location/search/?query=\(city)"
        
        _ = requestHandler.getLocationUpdatesFromServer(withURL: url, completionBlock: { location in
            //return location object
            completionBlock(location)
        })
    }
    
    func getCityWeatherInfo(woeid: String, completionBlock: @escaping (Weather) -> Void) {
        
        let url = serverURLPrefix+"location/\(woeid)/\(nextDay)/"
        
        _ = requestHandler.getWeatherUpdatesFromServer(withURL: url, completionBlock: { weather in
            completionBlock(weather)
        })
    }
    
    
}
