//
//  CheckmarkCell.swift
//  Yelp
//
//  Created by Marc Adam Anderson on 2/10/16.
//  Copyright © 2016 Marc Adam Anderson. All rights reserved.
//

import UIKit

class CheckmarkCell: UITableViewCell {

    @IBOutlet weak var checkmarkLabel: UILabel!
    @IBOutlet weak var checkmarkImage: UIImageView!

    let cellStateCheckedImage = UIImage(named: "CircleChecked")
    let cellStateUncheckedImage = UIImage(named: "CircleEmpty")
    let cellStateCollapsedImage = UIImage(named: "ExpandArrow")

    enum CellState {
        case checked, unchecked, collapsed
    }

    var state: CellState = CellState.collapsed {
        didSet {
            switch state {
            case .checked:
                checkmarkImage.image = cellStateCheckedImage
            case .unchecked:
                checkmarkImage.image = cellStateUncheckedImage
            case .collapsed:
                checkmarkImage.image = cellStateCollapsedImage
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
        checkmarkImage.image = cellStateUncheckedImage
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
