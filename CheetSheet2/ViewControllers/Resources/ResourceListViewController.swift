//
//  ResourceListViewController.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 5/24/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import UIKit
import SwiftSpinner
import Firebase

class ResourceListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, LessonViewProtocol {

    enum PathDirectionType {
        case nextPath
        case previousPath
    }

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var tblResourceList: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnRefresh: UIButton!
    @IBOutlet weak var btnPrevious: UIButton!

    var myController = Controller.sharedInstance
    var myModel = ResourceListModel()
    var configFile = csConfig()
    var arrData = [Any]()
    var arrOriginalData = [Any]()
    var strSource = ""
    var strReturnPath = ""
    var strLessonURL: String?
    var strLessonTitle: String?
    var arrPaths = [String]()
    var currentPathIdx = 0
    var strCurrentPath: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        tblResourceList.rowHeight = UITableViewAutomaticDimension
        tblResourceList.estimatedRowHeight = 140
        configFile.arrOriginalData = arrData
        
        Analytics.setScreenName("Khan Academy", screenClass: "ResourceListViewController")

    }

    override func viewDidAppear(_ animated: Bool) {

        myController.animationManager.backButtonHandler(btnBack)
        lblTitle.text = strSource

    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - Table Nav

    @IBAction func refreshTable(_ sender: Any) {

        arrPaths.removeAll()
        arrData = configFile.arrOriginalData
        tblResourceList.reloadData()
    }

    @IBAction func previousPath(_ sender: Any) {

        if arrPaths.count > 0 {
            currentPathIdx = currentPathIdx - 1
            if currentPathIdx < 0 {
                refreshTable("sender")
                currentPathIdx = 0
            } else {
                getTableData(arrPaths[currentPathIdx])
            }
        }

    }

    func getTableData(_ strPath: String) {

        myModel.retrieveKhanAPI("https", configFile.khanBaseURL, strPath, completion: {(bSuccess, dictJSON, strErrMsg, _) in
            if bSuccess {
                self.myModel.parseJSON(dictJSON, completion: {(_, arrResults, _) in

                    self.arrData = arrResults

                    DispatchQueue.main.async {
                        SwiftSpinner.hide()
                        self.tblResourceList.reloadData()
                    }
                })
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: resourceCell = tableView.dequeueReusableCell(withIdentifier: "resourceListCell") as! resourceCell

        //need to check the data type of the arrData objects
        if let dictObj = arrData[indexPath.row] as? Dictionary<String, Any> {
            cell.lblTitle!.text = dictObj["display"] as? String

            if let strDescription = dictObj["description"] as? String {

                //get string height
                let labelHeigth = strDescription.height(withConstrainedWidth: cell.lblDescription.frame.size.width, font: UIFont(name: "AvenirNext-Regular", size: 16.0)!)
                var labelFrame = cell.lblDescription.frame
                labelFrame.size.height = labelHeigth
                cell.lblDescription.frame = labelFrame

                cell.lblDescription!.text = strDescription

            } else {
                cell.lblDescription.text = ""
            }

            if let imgURL = dictObj["iconURL"] as? String, let thisURL = URL(string: imgURL) {
                cell.ivResource.downloadedFrom(url: thisURL)
            }
        }

        return cell

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        SwiftSpinner.show("Digging through the Khan Academy files...")

        //check if there is a sub routine or if we have reached lesson
        if let dictObj = arrData[indexPath.row] as? Dictionary<String, Any> {

            if let strKind = dictObj["kind"] as? String, strKind == "topic", let strPath = dictObj["path"] as? String {

                if strCurrentPath != nil {
                    arrPaths.append(strPath)
                    currentPathIdx = arrPaths.count - 1
                }
                strCurrentPath = strPath

                getTableData(strPath)

            } else {

                if let thisURL = dictObj["url"] as? String, let thisTitle = dictObj["display"] as? String {

                    DispatchQueue.main.async {
                        self.strLessonURL = thisURL
                        self.strLessonTitle = thisTitle
                        self.performSegue(withIdentifier: "toLessonFromList", sender: self)
                    }
                }

            }
        }

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        let vcLesson = segue.destination as? LessonViewController

        if let strLesson = strLessonURL, let strTitle = strLessonTitle {
            vcLesson!.strLessonURL = strLesson
            vcLesson!.strLessonTitle = strTitle
            vcLesson!.myLessonType = .khanAcademyLesson
            vcLesson?.myDelegate = self
        }

    }

    func closeSpinner() {
        SwiftSpinner.hide()
    }

    @IBAction func goBack(_ sender: Any) {
        myController.animationManager.backButtonCloseHandler(btnBack, self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Rotation
    override open var shouldAutorotate: Bool {
        return false
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
