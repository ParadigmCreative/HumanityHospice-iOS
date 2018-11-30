//
//  AboutViewController.swift
//  HumanityHospice
//
//  Created by App Center on 4/30/18.
//  Copyright © 2018 Oklahoma State University. All rights reserved.
//

import UIKit
import WebKit

class AboutViewController: UIViewController, WKNavigationDelegate {

    
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: "http://www.humanityhospice.com")!
        webView.allowsBackForwardNavigationGestures = true
        let urlR = URLRequest(url: url)
        webView.load(urlR)
        Log.i("ABOUT PAGE")
        Utilities.showActivityIndicator(view: self.view)
        webView.navigationDelegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let url = URL(string: "http://www.humanityhospice.com")!
        webView.allowsBackForwardNavigationGestures = true
        let urlR = URLRequest(url: url)
        webView.load(urlR)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Utilities.closeActivityIndicator()
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func openMenu(_ sender: Any) {
        MenuHandler.openMenu(vc: self)
    }
    
}
