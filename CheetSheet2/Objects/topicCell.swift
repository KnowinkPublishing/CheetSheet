//
//  topicCell.swift
//  iOSInterviewCheatSheet
//
//  Created by Steven Suranie on 11/2/17.
//  Copyright © 2017 Steven Suranie. All rights reserved.
//

import UIKit

class topicCell: UITableViewCell {

    @IBOutlet weak var lblCellTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var lblSection: UILabel!

    var topicTitle: String?
    var topicSection: String?
    var topicSubtitle: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
