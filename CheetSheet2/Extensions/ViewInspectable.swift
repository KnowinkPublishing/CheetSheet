//
//  ViewInspectable.swift
//  iOSInterviewCheatSheet
//
//  Created by Steven Suranie on 11/2/17.
//  Copyright © 2017 Steven Suranie. All rights reserved.
//

import UIKit

@IBDesignable
class ViewInspectable: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension UIView {

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    func returnRadiansFromDegrees(degrees: Double) -> CGFloat {
        return CGFloat(degrees * .pi / degrees)
    }

}

private extension UIView {

}
