//
//  Theme.swift
//  Yelp
//
//  Created by Marc Adam Anderson on 5/12/16.
//  Copyright © 2016 Marc Adam Anderson. All rights reserved.
//

import Foundation
import UIKit

public func applyTheme() {
    UINavigationBar.appearance().translucent = false
    UINavigationBar.appearance().barTintColor = UIColor.yelpRed()
    UINavigationBar.appearance().tintColor = UIColor.whiteColor()
}

extension UIColor {
    class func yelpRed() -> UIColor {
        return UIColor(red: 209.0/255.0, green: 18.0/255.0, blue: 36.0/255.0, alpha: 1.0)
    }
}
