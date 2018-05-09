//
//  FilterViewController.swift
//  Yelp
//
//  Created by Marc Adam Anderson on 2/10/16.
//  Copyright © 2016 Marc Adam Anderson. All rights reserved.
//

import UIKit

@objc protocol FilterViewControllerDelegate {
    @objc optional func filterViewController(_ filterViewController: FilterViewController, didUpdateFilters filters: [String: AnyObject])
}

class FilterViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    weak var delegate: FilterViewControllerDelegate?

    enum SectionDisplayMode {
        case expanded, collapsed
    }

    var filters = [String: AnyObject]()

    var offeringDealChoice = false

    var distanceDisplayMode = SectionDisplayMode.collapsed
    var distanceChoice = Filter.distance[0]
    var distanceRowData = [Filter.distance[0]]
    var distanceRowStates = [Bool](repeating: false, count: Filter.distance.count)

    var sortByDisplayMode = SectionDisplayMode.collapsed
    var sortByChoice = Filter.sortBy[0]
    var sortByRowData = [Filter.sortBy[0]]
    var sortByRowStates = [Bool](repeating: false, count: Filter.sortBy.count)

    var categoriesDisplayMode = SectionDisplayMode.collapsed
    var categoriesRowData = [Filter.categories[0], Filter.categories[1], Filter.categories[2], ["name": "Show All", "code": "show_all"]]
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

    @IBAction func onSearchButton(_ sender: UIBarButtonItem) {
        // Deals
        filters["deals"] = offeringDealChoice as AnyObject

        // Distance
        filters["distance"] = distanceChoice["code"] as? Int as AnyObject

        // Sort By
        filters["sortBy"] = sortByChoice["code"] as? Int as AnyObject

        // Categories
        var selectedCategories = [String]()
        for (row, isSelected) in categoriesSwitchStates {
            if isSelected {
                selectedCategories.append(Filter.categories[row]["code"]!)
            }
        }
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories as AnyObject
        }

        delegate?.filterViewController?(self, didUpdateFilters: filters)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func onCancelButton(_ sender: UIBarButtonItem) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource/UITableViewDelegate

extension FilterViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Filter.sections.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Filter.sections[section]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return distanceRowData.count
        case 2:
            return sortByRowData.count
        case 3:
            return categoriesRowData.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell") as! SwitchCell
            cell.delegate = self
            cell.switchLabel.text = "Offering a Deal"
            cell.switchToggle.isOn = offeringDealChoice
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CheckmarkCell") as! CheckmarkCell
            cell.checkmarkLabel.text = distanceRowData[indexPath.row]["name"] as? String

            if distanceDisplayMode == .collapsed {
                cell.state = .collapsed
            } else {
                cell.state = distanceRowStates[indexPath.row] ? .checked : .unchecked
            }
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CheckmarkCell") as! CheckmarkCell
            cell.checkmarkLabel.text = sortByRowData[indexPath.row]["name"] as? String
            if sortByDisplayMode == .collapsed {
                cell.state = .collapsed
            } else {
                cell.state = sortByRowStates[indexPath.row] ? .checked : .unchecked
            }
            return cell
        } else {
            if categoriesDisplayMode == .collapsed && indexPath.row == categoriesRowData.count - 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ShowAllCell") as! ShowAllCell
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell") as! SwitchCell
                cell.delegate = self
                cell.switchLabel.text = Filter.categories[indexPath.row]["name"]
                cell.switchToggle.isOn = categoriesSwitchStates[indexPath.row] ?? false
                return cell
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if distanceDisplayMode == .collapsed {
                distanceDisplayMode = .expanded

                distanceRowData = Filter.distance
                var indexPaths = [IndexPath]()
                for row in 0..<distanceRowData.count {
                    indexPaths.append(IndexPath(row: row, section: indexPath.section))
                }

                tableView.beginUpdates()
                tableView.deleteRows(at: [IndexPath(row: 0, section: indexPath.section)], with: .fade)
                tableView.insertRows(at: indexPaths, with: .fade)
                tableView.endUpdates()
            } else {
                distanceDisplayMode = .collapsed

                let cell = tableView.cellForRow(at: indexPath) as! CheckmarkCell
                cell.state = .checked

                var indexPaths = [IndexPath]()
                for row in 0..<distanceRowData.count {
                    distanceRowStates[row] = false
                    indexPaths.append(IndexPath(row: row, section: indexPath.section))
                }

                distanceRowStates[indexPath.row] = true
                distanceChoice = distanceRowData[indexPath.row]
                distanceRowData = [distanceChoice]

                tableView.beginUpdates()
                tableView.deleteRows(at: indexPaths, with: .fade)
                tableView.insertRows(at: [IndexPath(row: 0, section: indexPath.section)], with: .fade)
                tableView.endUpdates()
            }
        }

        if indexPath.section == 2 {
            if sortByDisplayMode == .collapsed {
                sortByDisplayMode = .expanded

                sortByRowData = Filter.sortBy
                var indexPaths = [IndexPath]()
                for row in 0..<sortByRowData.count {
                    indexPaths.append(IndexPath(row: row, section: indexPath.section))
                }

                tableView.beginUpdates()
                tableView.deleteRows(at: [IndexPath(row: 0, section: indexPath.section)], with: .fade)
                tableView.insertRows(at: indexPaths, with: .fade)
                tableView.endUpdates()
            } else {
                sortByDisplayMode = .collapsed

                let cell = tableView.cellForRow(at: indexPath) as! CheckmarkCell
                cell.state = .checked

                var indexPaths = [IndexPath]()
                for row in 0..<sortByRowData.count {
                    sortByRowStates[row] = false
                    indexPaths.append(IndexPath(row: row, section: indexPath.section))
                }

                sortByRowStates[indexPath.row] = true
                sortByChoice = sortByRowData[indexPath.row]
                sortByRowData = [sortByChoice]

                tableView.beginUpdates()
                tableView.deleteRows(at: indexPaths, with: .fade)
                tableView.insertRows(at: [IndexPath(row: 0, section: indexPath.section)], with: .fade)
                tableView.endUpdates()
            }
        }

        if indexPath.section == 3 && categoriesDisplayMode == .collapsed && indexPath.row == categoriesRowData.count - 1 {
            categoriesDisplayMode = .expanded

            let startRow = categoriesRowData.count - 1
            categoriesRowData = Filter.categories

            var indexPaths = [IndexPath]()
            for row in startRow..<categoriesRowData.count {
                indexPaths.append(IndexPath(row: row, section: indexPath.section))
            }

            tableView.beginUpdates()
            tableView.deleteRows(at: [IndexPath(row: startRow, section: indexPath.section)], with: .fade)
            tableView.insertRows(at: indexPaths, with: .fade)
            tableView.endUpdates()
        }

    }
}

// MARK: - SwitchCellDelegate

extension FilterViewController: SwitchCellDelegate {
    func switchCell(_ switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: switchCell)!
        switch indexPath.section {
        case 0:
            offeringDealChoice = value
        default:
            categoriesSwitchStates[indexPath.row] = value
        }
    }
}
