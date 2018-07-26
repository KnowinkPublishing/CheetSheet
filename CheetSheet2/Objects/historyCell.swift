//
//  historyCell.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 7/4/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import UIKit

class historyCell: UITableViewCell {

    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTerms: UILabel!
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
