//
//  ViewController.swift
//  WeatherChart
//
//  Created by Sho Tanaka on 7/12/15.
//  Copyright (c) 2015 Sho Tanaka. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController , CLLocationManagerDelegate, NSURLSessionDelegate, NSURLSessionDataDelegate{
        
    
    var myLocationManager:CLLocationManager!
    
    var myLatitudeLabel:UILabel!
    var myLongitudeLabel:UILabel!
    
    var country: String!
    var area: String!
//    var prediction: String! = "unknown"

    @IBOutlet weak var myForecast: UILabel!
    
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
    
    @IBAction func getForecastData(sender: AnyObject) {
        var todayCondition:NSString = "tets"
        var prediction:NSString = "unknown"

        myLocationManager.startUpdatingLocation()

        getData()
       
        jsonPost( {prediction in

            println(" in JsonPOST")
            println("self.prediction = \(prediction)")
            todayCondition = prediction as! NSString //["prediction"]

           
            if todayCondition == "Clear" as! NSString {
                self.myForecast.textColor = UIColor.redColor()
                self.myForecast.text = "晴れ"
            } else if todayCondition == "Cloud" {
                self.myForecast.textColor = UIColor.grayColor()
                self.myForecast.text = "曇り"
            } else if todayCondition == "Rain" {
                self.myForecast.textColor = UIColor.blueColor()
                self.myForecast.text = "雨"
            }
            println("text = \(self.myForecast.text)")
            println(" be out JsonPOST")

        })

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ボタンの生成.
//        let myButton = UIButton(frame: CGRect(x: 0, y: -10, width: 100, height: 100))
//        myButton.backgroundColor = UIColor.orangeColor()
//        myButton.layer.masksToBounds = true
//        myButton.setTitle("Get", forState: .Normal)
//        myButton.layer.cornerRadius = 50.0
//        myButton.layer.position = CGPoint(x: self.view.bounds.width/2, y:self.view.bounds.height/2)
//        myButton.addTarget(self, action: "onClickMyButton:", forControlEvents: .TouchUpInside)
        
        myLatitudeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 30))
        myLatitudeLabel.layer.position = CGPoint(x: self.view.bounds.width/2, y:self.view.bounds.height/2+100)
        
        myLongitudeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 30))
        myLongitudeLabel.layer.position = CGPoint(x: self.view.bounds.width/2, y:self.view.bounds.height/2+130)
        
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
        
//        self.view.addSubview(myButton)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func jsonPost(callback: (String) -> Void) -> Void  {
//    func jsonPost(success:() -> Void) {
        let urlString = "http://0.0.0.0:3000/getweatherinfo"
        //        let urlString = "http://lit-shelf-7885.herokuapp.com/getweatherinfo"
        
        var request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if (country == nil) {
            country = "Failed"
            println("country is nill")
            return
        }
        var params: [String: AnyObject] = [
            "country": country, "area" : area
        ]
        
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: nil)
        
        var task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
        
            if (error == nil) {
                var result = NSString(data: data, encoding: NSUTF8StringEncoding)!
                var json:NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSDictionary

                println(result)
//                var test: NSString = result.objectForKey("prediction") as NSString
                var test = json["prediction"] as? String
                
                println("test is \(test)")
//                var json:NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSDictionary
//                var json:Array = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadeingOptions.AllowFragments, error: nil) as! Array
                
                println(result)
//                let test:NSString = json["prediction"]
//                var prediction = json["prediction"] as String
//                callback(prediction)
//                self.prediction = json["prediction"] as! String
//                self.prediction = json["prediction"] as! String //?.description
//                callback("\(json[prediction])")
                callback(test!)

            } else {
                println(error)
            }
           
        })
        
        task.resume()
//        close()
//        let party: [String: String] = ["ルフィ": "船長", "ゾロ": "剣士", "ナミ":"航海士"]
//        return party
//        return json["prediction"]
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

    
    // ボタンイベントのセット.
    func onClickMyButton(sender: UIButton){
    }
    
    // 位置情報取得に成功したときに呼び出されるデリゲート.
    func locationManager(manager: CLLocationManager!,didUpdateLocations locations: [AnyObject]!){
        
        // 緯度・経度の表示.
        myLatitudeLabel.text = "緯度：\(manager.location.coordinate.latitude)"
        myLatitudeLabel.textAlignment = NSTextAlignment.Center
        
        myLongitudeLabel.text = "経度：\(manager.location.coordinate.longitude)"
        myLongitudeLabel.textAlignment = NSTextAlignment.Center
        
        
        self.view.addSubview(myLatitudeLabel)
        self.view.addSubview(myLongitudeLabel)

        revGeocoding(manager.location.coordinate)
    }
    
    // 位置情報取得に失敗した時に呼び出されるデリゲート.
    func locationManager(manager: CLLocationManager!,didFailWithError error: NSError!){
        print("error")
    }
    
    func getData() {
        let getPrfURL = NSURL(string: "http://express.heartrails.com/api/json?method=getPrefectures")
        let req = NSURLRequest(URL: getPrfURL!)
        let connection: NSURLConnection = NSURLConnection(request: req, delegate: self, startImmediately: false)!
        
        // NSURLConnectionを使ってAPIを取得する
        NSURLConnection.sendAsynchronousRequest(req,
            queue: NSOperationQueue.mainQueue(),
            completionHandler: response)
    }
    
    // 取得したAPIデータの処理
    func response(res: NSURLResponse!, data: NSData!, error: NSError!){
        
        let json:NSDictionary = NSJSONSerialization.JSONObjectWithData(data,
            options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSDictionary
        
        let res:NSDictionary = json.objectForKey("response") as! NSDictionary
        let pref:NSArray = res.objectForKey("prefecture") as! NSArray
        
        /*        for var i=0 ; i<pref.count ; i++ {
        println(pref[i])
        } */
    }
    
    
    
    func revGeocoding(coordinate: CLLocationCoordinate2D)
    {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        var geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks:[AnyObject]!, error:NSError!) -> Void in
            if (error == nil && placemarks.count > 0) {
                let placemark = placemarks[0] as! CLPlacemark
                println("Country = \(placemark.country)")
                println("Administrative Area = \(placemark.administrativeArea)")
                self.country = placemark.country
                self.area = placemark.administrativeArea
            } else if (error == nil && placemarks.count == 0) {
                println("No results were returned.")
            } else if (error != nil) {
                println("An error occured = \(error.localizedDescription)")
            }
        })
        
        println(coordinate.latitude)
        println(coordinate.longitude)
        //        println(country)
        
        //        jsonPost
        
    }
    

}

