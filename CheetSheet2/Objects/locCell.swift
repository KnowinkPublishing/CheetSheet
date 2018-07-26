//
//  locCell.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 7/11/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import UIKit

class locCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var ivThumb: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
