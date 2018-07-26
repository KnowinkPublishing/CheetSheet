//
//  AnimationManager.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 5/23/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import Foundation
import UIKit

struct AnimationManager {

    var backButtonHandler: (_ thisButton: UIButton) -> Void  = {(thisButton: UIButton) -> Void in

        UIView.animate(withDuration: 0.6, animations: {
            thisButton.transform = CGAffineTransform(rotationAngle: thisButton.returnRadiansFromDegrees(degrees: 180.0))
        }, completion: {(_) in

        })

    }

    var backButtonCloseHandler: (_ thisButton: UIButton, _ thisVC: UIViewController) -> Void  = { (thisButton: UIButton, thisVC: UIViewController) -> Void in

        UIView.animate(withDuration: 0.6, animations: {
            thisButton.transform = CGAffineTransform.identity
        }, completion: {(_) in
            thisVC.dismiss(animated: true, completion: nil)
        })

    }

}
