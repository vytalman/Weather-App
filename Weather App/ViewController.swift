//
//  ViewController.swift
//  Weather App
//
//  Created by Ryan Mesa on 5/3/23.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cityInfolabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var minMaxTemperatureLabel: UILabel!
    
    enum TemperatureScale {
        case fahrenheit
        case celsius
    }
    var tempScale: TemperatureScale = .fahrenheit
    var weatherDataHandler: WeatherDataHandler!
    var currentDay: Day = .today
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dateLabel.text = DateHandler.todaysDate
    }
    
    @IBAction func chooseTempScale(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                tempScale = .celsius
                displayWeatherData()
            case 1:
                tempScale = .fahrenheit
                displayWeatherData()
            default:
                tempScale = .fahrenheit
                displayWeatherData()
        }
    }
    
    @IBAction func endEditingTextField(_ sender: UITextField) {
        let baseURLString = "https://api.openweathermap.org/data/2.5/forecast?q="
        let APIKeyString = "&appid=4456fb3d92a65e2359141edd398865a3"
        guard var cityString = sender.text else { return }
        
        if cityString.contains(" ") {
            cityString = cityString.replacingOccurrences(of: " ", with: "%20")
        }
        if let finalURL = URL(string: baseURLString + cityString + APIKeyString) {
            requestWeatherData(url: finalURL)
        } else {
            print("Malformed URL")
        }
    }
    
    func requestWeatherData(url: URL) {
        let task = URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            if let urlResponse = response {
                print(urlResponse)
            }
            if let errorResponse = error {
                print(errorResponse)
            } else if let dataResponse = data {
                self.weatherDataHandler = WeatherDataHandler(_data: dataResponse)
                self.weatherDataHandler.decodeData()
                
                let delay = DispatchTime.now() + 1
                DispatchQueue.main.asyncAfter(deadline: delay, execute: {
                    self.displayWeatherData()
                })
            }
        }
        task.resume()
    }
    
    func convertKToC(kelvin: Double) -> Double {
        return kelvin - 273.15
    }
    
    func convertKToF(kelvin: Double) -> Double {
        return (kelvin - 273.15) * 9 / 5 + 32
    }
    
    func displayWeatherData() {
        guard let weatherDataHandler = weatherDataHandler else { return }
        if let city = weatherDataHandler.cityString {
            self.cityInfolabel.text = city
        }
        
        var day: WeatherByDay?
        switch self.currentDay {
            case .today:
                day = weatherDataHandler.todaysData
                dateLabel.text = DateHandler.todaysDate
            case .tomorrow:
                day = weatherDataHandler.tomorrowsData
                dateLabel.text = DateHandler.tomorrowsDate
        }
        if let currentDay = day {
            if tempScale == .fahrenheit {
                temperatureLabel.text = "\(Int(convertKToF(kelvin: currentDay.averageTemp)))℉"
                minMaxTemperatureLabel.text = "Min: \(Int(convertKToF(kelvin: currentDay.averageMinTemp)))℉, Max: \(Int(convertKToF(kelvin: currentDay.averageMaxTemp)))℉"
                getWeatherIcon(iconString: currentDay.iconString)
            } else if tempScale == .celsius {
                temperatureLabel.text = "\(Int(convertKToC(kelvin: currentDay.averageTemp)))℃"
                minMaxTemperatureLabel.text = "Min: \(Int(convertKToC(kelvin: currentDay.averageMinTemp)))℃, Max: \(Int(convertKToC(kelvin: currentDay.averageMaxTemp)))℃"
                getWeatherIcon(iconString: currentDay.iconString)
            }
        } else {
            temperatureLabel.text = "No data to display"
            minMaxTemperatureLabel.text = "No data to display"
        }
    }
    
    func getWeatherIcon(iconString: String) {
        let baseURLString = "https://openweathermap.org/img/wn/"
        let endURLString = ".png"
        guard let iconURL = URL(string: baseURLString + iconString + endURLString) else { return }
        
        let task = URLSession.shared.dataTask(with: iconURL) {
            (data, response, error) in
            if let urlResponse = response {
                print(urlResponse)
            }
            if let errorResponse = error {
                print(errorResponse)
            } else if let dataResponse = data {
                let delay = DispatchTime.now() + 1
                DispatchQueue.main.asyncAfter(deadline: delay, execute: {
                    self.displayIconImage(data: dataResponse)
                })
            }
        }
        task.resume()
    }
    
    func displayIconImage(data: Data) {
        if let image = UIImage(data: data) {
            self.imageView.image = image
        } else {
            printContent("Could not convert image")
        }
    }
    
    @IBAction func pressTodayButton(_ sender: UIBarButtonItem) {
        currentDay = .today
        displayWeatherData()
    }
    
    @IBAction func pressTomorrowButton(_ sender: UIBarButtonItem) {
        currentDay = .tomorrow
        displayWeatherData()
    }
    
}

