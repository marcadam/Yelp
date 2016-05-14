//
//  BusinessDetailsView.swift
//  Yelp
//
//  Created by Marc Adam Anderson on 5/13/16.
//  Copyright © 2016 Marc Adam Anderson. All rights reserved.
//

import UIKit

class BusinessDetailsView: UIView {

    @IBOutlet weak var writeReviewContainerView: UIView!
    @IBOutlet weak var actionsContainerView: UIView!

    @IBOutlet var contentView: UIView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }

    func initSubviews() {
        // standard initialization logic
        let nib = UINib(nibName: "BusinessDetailsView", bundle: nil)
        nib.instantiateWithOwner(self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)

        // custom initialization logic
        writeReviewContainerView.layer.cornerRadius = 5.0
        writeReviewContainerView.layer.borderWidth = 1.0
        writeReviewContainerView.layer.borderColor = UIColor.lightGrayColor().CGColor
        writeReviewContainerView.backgroundColor = UIColor.yelpExtraLightBackgroundColor()

        actionsContainerView.backgroundColor = UIColor.yelpExtraLightBackgroundColor()
    }

}
