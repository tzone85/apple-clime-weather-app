//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    //let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    let APP_ID = "1ecc5c42d35d24d19ead5f81abacb492"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters  //the more accurate, the longer it's going to take and the more batt you'll consume
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()     //read up on this Assynchronous method. works on the background
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherData(url: String, parameters: [String : String]){
        
        //getting data from the api, and reacting accordingly depending on if the response is successful or not
        //this takes place asynchronously in the background of the screen. Nothing gets held up on the frontend
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON{
            response in
            if response.result.isSuccess{
                print("Success! Got the weather data")
                
                //force unwrapping the value for we've already made sure that it is not empty.
                let weatherJSON : JSON = JSON(response.result.value!)
                print(weatherJSON)
                self.updateWeatherData(json: weatherJSON)
                
            }else{
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    
    func updateWeatherData(json: JSON){
        //grabbing this data from the json raw file data, calling it buy making use of the SwiftyJSON library from our pods
        if let tempResults = json["main"]["temp"].double{
            weatherDataModel.temperature = Int(tempResults - 273.15)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            //call updateUI method after the weather data has been loaded
            updateUIWithWeatherData()
        }else{
            cityLabel.text = "Weather Unavailable"
        }
    }
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData(){
        
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = String(weatherDataModel.temperature)
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //getting the last and most accurate value from within the array of locations
        let location = locations[locations.count - 1]
        
        //if the value we get is less than zero, then that's an invalid result
        if location.horizontalAccuracy > 0{
            
            //if true thus error and location manager must stop updating the locations
            locationManager.stopUpdatingLocation()
            
            //to prevent the json file from calling itself multiple times. So this is sort of like a centinal
            locationManager.delegate = nil
            
            print("longitude = \(location.coordinate.longitude)", "latitude = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            //making use of a Dictionery for the first time
            let params : [String : String] = ["lat" : (latitude), "lon" : longitude, "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
        
        
    }
    
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Locatio unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    

    
    //Write the PrepareForSegue Method here
    
    
    
    
    
}


