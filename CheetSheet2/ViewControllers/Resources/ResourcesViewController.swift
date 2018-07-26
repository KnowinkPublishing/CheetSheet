//
//  ResourcesViewController.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 5/23/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import UIKit
import SwiftSpinner
import Firebase

enum ExternalSourceTypes: String {
    case khanAcademy = "Khan Academy"
    case quizlet = "Quizelt"
    case pbslm = "PBS Learning Media"
    case dictionary = "Merriam Webster Dictionary"
    case newton = "Newton"
    case libOfCong = "Library of Congress"
}

class ResourcesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var tblResources: UITableView!
    @IBOutlet weak var lcTableBottom: NSLayoutConstraint!
    @IBOutlet weak var btnHistory: UIButton!
    @IBOutlet weak var collResources: UICollectionView!

    var myController = Controller.sharedInstance
    var myModel = ResourceModel()
    var arrResourceData = [Any]()
    var sourceType: ExternalSourceTypes?

    override func viewDidLoad() {

        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {

        myController.animationManager.backButtonHandler(btnBack)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func showHistory(_ sender: Any) {
        self.performSegue(withIdentifier: "toHistoryFromResources", sender: self)
    }

    // MARK: - Collection View Delegates

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myModel.arrResources.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell: resourceCollCell = collectionView.dequeueReusableCell(withReuseIdentifier: "collCell", for: indexPath) as! resourceCollCell

        if let strResource = myModel.arrResources[indexPath.row]["name"] as? String {
            cell.ivResource.image = UIImage(named: strResource.lowercased())
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        SwiftSpinner.show("Doing some magic...")

        var strErrTitle = ""
        //set source
        switch indexPath.row {
        case 0:

            sourceType = .khanAcademy
            strErrTitle = "Khan Academy Error"
            Analytics.logEvent("khan_academy_accessed", parameters: ["resource": "Khan Academy", "Date": Date()])

            myModel.retrieveResource(myModel.arrResources[indexPath.row], completion: {(bSuccess, arrData, strErrMsg) in
                if bSuccess {
                    arrResourceData = arrData
                    self.performSegue(withIdentifier: "toResourceListFromResources", sender: self)
                } else {
                    myController.alert.presentAlert(strErrTitle, strErrMsg, self)
                }
            })

        case 1:

            sourceType = .quizlet
            Analytics.logEvent("quizlet_accessed", parameters: ["resource": "Quizlet", "Date": Date()])
            self.performSegue(withIdentifier: "toQuizletFromResources", sender: self)

        case 2:

            sourceType = .pbslm
            Analytics.logEvent("pbs_accessed", parameters: ["resource": "PBS", "Date": Date()])
            self.performSegue(withIdentifier: "toPBSFromResources", sender: self)

        case 3:
            sourceType = .dictionary
            Analytics.logEvent("merriam_accessed", parameters: ["resource": "Merriam-Webster", "Date": Date()])
            self.performSegue(withIdentifier: "toDictionaryFromResources", sender: self)

        case 4:
            sourceType = .newton
            Analytics.logEvent("newton_accessed", parameters: ["resource": "Newton", "Date": Date()])
            self.performSegue(withIdentifier: "toNewtonFromResources", sender: self)

        case 5:
            sourceType = .libOfCong
            Analytics.logEvent("loc_accessed", parameters: ["resource": "Library Of Congress", "Date": Date()])
            self.performSegue(withIdentifier: "toLibOfCongFromResources", sender: self)

        default:
            sourceType = nil
        }

    }

    // MARK: - Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        SwiftSpinner.hide()

        if let vcResourceList = segue.destination as? ResourceListViewController {

            vcResourceList.arrData = arrResourceData

            if let strSource = sourceType?.rawValue {
                vcResourceList.strSource = strSource
            }

        }

    }

    @IBAction func goBack(_ sender: Any) {
        myController.animationManager.backButtonCloseHandler(btnBack, self)
    }

    // MARK: - Rotation
    override open var shouldAutorotate: Bool {
        return false
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
