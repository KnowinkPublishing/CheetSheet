//
//  ViewController.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 5/16/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

class ViewController: UIViewController {

    @IBOutlet weak var btnNav: UIButton!
    @IBOutlet weak var vBackground: ViewInspectable!
    @IBOutlet weak var vNav: UIView!

    @IBOutlet weak var btnInfo: UIButton!
    @IBOutlet weak var btnViewTopic: UIButton!
    @IBOutlet weak var btnAddTopic: UIButton!
    @IBOutlet weak var btnResources: UIButton!

    var myController = Controller.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        vNav.clipsToBounds = true
    }

    override func viewDidAppear(_ animated: Bool) {

    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func showNav(_ sender: Any) {

        if vBackground.transform == CGAffineTransform.identity {

            var scale: CGFloat = 0.0
            switch UIDevice.current.orientation {
            case .portrait:
                scale = 22.0
            case .portraitUpsideDown:
                scale = 22.0
            case .landscapeLeft:
                scale =  44.0
            case .landscapeRight:
                scale = 44.0
            default:
                scale = 44.0
            }

            UIView.animate(withDuration: 0.7, animations: {
                self.vBackground.transform = CGAffineTransform(scaleX: scale, y: scale)
                self.vNav.transform = CGAffineTransform(translationX: 0, y: -79)
                self.btnNav.transform = CGAffineTransform(rotationAngle: self.btnNav.returnRadiansFromDegrees(degrees: 180.0))

            }, completion: {(_) in

            })

        } else {

            UIView.animate(withDuration: 0.7, animations: {
                self.vBackground.transform = CGAffineTransform.identity
                self.vNav.transform = CGAffineTransform.identity
                self.btnNav.transform = CGAffineTransform.identity
            }, completion: {(_) in

            })
        }
    }

    @IBAction func showAddTopic(_ sender: Any) {
        self.performSegue(withIdentifier: "toAddTopicFromRoot", sender: self)
    }

    @IBAction func showViewTopic(_ sender: Any) {
        self.performSegue(withIdentifier: "toViewTopicFromRoot", sender: self)
    }

    @IBAction func showInfo(_ sender: Any) {
        self.performSegue(withIdentifier: "toInfoFromRoot", sender: self)

    }

    @IBAction func showReources(_ sender: Any) {
        self.performSegue(withIdentifier: "toResourcesFromRoot", sender: self)
    }

    // MARK: - Rotation
    override open var shouldAutorotate: Bool {
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
