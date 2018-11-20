//
//  RequestHandler.swift
//  Weather
//
//  Created by Deepesh Gairola on 18/11/18.
//  Copyright © 2018 Deepesh Gairola. All rights reserved.
//

import UIKit

class RequestHandler: NSObject {
    
    func getLocationUpdatesFromServer(withURL: String, completionBlock: @escaping ([Location]) -> Void) {
        
        let url = NSURL(string: withURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)
        
        let request = NSMutableURLRequest(url: url! as URL)
        let session = URLSession.shared
        
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            
            if let data = data {
                
                guard let location = try? JSONDecoder().decode([Location].self, from: data) else {
                    print("Error: Couldn't decode data")
                    return
                }
                
                DispatchQueue.main.async {
                    completionBlock(location)
                }
            }
        }
        task.resume()
    }
    
    func getWeatherUpdatesFromServer(withURL: String, completionBlock: @escaping (Weather) -> Void) {
        
        let url = NSURL(string: withURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)
        
        let request = NSMutableURLRequest(url: url! as URL)
        let session = URLSession.shared
        
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            
            if let data = data {
                
                guard let weatherInfo = try? JSONDecoder().decode([Weather].self, from: data) else {
                    print("Error: Couldn't decode data")
                    return
                }
                
                DispatchQueue.main.async {
                    completionBlock(weatherInfo.first!)
                }
            }
        }
        task.resume()
    }
}
extension UIImageView {
    
    func imageFromServerURL(urlString: String, defaultImage : String?) {
        
        if let defaultImg = defaultImage {
            self.image = UIImage(named: defaultImg)
        }
        
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error ?? "error")
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
            })
            
        }).resume()
    }
}
