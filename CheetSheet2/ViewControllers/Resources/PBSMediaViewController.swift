//
//  PBSMediaViewController.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 6/18/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import UIKit
import SwiftSpinner
import RealmSwift

class PBSMediaViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var vPickerWrapper: UIView!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var pvGrades: UIPickerView!
    @IBOutlet weak var vTableWrapper: UIView!
    @IBOutlet weak var tblLessons: UITableView!
    @IBOutlet weak var btnCloseTable: UIButton!
    @IBOutlet weak var lcTableWrapperBottom: NSLayoutConstraint!

    var myController = Controller.sharedInstance
    var myConfig = csConfig()
    var myModel = PBSLMModel()
    var arrGrades = ["", "K", "1st", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th", "9th", "10th", "11th", "12th"]
    var arrData = [pbsLesson]()
    var arrSelectedGrades = [String]()
    var selectedLesson: pbsLesson?
    var selectedMediaURL: URL?
    var bFromHistory = false
    var strSearchTerm: String?
    var strGrade: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        pvGrades.delegate = self
        pvGrades.dataSource = self

        tblLessons.rowHeight = UITableViewAutomaticDimension
        tblLessons.estimatedRowHeight = 120

        self.view.bringSubview(toFront: vTableWrapper)
    }

    override func viewDidAppear(_ animated: Bool) {

        myController.animationManager.backButtonHandler(btnBack)

        if bFromHistory {
            if let strMySearchTerm = strSearchTerm, let strMyGrade = strGrade {
                arrSelectedGrades.removeAll()
                arrSelectedGrades.append(strMyGrade)
                txtSearch.text = strMySearchTerm
                conductSearch()
            }
        }

    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func searchPBSLM(_ sender: Any) {
        conductSearch()
    }

    func conductSearch() {

        //validate
        myModel.validateSearchEntries(txtSearch, arrSelectedGrades, completion: {bIsValid, strErrMsg in

            if !bIsValid {
                myController.alert.presentAlert("Search Error", strErrMsg, self)
            } else {

                //search
                SwiftSpinner.show("Connecting to PBS Learning Media...")

                myModel.getSearchResults(txtSearch.text!, arrSelectedGrades, completion: {(bSuccess, arrLessons, _) in

                    if bSuccess {

                        DispatchQueue.main.async {

                            SwiftSpinner.hide()
                            self.arrData = arrLessons
                            self.tblLessons.reloadData()
                            self.toggleTable()

                            //store search
                            let thisSearchCache = CheetSheetSearch()
                            let resourceType: ResourceSourceType = .pbslmResource
                            let segueType: ResourceSequeType = .pbslmSegue

                            thisSearchCache.strTerms = self.txtSearch.text!
                            thisSearchCache.dtSearch = Date()
                            thisSearchCache.grade = self.arrSelectedGrades.first!
                            thisSearchCache.resourceType = resourceType.rawValue
                            thisSearchCache.segueType = segueType.rawValue

                            if self.myController.dataManager.checkForDuplicateSearch(thisSearchCache) {
                                let myRealm = try! Realm()
                                try? myRealm.write {
                                    myRealm.add(thisSearchCache)
                                }
                            } else {
                                print("Do not need to save this search again.")
                            }

                        }

                    } else {
                        self.myController.alert.presentAlert("Error", "There was an error with the PBS Learning Media data.", self)
                    }
                })
            }
        })

        //myModel.getSearchResults(strText, selectedGrade!, completion: {(bSuccess, arrData, dictResultsData, strErrMsg) in })
    }

    // MARK: - Picker View Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrGrades.count
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50.0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrGrades[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        if row > 0 {
            arrSelectedGrades.append(arrGrades[row])
        }

    }

    // MARK: - Table View Methods

    @IBAction func closeTable(_ sender: Any) {
        toggleTable()
    }

    func toggleTable() {

        var thisConstant: CGFloat = 572.0

        if lcTableWrapperBottom.constant == 572.0 {
            thisConstant = 0.0
        }

        UIView.animate(withDuration: 0.3, animations: {

            self.lcTableWrapperBottom.constant = thisConstant
            self.view.layoutIfNeeded()
            self.view.needsUpdateConstraints()

        })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: PBSCell = tblLessons.dequeueReusableCell(withIdentifier: "pbsCell", for: indexPath) as! PBSCell

        let thisLesson = arrData[indexPath.row]

        //get string height
        let labelHeigth = thisLesson.description.height(withConstrainedWidth: cell.lblDescription.frame.size.width, font: UIFont(name: "AvenirNext-Regular", size: 16.0)!)
        var labelFrame = cell.lblDescription.frame
        labelFrame.size.height = labelHeigth
        cell.contentView.frame = labelFrame

        cell.lblTitle.text = thisLesson.title
        cell.lblDescription.text = thisLesson.description

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        selectedLesson = arrData[indexPath.row]

        if let thisLesson = selectedLesson, let theseComps = URLComponents(string: thisLesson.uri), let thisHost = theseComps.host, let thisScheme = theseComps.scheme {

            let thisPath = theseComps.path
            var theseParams = [URLQueryItem]()

            if theseComps.queryItems != nil {
                theseParams = theseComps.queryItems!
            }

            myModel.getMediaURL(thisScheme, thisHost, thisPath, theseParams, completition: { (bSuccess, mediaURL, _) in

                if bSuccess {

                    DispatchQueue.main.async {

                        self.selectedMediaURL = mediaURL
                        self.performSegue(withIdentifier: "toLessonViewFromPBS", sender: self)
                    }

                }

            })

        } else {

            myController.alert.presentAlert("Error With Media", "Could not retrieve the selected media.", self)
            print(selectedLesson!.uri)
        }

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "toLessonViewFromPBS" {

            let lessonVC = segue.destination as? LessonViewController
            if let thisVC = lessonVC, let thisLesson = selectedLesson, let thisLessonURL = selectedMediaURL {
                thisVC.strLessonURL = thisLessonURL.absoluteString
                thisVC.strLessonTitle = thisLesson.title
            }

        }
    }

    // MARK: - Text Field Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        //closes keyboard
        self.view.endEditing(true)

        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {

        //closes keyboard
        self.view.endEditing(true)

    }

    @IBAction func goBack(_ sender: Any) {
        myController.animationManager.backButtonCloseHandler(btnBack, self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
