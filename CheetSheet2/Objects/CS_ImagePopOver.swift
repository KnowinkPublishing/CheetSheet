//
//  CS_ImagePopOver.swift
//  CheetSheet
//
//  Created by Steven Suranie on 4/10/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import UIKit

class CS_ImagePopOver: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var ivMyImage: UIImageView!
    @IBOutlet weak var btnClose: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()

    }

    private func commonInit() {

        Bundle.main.loadNibNamed("CS_ImagePopOver", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    }

    @IBAction func closePopover(_ sender: Any) {
        NotificationCenter.default.post(name: .closeImagePopover, object: nil)
    }

}
