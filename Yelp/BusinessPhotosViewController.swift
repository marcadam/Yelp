//
//  BusinessPhotosViewController.swift
//  Yelp
//
//  Created by Marc Adam Anderson on 5/16/16.
//  Copyright © 2016 Marc Adam Anderson. All rights reserved.
//

import UIKit

class BusinessPhotosViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!

    var imageLargeURL: NSURL!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let imageLargeURL = imageLargeURL {
            imageView.setImageWithURL(imageLargeURL)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTapCloseButton(sender: UIBarButtonItem) {
        parentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

}
