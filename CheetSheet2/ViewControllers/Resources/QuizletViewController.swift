//
//  QuizletViewController.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 5/26/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import UIKit
import SwiftSpinner
import RealmSwift
import Firebase

class QuizletViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var lcTextFieldBottom: NSLayoutConstraint!
    @IBOutlet weak var lcTblHeight: NSLayoutConstraint!
    @IBOutlet weak var lcTableBottom: NSLayoutConstraint!
    @IBOutlet weak var tblQuizlet: UITableView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var lblResults: UILabel!
    @IBOutlet weak var vButtonWrapper: UIView!
    @IBOutlet weak var btnPageDown: UIButton!
    @IBOutlet weak var btnPageUp: UIButton!

    var arrData = [CS_Quizlet]()
    var myController = Controller.sharedInstance
    var myModel = QuizeltModel()
    var searchPageNum: Int = 1
    var maxPageCount: Int = 0
    var selectedQuizlet: CS_Quizlet?
    var bFromHistory = false
    var strSearchTerm = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        tblQuizlet.rowHeight = UITableViewAutomaticDimension
        tblQuizlet.estimatedRowHeight = 120
        
        Analytics.setScreenName("Quizlet", screenClass: "QuizletViewController")
    }

    override func viewDidAppear(_ animated: Bool) {
        myController.animationManager.backButtonHandler(btnBack)

        if bFromHistory {
            txtSearch.text = strSearchTerm
            runQuizletSearch()
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func pageDown(_ sender: Any) {
        searchPageNum -= 1
        if searchPageNum < 1 {
            searchPageNum = 1
        }

        runQuizletSearch()
    }

    @IBAction func pageUp(_ sender: Any) {
        searchPageNum += 1
        if searchPageNum > maxPageCount {
            searchPageNum = maxPageCount
        }

        runQuizletSearch()
    }

    func runQuizletSearch() {

        guard let strText = txtSearch.text, !strText.isEmpty else {
            print("text entry error")
            return
        }

        SwiftSpinner.show("Finding the Quizlets...")

        myModel.getSearchResults(strText, searchPageNum, completion: {(bSuccess, arrData, dictResultsData, _) in

            if bSuccess {
                DispatchQueue.main.async {
                    self.arrData = arrData
                    self.tblQuizlet.reloadData()

                    if let numTotalResults = dictResultsData["totalResults"], let numPage = dictResultsData["page"], let numTotalPages = dictResultsData["totalPages"] {
                        self.lblResults.text = "There were \(numTotalResults) results. Showing page \(numPage) of \(numTotalPages)"
                    } else {
                        self.lblResults.text = ""
                    }

                    UIView.animate(withDuration: 0.3, animations: {
                        self.btnPageUp.alpha = 1.0
                        self.btnPageDown.alpha = 1.0
                    })

                    self.maxPageCount = dictResultsData["totalPages"] as? Int ?? 0

                    //store search
                    let thisSearchCache = CheetSheetSearch()
                    let resourceType: ResourceSourceType = .quizletResource
                    let segueType: ResourceSequeType = .quizletSegue

                    thisSearchCache.strTerms = strText
                    thisSearchCache.dtSearch = Date()
                    thisSearchCache.resourceType = resourceType.rawValue
                    thisSearchCache.segueType = segueType.rawValue

                    if self.myController.dataManager.checkForDuplicateSearch(thisSearchCache) {
                        let myRealm = try! Realm()
                        try? myRealm.write {
                            myRealm.add(thisSearchCache)
                        }
                    } else {
                        print ("Do not need to save this search!")
                    }

                    self.showTable()
                }
            }

        })
    }

    // MARK: - Table View Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return arrData.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: quizletCell = tableView.dequeueReusableCell(withIdentifier: "quizletListCell") as! quizletCell

        let thisQuizlet: CS_Quizlet = arrData[indexPath.row]
        cell.lblTitle.text = thisQuizlet.quizletTitle
        cell.lblCreator.text = thisQuizlet.quizletCreatedBy
        cell.lblCreationDate.text = thisQuizlet.quizletCreatedDate

        //get string height
        let labelHeigth = thisQuizlet.quizletDescription.height(withConstrainedWidth: cell.lblDescription.frame.size.width, font: UIFont(name: "AvenirNext-Regular", size: 16.0)!)
        var labelFrame = cell.lblDescription.frame
        labelFrame.size.height = labelHeigth
        cell.lblDescription.frame = labelFrame

        if thisQuizlet.quizletDescription.isEmpty {
            cell.lblDescription.text = "No description provided"
        } else {
            cell.lblDescription.text = thisQuizlet.quizletDescription
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedQuizlet = arrData[indexPath.row]
        self.performSegue(withIdentifier: "toLessonFromQuizlet", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vcLessons = segue.destination as? LessonViewController

        if let thisQuizlet = selectedQuizlet {
            vcLessons?.strLessonURL = thisQuizlet.quizletURL
            vcLessons?.strLessonTitle = thisQuizlet.quizletTitle
            vcLessons?.myLessonType = .quizletLesson
        }
    }

    // MARK: - TextField Methods

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        //closes keyboard
        self.view.endEditing(true)

        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        runQuizletSearch()
    }

    func showTable() {

        SwiftSpinner.hide()
        var thisConstant = lcTableBottom.constant

        if thisConstant == 0 {

            //table is displayed, hide it

            thisConstant = -573

            UIView.animate(withDuration: 0.3, animations: {

                self.view.layoutIfNeeded()
                self.view.needsUpdateConstraints()
                self.lcTableBottom.constant = thisConstant

            })

        } else {
            //table hidden, display it

            //add a new constant
            let lcTableTop = NSLayoutConstraint(item: tblQuizlet, attribute: .top, relatedBy: .equal, toItem: vButtonWrapper, attribute: .bottom, multiplier: 1.0, constant: 10.0)
            lcTableTop.identifier = "newTableTop"
            thisConstant = 0

            UIView.animate(withDuration: 0.3, animations: {

                self.view.layoutIfNeeded()
                self.view.needsUpdateConstraints()
                self.view.addConstraint(lcTableTop)

                self.lcTableBottom.constant = thisConstant

            })

        }

    }

    // MARK: - Nav

    @IBAction func goBack(_ sender: Any) {
        myController.animationManager.backButtonCloseHandler(btnBack, self)
    }

    @objc func closeKeyboard(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

}
