//
//  FilterViewController.swift
//  Yelp
//
//  Created by Marc Anderson on 2/10/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FilterViewControllerDelegate {
    optional func filterViewController(filterViewController: FilterViewController, diUpdateFilters filters: [String: AnyObject])
}

class FilterViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    weak var delegate: FilterViewControllerDelegate?
    var filters = [String: AnyObject]()
    var offeringDealChoice = false
    var distanceChoice = Filter.distance[0]["code"]
    var distanceRowStates = [Bool](count: Filter.distance.count, repeatedValue: false)
    var sortByChoice = Filter.sortBy[0]["code"] as? Int
    var sortByRowStates = [Bool](count: Filter.sortBy.count, repeatedValue: false)
    var categoriesSwitchStates = [Int: Bool]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        distanceRowStates[0] = true
        sortByRowStates[0] = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onSearchButton(sender: UIBarButtonItem) {
        // Deals
        filters["deals"] = offeringDealChoice

        // Distance
        filters["distance"] = distanceChoice

        // Sort By
        filters["sortBy"] = sortByChoice

        // Categories
        var selectedCategories = [String]()
        for (row, isSelected) in categoriesSwitchStates {
            if isSelected {
                selectedCategories.append(Filter.categories[row]["code"]!)
            }
        }
        filters["categories"] = selectedCategories.count > 0 ? selectedCategories : nil

        delegate?.filterViewController?(self, diUpdateFilters: filters)
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onCancelButton(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - UITableViewDataSource/UITableViewDelegate

extension FilterViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Filter.sections.count
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Filter.sections[section]
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return Filter.distance.count
        case 2:
            return Filter.sortBy.count
        case 3:
            return Filter.categories.count
        default:
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell") as! SwitchCell
            cell.delegate = self
            cell.switchLabel.text = "Offering a Deal"
            cell.switchToggle.on = offeringDealChoice
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("CheckmarkCell") as! CheckmarkCell
            cell.checkmarkLabel.text = Filter.distance[indexPath.row]["name"]
            cell.checked = distanceRowStates[indexPath.row] ? true : false
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("CheckmarkCell") as! CheckmarkCell
            cell.checkmarkLabel.text = Filter.sortBy[indexPath.row]["name"] as? String
            cell.checked = sortByRowStates[indexPath.row] ? true : false
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell") as! SwitchCell
            cell.delegate = self
            cell.switchLabel.text = Filter.categories[indexPath.row]["name"]
            cell.switchToggle.on = categoriesSwitchStates[indexPath.row] ?? false
            return cell
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! CheckmarkCell
            cell.checked = true
            for row in 0..<Filter.distance.count {
                distanceRowStates[row] = false
            }
            distanceRowStates[indexPath.row] = true
            distanceChoice = Filter.distance[indexPath.row]["code"]
            tableView.reloadData()
        }

        if indexPath.section == 2 {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! CheckmarkCell
            cell.checked = true
            for row in 0..<Filter.sortBy.count {
                sortByRowStates[row] = false
            }
            sortByRowStates[indexPath.row] = true
            sortByChoice = Filter.sortBy[indexPath.row]["code"] as? Int
            tableView.reloadData()

        }
    }
}

// MARK: - SwitchCellDelegate

extension FilterViewController: SwitchCellDelegate {
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPathForCell(switchCell)!
        switch indexPath.section {
        case 0:
            offeringDealChoice = value
        default:
            categoriesSwitchStates[indexPath.row] = value
        }
    }
}
