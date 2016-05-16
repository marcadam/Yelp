//
//  Business.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class Business: NSObject {
    let yelpID: String?
    let name: String?
    let address: String?
    let imageURL: NSURL?
    let categories: String?
    let distance: String?
    let ratingImageURL: NSURL?
    let reviewCount: NSNumber?
    var coordinate = Coordinate()
    var imageLargeURL: NSURL?

    struct Coordinate {
        var latitude: Double?
        var longitude: Double?
    }
    
    init(dictionary: NSDictionary) {
        yelpID = dictionary["id"] as? String
        name = dictionary["name"] as? String
        
        let imageURLString = dictionary["image_url"] as? String
        if imageURLString != nil {
            imageURL = NSURL(string: imageURLString!)!
            imageLargeURL = NSURL(fileURLWithPath: "l.jpg", relativeToURL: imageURL!.URLByDeletingLastPathComponent)
        } else {
            imageURL = nil
            imageLargeURL = nil
        }
        
        let location = dictionary["location"] as? NSDictionary
        var address = ""
        if location != nil {
            let addressArray = location!["address"] as? NSArray
            if addressArray != nil && addressArray!.count > 0 {
                address = addressArray![0] as! String
            }
            
            let neighborhoods = location!["neighborhoods"] as? NSArray
            if neighborhoods != nil && neighborhoods!.count > 0 {
                if !address.isEmpty {
                    address += ", "
                }
                address += neighborhoods![0] as! String
            }

            if let coordinatesDictionary = location!["coordinate"] as? NSDictionary {
                if let latitude = coordinatesDictionary["latitude"] as? Double {
                    coordinate.latitude = latitude
                }
                if let longitude = coordinatesDictionary["longitude"] as? Double {
                    coordinate.longitude = longitude
                }
            }
        }
        self.address = address
        
        let categoriesArray = dictionary["categories"] as? [[String]]
        if categoriesArray != nil {
            var categoryNames = [String]()
            for category in categoriesArray! {
                let categoryName = category[0]
                categoryNames.append(categoryName)
            }
            categories = categoryNames.joinWithSeparator(", ")
        } else {
            categories = nil
        }
        
        if let distanceMeters = dictionary["distance"] as? NSNumber {
            let milesPerMeter = 0.000621371
            distance = String(format: "%.2f mi", milesPerMeter * distanceMeters.doubleValue)
        } else {
            distance = nil
        }
        
        let ratingImageURLString = dictionary["rating_img_url_large"] as? String
        if ratingImageURLString != nil {
            ratingImageURL = NSURL(string: ratingImageURLString!)
        } else {
            ratingImageURL = nil
        }
        
        reviewCount = dictionary["review_count"] as? NSNumber
    }
    
    class func businesses(array array: [NSDictionary]) -> [Business] {
        var businesses = [Business]()
        for dictionary in array {
            let business = Business(dictionary: dictionary)
            businesses.append(business)
        }
        return businesses
    }
    
    class func searchWithTerm(term: String, limit: Int?, offset: Int?, completion: ([Business]!, NSError!) -> Void) {
        YelpClient.sharedInstance.searchWithTerm(term, limit: limit, offset: offset, completion: completion)
    }
    
    class func searchWithTerm(term: String, limit: Int?, offset: Int?, sort: YelpSortMode?, categories: [String]?, distance: Int?, deals: Bool?, completion: ([Business]!, NSError!) -> Void) -> Void {
        YelpClient.sharedInstance.searchWithTerm(term, limit: limit, offset: offset, sort: sort, categories: categories, distance: distance, deals: deals, completion: completion)
    }

    class func getBusiness(yelpID: String, completion: (Business!, NSError!) -> Void) {
        YelpClient.sharedInstance.getBusiness(yelpID, completion: completion)
    }
}
