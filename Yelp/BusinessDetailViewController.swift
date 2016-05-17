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
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var tableView: UITableView!

    var business: Business!

    let alphaViewDefaultAlpha = CGFloat(0.9)
    var scrollViewLastOffsetY = CGFloat(0)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let yelpID = business.yelpID {
            getBusiness(yelpID)
        }

        if let imageLargeURL = business.imageLargeURL {
            imageView.setImageWithURL(imageLargeURL)
        }

        alphaView.alpha = alphaViewDefaultAlpha

        let tableHeaderView = BusinessDetailsView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 215))
        tableHeaderView.business = business
        tableView.tableHeaderView = tableHeaderView
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        alphaView.alpha = alphaViewDefaultAlpha
        (tableView.tableHeaderView as! BusinessDetailsView).topContainerView.alpha = 1
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

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = UIColor.yelpTableHeaderFooterColor()
        return header
    }

    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = UIColor.yelpTableHeaderFooterColor()
        return header
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

extension BusinessDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let scrollOffsetLimitY = CGFloat(-130)
        let scrollOffsetY = scrollView.contentOffset.y

        if scrollOffsetY <= scrollOffsetLimitY {
            let storyboard = UIStoryboard(name: "BusinessPhotos", bundle: nil)
            let businessPhotosNC = storyboard.instantiateViewControllerWithIdentifier("BusinessPhotosNavigationController") as! UINavigationController
            let businessPhotosVC = businessPhotosNC.topViewController as! BusinessPhotosViewController
            businessPhotosVC.imageLargeURL = business.imageLargeURL

            presentViewController(businessPhotosNC, animated: false, completion: nil)
        } else if scrollOffsetY < 0 {
            let alpha = alphaViewDefaultAlpha + (scrollOffsetY / 70)
            alphaView.alpha = alpha
            (tableView.tableHeaderView as! BusinessDetailsView).topContainerView.alpha = alpha

            imageViewTopConstraint.constant -= ((scrollOffsetY - scrollViewLastOffsetY) / 3)
            scrollViewLastOffsetY = scrollOffsetY
        }
    }
}
