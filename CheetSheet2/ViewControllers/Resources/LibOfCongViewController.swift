//
//  LibOfCongViewController.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 7/11/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import UIKit
import SwiftSpinner
import RealmSwift

class LibOfCongViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tblResults: UITableView!
    @IBOutlet weak var vDetailWrapper: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var ivDetail: UIImageView!
    @IBOutlet weak var lblCreator: UILabel!
    @IBOutlet weak var lblCreationDate: UILabel!
    @IBOutlet weak var lblMedium: UILabel!
    @IBOutlet weak var btnCloseDetails: UIButton!
    @IBOutlet weak var lcWrapperBottom: NSLayoutConstraint!
    @IBOutlet weak var lcWrapperTop: NSLayoutConstraint!

    var myController = Controller.sharedInstance
    var myModel = LibOfCongressModel()
    var arrData: Array<locObj>?
    var selectedLOCObj: locObj?
    var bGetSelectedData = false
    var bFromHistory = false
    var strSearchTerm: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        tblResults.rowHeight = UITableViewAutomaticDimension
        tblResults.estimatedRowHeight = 140
    }

    override func viewDidAppear(_ animated: Bool) {

        myController.animationManager.backButtonHandler(btnBack)

        if bFromHistory {
            if let strMySearchTerm = strSearchTerm {
                txtSearch.text = strMySearchTerm
                runLOCSearch(strMySearchTerm)
            }
        }
    }

    func displaySelectedImage() {

        if bGetSelectedData {

            if let locObj = selectedLOCObj {

                myModel.getMediaURL("https:" + locObj.image.full, completion: {(bSuccess, imgFromURL, _) in

                    if bSuccess {

                        DispatchQueue.main.async {

                            self.lblTitle.text = locObj.title ?? "Unknown"
                            self.lblMedium.text = locObj.medium ?? "Unknown"
                            self.lblCreator.text = locObj.creator ?? "Unknown"
                            self.lblCreationDate.text = locObj.created_published_date ?? "Unknown"
                            self.ivDetail.image = imgFromURL

                        }
                    }
                })
            }

        }  else {
            
            self.lblTitle.text = ""
            self.lblMedium.text = ""
            self.lblCreator.text = ""
            self.lblCreationDate.text = ""
            self.ivDetail.image = nil
        }

        var thisConstant = self.view.frame.size.height + 1.0

        if lcWrapperTop.constant == self.view.frame.size.height + 1.0 {
            thisConstant = 15.0
        } else {
            thisConstant = self.view.frame.size.height + 1.0
        }

        UIView.animate(withDuration: 0.3, animations: {

            self.lcWrapperTop.constant = thisConstant
            self.view.layoutIfNeeded()
            self.view.needsUpdateConstraints()
        })

    }

    @IBAction func closeDetails(_ sender: Any) {

        bGetSelectedData = false
        displaySelectedImage()
    }

    // MARK: - Table View Delegates

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if let arrTableData = arrData {
            return arrTableData.count
        }

        return 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: locCell = tblResults.dequeueReusableCell(withIdentifier: "locCell", for: indexPath) as! locCell

        if let arrTableData = arrData {

            let locObj = arrTableData[indexPath.row]

            //get string height
            if let strTitle = locObj.title {
                let labelHeigth = strTitle.height(withConstrainedWidth: cell.lblTitle.frame.size.width, font: UIFont(name: "AvenirNext-Regular", size: 16.0)!)
                var labelFrame = cell.lblTitle.frame
                labelFrame.size.height = labelHeigth
                cell.lblTitle.frame = labelFrame
                cell.lblTitle.text = strTitle
            } else {
                cell.lblTitle.text = "Unknown"
            }

            myModel.getMediaURL("https:" + locObj.image.thumb, completion: {(bSuccess, imgFromURL, _) in

                if bSuccess {

                    DispatchQueue.main.async {
                        cell.ivThumb.contentMode = .scaleAspectFit
                        cell.ivThumb.image = imgFromURL
                    }
                }
            })

        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let arrLOCObjs = arrData {
            selectedLOCObj = arrLOCObjs[indexPath.row]
            bGetSelectedData = true
            displaySelectedImage()
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

        if let strText = textField.text {
            if !strText.isEmpty {
               runLOCSearch(strText)
            }
        }

    }

    func runLOCSearch(_ strToSearch: String) {

        SwiftSpinner.show("Searching Library of Congress Media Collection...")

        myModel.searchLOC(strToSearch, completion: {(bSuccess, arrLOCObjs, _) in

            self.arrData = arrLOCObjs

            DispatchQueue.main.async {

                SwiftSpinner.hide()

                if bSuccess {

                    //store search
                    let thisSearchCache = CheetSheetSearch()
                    let resourceType: ResourceSourceType = .locResource
                    let segueType: ResourceSequeType = .locSegue

                    thisSearchCache.strTerms = strToSearch
                    thisSearchCache.dtSearch = Date()
                    thisSearchCache.grade = ""
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

                    self.tblResults.reloadData()
                } else {
                    self.myController.alert.presentAlert("Search Error", "Your search for \(strToSearch) produced no results.", self)
                }

            }

        })

    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func goBack(_ sender: Any) {
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
