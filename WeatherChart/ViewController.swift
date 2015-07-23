//
//  ViewController.swift
//  WeatherChart
//
//  Created by Sho Tanaka on 7/12/15.
//  Copyright (c) 2015 Sho Tanaka. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, NSURLSessionDelegate, NSURLSessionDataDelegate{
    
    var myLocationManager:CLLocationManager!
    
    var myLatitudeLabel:UILabel!
    var myLongitudeLabel:UILabel!
    
    @IBOutlet weak var myForecast: UILabel!
    @IBOutlet weak var myForecastArea: UILabel!

    @IBOutlet weak var myBtnWeatherInfo: UIButton!
    @IBOutlet weak var myBtnGetWeather: UIButton!

    var country: String! = "unknown"
    var area: String!
    
    var _type: String = ""

    @IBAction func mySurfChart(sender : UIButton) {
        println(__FUNCTION__, __LINE__)
        _type = "surf"
        performSegueWithIdentifier("segue", sender: nil)
    }

    @IBAction func my500hpa(sender: UIButton) {
        _type = "500hpa"
        performSegueWithIdentifier("segue", sender: nil)
    }

    @IBAction func myEnsemble(sender: UIButton) {
        _type = "ensemble"
        performSegueWithIdentifier("segue", sender: nil)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "segue") {
            var chartView: ChartViewController = segue.destinationViewController as! ChartViewController
            chartView._type = _type
        }
    }
    
    
    @IBAction func getLocationData(sender: AnyObject) {
        self.myForecastArea.text = "通信中..."
        myLocationManager.startUpdatingLocation()
    }

    
    @IBAction func getWeatherInfo(sender: AnyObject) {
        self.myForecast.text = "通信中..."
        var todayCondition:NSString = "unknown"
        var prediction:NSString = "unknown"


        jsonPost( {prediction in
        
            println(" in JsonPOST")
            println("self.prediction = \(prediction)")
            todayCondition = prediction as! NSString
            
            
            switch todayCondition {
                case "Clear":
                    self.myForecast.textColor = UIColor.redColor()
                    self.myForecast.text = "晴れ"
                case "Cloud":
                    self.myForecast.textColor = UIColor.grayColor()
                    self.myForecast.text = "曇り"
                case "Rain":
                    self.myForecast.textColor = UIColor.blueColor()
                    self.myForecast.text = "雨"
                default:
                    self.myForecast.textColor = UIColor.blackColor()
                    self.myForecast.text = "もう一度ボタンを押してください"
            }
        })
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        
        // セキュリティ認証のステータスを取得.
        let status = CLLocationManager.authorizationStatus()
        
        if(status == CLAuthorizationStatus.NotDetermined) {
            println("didChangeAuthorizationStatus:\(status)");
            self.myLocationManager.requestAlwaysAuthorization()
        }
        
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        myLocationManager.distanceFilter = 100
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    func jsonPost(callback: (String) -> Void) -> Void  {
//        let urlString = "http://0.0.0.0:3000/getweatherinfo"
        let urlString = "http://lit-shelf-7885.herokuapp.com/getweatherinfo"
        
        var request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if (country == nil) {
            country = "Failed"
            println("country is nill")
            return
        }
        var params: [String: AnyObject] = [
            "country": self.country, "area" : self.area
        ]
        
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: nil)
        
        var task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
        
            if (error == nil) {
                var result = NSString(data: data, encoding: NSUTF8StringEncoding)!
                var json:NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSDictionary

                println(result)
                var test = (json["prediction"] as? String)!
                
                callback(test)

            } else {
                println(error)
            }
        })
        
        task.resume()
    }
   
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        println("didChangeAuthorizationStatus");
        
        // 認証のステータスをログで表示.
        var statusStr = "";
        switch (status) {
        case .NotDetermined:
            statusStr = "NotDetermined"
        case .Restricted:
            statusStr = "Restricted"
        case .Denied:
            statusStr = "Denied"
        case .AuthorizedAlways:
            statusStr = "AuthorizedAlways"
        case .AuthorizedWhenInUse:
            statusStr = "AuthorizedWhenInUse"
        }
        println(" CLAuthorizationStatus: \(statusStr)")
    }

    // 位置情報取得に成功したときに呼び出されるデリゲート.
    func locationManager(manager: CLLocationManager!,didUpdateLocations locations: [AnyObject]!){
        revGeocoding(manager.location.coordinate)
    }
    
    // 位置情報取得に失敗した時に呼び出されるデリゲート.
    func locationManager(manager: CLLocationManager!,didFailWithError error: NSError!){
        print("error")
    }
  
    
    func revGeocoding(coordinate: CLLocationCoordinate2D) {

        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        var geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks:[AnyObject]!, error:NSError!) -> Void in
            if (error == nil && placemarks.count > 0) {
                let placemark = placemarks[0] as! CLPlacemark
                println("Country = \(placemark.country)")
                println("Administrative Area = \(placemark.administrativeArea)")
                self.country = placemark.country
                self.area = placemark.administrativeArea
                if self.country != "unknown" {
                    self.myBtnGetWeather.hidden = false
                    self.myForecastArea.text = placemark.administrativeArea
                }

            } else if (error == nil && placemarks.count == 0) {
                println("No results were returned.")
            } else if (error != nil) {
                println("An error occured = \(error.localizedDescription)")
            }
        })
        
        println(coordinate.latitude)
        println(coordinate.longitude)

        
        return
    }
}