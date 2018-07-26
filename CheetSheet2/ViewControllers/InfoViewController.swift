//
//  InfoViewController.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 5/17/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import UIKit
import MessageUI

class InfoViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var txtInfo: UITextView!
    @IBOutlet weak var btnMail: UIButton!
    @IBOutlet weak var btnBack: UIButton!

    var myController = Controller.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {

        myController.animationManager.backButtonHandler(btnBack)

        if let rtfPath = Bundle.main.url(forResource: "topic_help", withExtension: "rtf") {
            do {
                let attributedStringWithRtf: NSAttributedString = try NSAttributedString(url: rtfPath, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
                self.txtInfo.attributedText = attributedStringWithRtf
            } catch let error {
                print("Got an error trying to display privacy file:\n \(error)")
            }
        } else {
            print("Can't find file!")
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func goBack(_ sender: Any) {
        myController.animationManager.backButtonCloseHandler(btnBack, self)
    }

    @IBAction func contactUS(_ sender: Any) {
        sendEmail()
    }

    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["steve@martiantribe.com"])
            mail.setSubject("Message from the CheetSheet app!")

            present(mail, animated: true)

        } else {

            myController.alert.presentAlert("Email Error", "You cannot send email from this device.", self)
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
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
