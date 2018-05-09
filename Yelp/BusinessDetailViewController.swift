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

        if let imageLargeURL = business.imageLargeURL {
            imageView.setImageWith(imageLargeURL)
        }

        alphaView.alpha = alphaViewDefaultAlpha

        let tableHeaderView = BusinessDetailsView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 215))
        tableHeaderView.business = business
        tableView.tableHeaderView = tableHeaderView

        let tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 8))
        tableFooterView.backgroundColor = UIColor.yelpTableHeaderFooter()
        tableView.tableFooterView = tableFooterView
    }

    override func viewWillAppear(_ animated: Bool) {
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

        let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame

        tableView.tableHeaderView = headerView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension BusinessDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return 5
        } else {
            return 2
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 7
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = UIColor.yelpTableHeaderFooter()
        return header
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = UIColor.yelpTableHeaderFooter()
        return header
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 0 {
            // MapCell height
            return 110
        } else {
            // All other cells use standard height
            return 44
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MapCell") as! MapTableViewCell
            cell.business = business
            cell.preservesSuperviewLayoutMargins = false
            cell.layoutMargins = UIEdgeInsets.zero
            cell.separatorInset = UIEdgeInsets.zero

            return cell
        } else {
            let reuseID = "SubtitleCell"
            var cell = tableView.dequeueReusableCell(withIdentifier: reuseID)
            if cell == nil {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseID)
            }

            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    cell?.imageView?.image = UIImage(named: "Truck")
                    cell?.textLabel?.text = "Order Pickup"
                    cell?.textLabel?.textColor = UIColor.yelpBlue()
                } else if indexPath.row == 1 {
                    cell?.imageView?.image = UIImage(named: "Blowhorn")
                    cell?.textLabel?.text = "Call Now"
                    cell?.textLabel?.textColor = UIColor.yelpOrange()
                    cell?.detailTextLabel?.text = "Let us cater your next event!"
                }
                cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            } else if indexPath.section == 1 && indexPath.row == 1 {
                if let address = business.displayAddress.address, let cityStatePostal = business.displayAddress.cityStatePostal {
                    cell?.textLabel?.text = "\(address), \(cityStatePostal)"
                }
                cell?.detailTextLabel?.text = business.displayAddress.crossStreets
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell?.preservesSuperviewLayoutMargins = false
                cell?.layoutMargins = UIEdgeInsets.zero
                cell?.separatorInset = UIEdgeInsets.zero
            } else if indexPath.section == 2 {
                if indexPath.row == 0 {
                    cell?.imageView?.image = UIImage(named: "TurnSign")
                    cell?.textLabel?.text = "Directions"
                    cell?.detailTextLabel?.text = "3 min drive"
                } else if indexPath.row == 1 {
                    cell?.imageView?.image = UIImage(named: "Phone")
                    cell?.textLabel?.text = "Call"
                    cell?.detailTextLabel?.text = business.phoneNumber
                } else if indexPath.row == 2 {
                    cell?.imageView?.image = UIImage(named: "MessageBalloon")
                    cell?.textLabel?.text = "Message the Business"
                } else if indexPath.row == 3 {
                    cell?.imageView?.image = UIImage(named: "Utensils")
                    cell?.textLabel?.text = "Explore the Menu"
                } else if indexPath.row == 4 {
                    cell?.imageView?.image = UIImage(named: "Ellipses")
                    cell?.textLabel?.text = "More Info"
                    cell?.detailTextLabel?.text = "Hours, Website, Attire, Noise Level, Ambience"
                }
                cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            }

            cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 11)
            cell?.detailTextLabel?.textColor = UIColor.darkGray
            cell?.accessoryType = .disclosureIndicator

            return cell!
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UIScrollViewDelegate

extension BusinessDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollOffsetLimitY = CGFloat(-130)
        let scrollOffsetY = scrollView.contentOffset.y

        if scrollOffsetY > 0 {
            imageViewTopConstraint.constant -= (scrollOffsetY - scrollViewLastOffsetY)
            scrollViewLastOffsetY = scrollOffsetY
        } else if scrollOffsetY <= scrollOffsetLimitY {
            let storyboard = UIStoryboard(name: "BusinessPhotos", bundle: nil)
            let businessPhotosNC = storyboard.instantiateViewController(withIdentifier: "BusinessPhotosNavigationController") as! UINavigationController
            let businessPhotosVC = businessPhotosNC.topViewController as! BusinessPhotosViewController
            businessPhotosVC.imageLargeURL = business.imageLargeURL

            present(businessPhotosNC, animated: false, completion: nil)
        } else if scrollOffsetY < 0 {
            let alpha = alphaViewDefaultAlpha + (scrollOffsetY / 70)
            alphaView.alpha = alpha
            (tableView.tableHeaderView as! BusinessDetailsView).topContainerView.alpha = alpha

            imageViewTopConstraint.constant -= ((scrollOffsetY - scrollViewLastOffsetY) / 3)
            scrollViewLastOffsetY = scrollOffsetY
        }
    }
}
