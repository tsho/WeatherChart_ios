//
//  ViewController.swift
//  WeatherChart
//
//  Created by Sho Tanaka on 7/12/15.
//  Copyright (c) 2015 Sho Tanaka. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    func jsonPost() {
        //            let urlString = "http://0.0.0.0:3000/getweatherinfo"
        let urlString = "http://lit-shelf-7885.herokuapp.com/getweatherinfo"
        
        var request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        
        // set the method(HTTP-POST)
        request.HTTPMethod = "POST"
        // set the header(s)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // set the request-body(JSON)
        /*            var params: [String: AnyObject] = [
        "foo": "bar",
        "baz": [
        "a": 1,
        "b": 20,
        "c": 300
        ]
        ] */
        /*            var params: [String: AnyObject] = [
        "company" : [
        "area" : "Tokyo",
        "password" : "lmn"
        ]
        ] */
        var params: [String: AnyObject] = [
            "area" : "Tokyo"
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
    

   
    @IBOutlet weak var myForecast: UILabel!
    
    @IBAction func getForecastData(sender: AnyObject) {

        
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
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    
    
    func pushJson(jsonStr: String) {

        
    }

}

