//
//  BusinessDetailViewController.swift
//  Yelp
//
//  Created by Marc Adam Anderson on 4/25/16.
//  Copyright © 2016 Marc Adam Anderson. All rights reserved.
//

import UIKit

class BusinessDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var alphaView: UIView!

    @IBOutlet weak var tableView: UITableView!

    var business: Business!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let yelpID = business.yelpID {
            getBusiness(yelpID)
        }

        print("Large Image URL: \(business.imageLargeURL?.absoluteString)")
        if let imageLargeURL = business.imageLargeURL {
            imageView.setImageWithURL(imageLargeURL)
        }

        let tableHeaderView = BusinessDetailsView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 215))
        tableHeaderView.business = business
        tableView.tableHeaderView = tableHeaderView
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sizeHeaderToFit()
    }

    func sizeHeaderToFit() {
        let headerView = tableView.tableHeaderView!

        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()

        let height = headerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame

        tableView.tableHeaderView = headerView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func getBusiness(yelpID: String) {
        Business.getBusiness(business.yelpID!) { (business: Business!, error: NSError!) -> Void in
//            print("Business: \(business)")
        }
    }
}

extension BusinessDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 7
    }

    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseID = "SubtitleCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(reuseID)
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: reuseID)
        }

        cell?.textLabel?.text = "Some label"
        cell?.detailTextLabel?.text = "Details and details"
        cell?.accessoryType = .DisclosureIndicator
        return cell!
    }
}