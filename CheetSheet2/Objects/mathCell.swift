//
//  mathCell.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 7/6/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import UIKit

class mathCell: UITableViewCell {

    @IBOutlet weak var lblExpression: UILabel!
    @IBOutlet weak var lblSymbol: UILabel!
    @IBOutlet weak var lblSample: UILabel!
    @IBOutlet weak var lblResult: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
