//
//  SwitchCell.swift
//  Yelp
//
//  Created by Marc Adam Anderson on 2/10/16.
//  Copyright © 2016 Marc Adam Anderson. All rights reserved.
//

import UIKit

@objc protocol SwitchCellDelegate {
    @objc optional func switchCell(_ switchCell: SwitchCell, didChangeValue value: Bool)
}

class SwitchCell: UITableViewCell {

    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var switchToggle: UISwitch!

    weak var delegate: SwitchCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onSwitchValueChanged(_ sender: AnyObject) {
        delegate?.switchCell?(self, didChangeValue: switchToggle.isOn)
    }
}
