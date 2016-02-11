//
//  FilterViewController.swift
//  Yelp
//
//  Created by Marc Anderson on 2/10/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTapCancel(sender: UIBarButtonItem) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

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
            return 4
        case 2:
            return 3
        case 3:
            return 10
        default:
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!

        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell") as! SwitchCell
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier("CheckmarkCell") as! CheckmarkCell
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier("CheckmarkCell") as! CheckmarkCell
        case 3:
            cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell") as! SwitchCell
        default:
            break
        }

        return cell


//        if indexPath.section == 0 || indexPath.section == 3 {
//            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell") as! SwitchCell
//            return cell
//        } else {
//            let cell = tableView.dequeueReusableCellWithIdentifier("CheckmarkCell") as! CheckmarkCell
//            return cell
//        }

    }

}
