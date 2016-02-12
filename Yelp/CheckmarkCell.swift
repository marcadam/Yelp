//
//  CheckmarkCell.swift
//  Yelp
//
//  Created by Marc Anderson on 2/10/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol CheckmarkCellDelegate {
    optional func checkmarkCell(checkmarkCell: CheckmarkCell, didChangeValue value: Bool)
}

class CheckmarkCell: UITableViewCell {

    @IBOutlet weak var checkmarkLabel: UILabel!
    @IBOutlet weak var checkmarkImage: UIImageView!

    weak var delegate: CheckmarkCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
        checkmarkImage.image = UIImage(named: "CircleEmpty")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
