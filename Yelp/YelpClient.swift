//
//  YelpClient.swift
//  Yelp
//
//  Created by Timothy Lee on 9/19/14.
//  Copyright (c) 2014 Timothy Lee. All rights reserved.
//

import UIKit

import AFNetworking
import BDBOAuth1Manager

// You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
let yelpConsumerKey = "vxKwwcR_NMQ7WaEiQBK_CA"
let yelpConsumerSecret = "33QCvh5bIF5jIHR5klQr7RtBDhQ"
let yelpToken = "uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV"
let yelpTokenSecret = "mqtKIxMIR4iBtBPZCmCLEb-Dz3Y"

enum YelpSortMode: Int {
    case bestMatched = 0, distance, highestRated
}

class YelpClient: BDBOAuth1RequestOperationManager {
    var accessToken: String!
    var accessSecret: String!
    
    static let sharedInstance = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private init(consumerKey key: String!, consumerSecret secret: String!, accessToken: String!, accessSecret: String!) {
        self.accessToken = accessToken
        self.accessSecret = accessSecret
        let baseUrl = URL(string: "https://api.yelp.com/v2/")
        super.init(baseURL: baseUrl, consumerKey: key, consumerSecret: secret);
        
        let token = BDBOAuth1Credential(token: accessToken, secret: accessSecret, expiration: nil)
        self.requestSerializer.saveAccessToken(token)
    }
    
    @discardableResult func searchWithTerm(_ term: String, limit: Int?, offset: Int?, completion: @escaping ([Business]?, NSError?) -> Void) -> AFHTTPRequestOperation {
        return searchWithTerm(term, limit: limit, offset: offset, sort: nil, categories: nil, distance: nil, deals: nil, completion: completion)
    }
    
    @discardableResult func searchWithTerm(_ term: String, limit: Int?, offset: Int?, sort: YelpSortMode?, categories: [String]?, distance: Int?, deals: Bool?, completion: @escaping ([Business]?, NSError?) -> Void) -> AFHTTPRequestOperation {
        // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api

        // Default the location to San Francisco
        // TODO: check all these casts to AnyObject
        var parameters: [String : AnyObject] = ["term": term as AnyObject, "ll": "\(Constants.DefaultLocation.latitude),\(Constants.DefaultLocation.longitude)" as AnyObject]

        if limit != nil && offset != nil {
            parameters["limit"] = limit as AnyObject
            parameters["offset"] = offset as AnyObject
        }

        if sort != nil {
            parameters["sort"] = sort!.rawValue as AnyObject
        }
        
        if categories != nil && categories!.count > 0 {
            parameters["category_filter"] = (categories!).joined(separator: ",") as AnyObject
        }

        if distance != nil && distance != 0 {
            parameters["radius_filter"] = distance! as AnyObject
        }

        if deals != nil {
            parameters["deals_filter"] = deals! as AnyObject
        }
        
        return self.get(
            "search",
            parameters: parameters,
            success: { (operation: AFHTTPRequestOperation!, response: Any!) -> Void in
                // TODO: check this
                guard let response = response as? NSDictionary else { fatalError() }
                if let dictionaries = response["businesses"] as? [NSDictionary] {
                    completion(Business.businesses(array: dictionaries), nil)
                }
            },
            failure: { (operation: AFHTTPRequestOperation?, error: Error!) -> Void in
                completion(nil, error as NSError)
            }
        )!
    }

    func getBusiness(_ yelpID: String, completion: @escaping (Business?, NSError?) -> Void) -> AFHTTPRequestOperation {
        let encodedYelpID = yelpID.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
        let endpointName = "business/" + encodedYelpID

        return self.get(
            endpointName,
            parameters: nil,
            success: { (operation: AFHTTPRequestOperation!, response: Any!) -> Void in
                // print(response)
                if let dictionary = response as? NSDictionary {
                    completion(Business(dictionary: dictionary), nil)
                }
            },
            failure: { (operation: AFHTTPRequestOperation?, error: Error!) -> Void in
                completion(nil, error as NSError)
            }
        )!
    }
}
