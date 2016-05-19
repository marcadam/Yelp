//
//  MapTableViewCell.swift
//  Yelp
//
//  Created by Marc Adam Anderson on 5/18/16.
//  Copyright © 2016 Marc Adam Anderson. All rights reserved.
//

import UIKit
import MapKit

class MapTableViewCell: UITableViewCell {

    @IBOutlet weak var mapView: MKMapView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
