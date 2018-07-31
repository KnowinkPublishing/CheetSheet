//
//  LessonViewController.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 5/25/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import UIKit
import WebKit
import Firebase

protocol LessonViewProtocol {
    func closeSpinner()
}

class LessonViewController: UIViewController {

    enum lessonType {
        case khanAcademyLesson
        case quizletLesson
        case pbsLearningMedia
    }

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var webView: WKWebView!

    var strLessonURL: String?
    var strLessonTitle: String?
    var myController = Controller.sharedInstance
    var myLessonType: lessonType?
    var myDelegate: LessonViewProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Analytics.setScreenName("Lessons", screenClass: "LessonViewController")

    }

    override func viewDidAppear(_ animated: Bool) {
        myController.animationManager.backButtonHandler(btnBack)

        if let strLesson = strLessonTitle {
            lblTitle.text = strLesson
        }

        //load web url
        if let strURL = strLessonURL, let url = URL(string: strURL) {
            let urlRequest = URLRequest(url: url)
            webView.load(urlRequest)
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func goBack(_ sender: Any) {
        myDelegate?.closeSpinner()
        myController.animationManager.backButtonCloseHandler(btnBack, self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
