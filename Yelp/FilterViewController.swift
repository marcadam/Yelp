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
    var dealsSwitchState = false
    var categoriesSwitchStates = [Int: Bool]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onSearchButton(sender: UIBarButtonItem) {
        // Deals
        filters["deals"] = dealsSwitchState

        // Categories
        var categories = [String]()
        for (index, state) in categoriesSwitchStates {
            if state {
                categories.append(Filter.categories[index]["code"]!)
            }
        }
        filters["categories"] = categories.count > 0 ? categories : nil

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
            cell.switchToggle.on = dealsSwitchState
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("CheckmarkCell") as! CheckmarkCell
            cell.delegate = self
            cell.checkmarkLabel.text = Filter.distance[indexPath.row]["name"]
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("CheckmarkCell") as! CheckmarkCell
            cell.delegate = self
            cell.checkmarkLabel.text = Filter.sortBy[indexPath.row]["name"]
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell") as! SwitchCell
            cell.delegate = self
            cell.switchLabel.text = Filter.categories[indexPath.row]["name"]
            cell.switchToggle.on = categoriesSwitchStates[indexPath.row] ?? false
            return cell
        }
    }
}

// MARK: - SwitchCellDelegate

extension FilterViewController: SwitchCellDelegate {
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPathForCell(switchCell)!
        switch indexPath.section {
        case 0:
            dealsSwitchState = value
        default:
            categoriesSwitchStates[indexPath.row] = value
        }
    }
}

// MARK: - CheckmarkCellDelegate

extension FilterViewController: CheckmarkCellDelegate {

}
