//
//  ViewControllerChart.swift
//  WeatherChart
//
//  Created by Sho Tanaka on 7/13/15.
//  Copyright (c) 2015 Sho Tanaka. All rights reserved.
//

import UIKit

class ChartViewController: UIViewController, UIWebViewDelegate {

    var myWebView: UIWebView!
    var myPDFurl: NSURL!
    var myRequest: NSURLRequest!
    var myIndiator: UIActivityIndicatorView!
    
    /// 遷移時の受け取り用の変数
    var _type:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.hidesBarsOnSwipe = true
        self.navigationController?.hidesBarsOnTap = true
        
        // ラベルに受け取った遷移用の変数を渡す
        var type = _type
        println("type = " + type)
        var url: String
        
        switch type {
            case "surf":
                url = "http://www.hbc.jp/tecweather/SPAS.pdf"
            case "500hpa":
                url = "http://www.hbc.jp/tecweather/AUPQ35.pdf"
            case "ensemble":
                url = "http://www.hbc.jp/tecweather/FZCX50.pdf"
            default:
                url = "https://developer.apple.com/jp/documentation/CocoaEncyclopedia.pdf"
        }
        
       
        myPDFurl = NSURL(string: url)
        loadVierPDF(myPDFurl)

    }
    
    /*
    インジケータのアニメーション開始.
    */
    func startAnimation() {
        
        // NetworkActivityIndicatorを表示.
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        // UIACtivityIndicatorを表示.
        if !myIndiator.isAnimating() {
            myIndiator.startAnimating()
        }
        
        // viewにインジケータを追加.
        self.view.addSubview(myIndiator)
    }
    
    func stopAnimation() {
        // NetworkActivityIndicatorを非表示.
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        // UIACtivityIndicatorを非表示.
        if myIndiator.isAnimating() {
            myIndiator.stopAnimating()
        }
    }
    
    
    /*
    WebViewのloadが開始された時に呼ばれるメソッド.
    */
    func webViewDidStartLoad(webView: UIWebView) {
        println("load started")
        
        startAnimation()
    }
    
    /*
    WebViewのloadが終了した時に呼ばれるメソッド.
    */
    func webViewDidFinishLoad(webView: UIWebView) {
        println("load finished")
        
        stopAnimation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadVierPDF(myPDFurl: NSURL) {
        myRequest = NSURLRequest(URL: myPDFurl)

        // PDFを開くためのWebViewを生成.
        myWebView = UIWebView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
        myWebView.delegate = self
        myWebView.scalesPageToFit = true
        myWebView.layer.position = CGPointMake(self.view.frame.width/2, self.view.frame.height/2)
        
        // URLReqestを生成.
        
        // ページ読み込み中に表示させるインジケータを生成.
        myIndiator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        myIndiator.center = self.view.center
        myIndiator.hidesWhenStopped = true
        myIndiator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        
        // WebViewのLoad開始.
        myWebView.loadRequest(myRequest)
        
        // viewにWebViewを追加.
        self.view.addSubview(myWebView)
    }

}
