//
//  BusinessDetailViewController.swift
//  Yelp
//
//  Created by Marc Adam Anderson on 4/25/16.
//  Copyright © 2016 Marc Adam Anderson. All rights reserved.
//

import UIKit

class BusinessDetailViewController: UIViewController {

    var business: Business!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let yelpID = business.yelpID {
            getBusiness(yelpID)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func getBusiness(yelpID: String) {
        Business.getBusiness(business.yelpID!) { (business: Business!, error: NSError!) -> Void in
            print("Business: \(business)")
        }
    }
}
