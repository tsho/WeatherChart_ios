//
//  ViewController.swift
//  WeatherChart
//
//  Created by Sho Tanaka on 7/12/15.
//  Copyright (c) 2015 Sho Tanaka. All rights reserved.
//

import UIKit
import CoreLocation

//class ViewController: UIViewController {
class ViewController: UIViewController , CLLocationManagerDelegate{
        
    
    var myLocationManager:CLLocationManager!
    
    // 緯度表示用のラベル.
    var myLatitudeLabel:UILabel!
    
    // 経度表示用のラベル.
    var myLongitudeLabel:UILabel!
    

    var country:String!
    var area:String!

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
    

/*    func getPosition () {
        var myLocationManager:CLLocationManager!

        // 現在地の取得.
        myLocationManager = CLLocationManager()
        
//        myLocationManager.delegate = self
    
        // セキュリティ認証のステータスを取得.
        let status = CLLocationManager.authorizationStatus()
    
        // まだ認証が得られていない場合は、認証ダイアログを表示.
        if(status == CLAuthorizationStatus.NotDetermined) {
        println("didChangeAuthorizationStatus:\(status)");
        // まだ承認が得られていない場合は、認証ダイアログを表示.
        self.myLocationManager.requestAlwaysAuthorization()
        }
        
        // 取得精度の設定.
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 取得頻度の設定.
        myLocationManager.distanceFilter = 100
        
//s        self.view.addSubview(myButton)
    
    } */

    @IBOutlet weak var myForecast: UILabel!
    
    @IBAction func getForecastData(sender: AnyObject) {

       
        getData()
//        println(coordinate.latitude)
//        revGeocoding()
//        getPaosition()
        
        // 緯度表示用のラベル.
        var myLatitudeLabel:UILabel!
        
        // 経度表示用のラベル.
        var myLongitudeLabel:UILabel!
        
        
        let conditions = [
            "晴れ",
            "曇り",
            "雨"
        ]
        
        let todayCondition = conditions[2]
        
        if todayCondition == "晴れ" {
            self.myForecast.textColor = UIColor.redColor()
        } else if todayCondition == "曇り" {
            self.myForecast.textColor = UIColor.grayColor()
        } else if todayCondition == "雨" {
            self.myForecast.textColor = UIColor.blueColor()
        }

        
        self.myForecast.text = todayCondition
        
        jsonPost()

    }
    
    func jsonPost() {
        let urlString = "http://0.0.0.0:3000/getweatherinfo"
//        let urlString = "http://lit-shelf-7885.herokuapp.com/getweatherinfo"
        
        var request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        
        // set the method(HTTP-POST)
        request.HTTPMethod = "POST"
        // set the header(s)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var params: [String: AnyObject] = [
            "country": country, "area" : area
        ]
        
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: nil)
        
        // use NSURLSessionDataTask
        var task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {data, response, error in
            if (error == nil) {
                var result = NSString(data: data, encoding: NSUTF8StringEncoding)!
                println(result)
            } else {
                println(error)
            }
        })
        task.resume()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ボタンの生成.
        let myButton = UIButton(frame: CGRect(x: 0, y: -10, width: 100, height: 100))
        myButton.backgroundColor = UIColor.orangeColor()
        myButton.layer.masksToBounds = true
        myButton.setTitle("Get", forState: .Normal)
        myButton.layer.cornerRadius = 50.0
        myButton.layer.position = CGPoint(x: self.view.bounds.width/2, y:self.view.bounds.height/2)
        myButton.addTarget(self, action: "onClickMyButton:", forControlEvents: .TouchUpInside)
        
        // 緯度表示用のラベルを生成.
        myLatitudeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 30))
        myLatitudeLabel.layer.position = CGPoint(x: self.view.bounds.width/2, y:self.view.bounds.height/2+100)
        
        // 軽度表示用のラベルを生成.
        myLongitudeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 30))
        myLongitudeLabel.layer.position = CGPoint(x: self.view.bounds.width/2, y:self.view.bounds.height/2+130)
        
        
        // 現在地の取得.
        myLocationManager = CLLocationManager()
        
        myLocationManager.delegate = self
        
        // セキュリティ認証のステータスを取得.
        let status = CLLocationManager.authorizationStatus()
        
        // まだ認証が得られていない場合は、認証ダイアログを表示.
        if(status == CLAuthorizationStatus.NotDetermined) {
            println("didChangeAuthorizationStatus:\(status)");
            // まだ承認が得られていない場合は、認証ダイアログを表示.
            self.myLocationManager.requestAlwaysAuthorization()
        }
        
        // 取得精度の設定.
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 取得頻度の設定.
        myLocationManager.distanceFilter = 100
        
        self.view.addSubview(myButton)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        // 現在位置の取得を開始.
        myLocationManager.startUpdatingLocation()
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
    

}

