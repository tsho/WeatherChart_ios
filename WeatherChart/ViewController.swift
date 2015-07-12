//
//  ViewController.swift
//  WeatherChart
//
//  Created by Sho Tanaka on 7/12/15.
//  Copyright (c) 2015 Sho Tanaka. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

   
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

