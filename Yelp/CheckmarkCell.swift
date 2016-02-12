//
//  CheckmarkCell.swift
//  Yelp
//
//  Created by Marc Anderson on 2/10/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class CheckmarkCell: UITableViewCell {

    @IBOutlet weak var checkmarkLabel: UILabel!
    @IBOutlet weak var checkmarkImage: UIImageView!

    let circleCheckedImage = UIImage(named: "CircleChecked")
    let circleEmptyImage = UIImage(named: "CircleEmpty")

    var checked: Bool = false {
        didSet {
            checkmarkImage.image = checked ? circleCheckedImage : circleEmptyImage
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
        checkmarkImage.image = circleEmptyImage
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
