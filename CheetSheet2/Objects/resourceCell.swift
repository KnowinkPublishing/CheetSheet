//
//  resourceCell.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 5/25/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import UIKit

class resourceCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var ivResource: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
