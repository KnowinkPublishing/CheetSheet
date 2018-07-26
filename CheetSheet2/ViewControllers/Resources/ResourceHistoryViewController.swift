//
//  ResourceHistoryViewController.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 7/4/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import UIKit
import RealmSwift

class ResourceHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var tblHistory: UITableView!

    var myController = Controller.sharedInstance
    var arrResourceHistory = [CheetSheetSearch]()
    var currentSearchObj: CheetSheetSearch?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {

        myController.animationManager.backButtonHandler(btnBack)

        let myRealm = try! Realm()
        let listObjects = myRealm.objects(CheetSheetSearch.self)

        if listObjects.count > 0 {
            arrResourceHistory = Array(listObjects)
            tblHistory.reloadData()
        }

        tblHistory.rowHeight = 75.0
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - Table View Delegates

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return arrResourceHistory.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: historyCell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! historyCell

        let thisSearchObj = arrResourceHistory[indexPath.row]
        cell.lblTerms.text = thisSearchObj.strTerms
        cell.lblDate.text = myController.dateManager.dateToString(thisSearchObj.dtSearch, "MM/dd/YYYY")
        let strImage = thisSearchObj.strImageName
        cell.ivResource.image = UIImage(named: strImage)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        currentSearchObj = arrResourceHistory[indexPath.row]

        if let thisSearchObj = currentSearchObj {
            self.performSegue(withIdentifier: thisSearchObj.segueType, sender: self)
        }

    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {

            //remove data from array
            let thisSearchObj = arrResourceHistory[indexPath.row]
            arrResourceHistory.remove(at: indexPath.row)

            //remove data from realm
            let myRealm = try! Realm()
            try! myRealm.write {
                myRealm.delete(thisSearchObj)
            }

            //reload table data
            tblHistory.reloadData()

        }
    }

    // MARK: - Prepare for Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "toQuizletFromHistory" {

            let quizletVC = segue.destination as? QuizletViewController
            quizletVC?.bFromHistory = true

            if let thisSearchObj = currentSearchObj {
                quizletVC?.strSearchTerm = thisSearchObj.strTerms
            }

        } else if segue.identifier == "toPBSFromHistory" {

            let pbsVC = segue.destination as? PBSMediaViewController
            pbsVC?.bFromHistory = true

            if let thisSearchObj = currentSearchObj {
                pbsVC?.strSearchTerm = thisSearchObj.strTerms
                pbsVC?.strGrade = thisSearchObj.grade
            }

        } else if segue.identifier == "toMerriamFromHistory" {

            let dictonaryVC = segue.destination as? DictionaryViewController
            dictonaryVC?.bFromHistory = true

            if let thisSearchObj = currentSearchObj {
                dictonaryVC?.strSearchTerm = thisSearchObj.strTerms
            }

        } else if segue.identifier == "toLOCFromHistory" {

            let locVC = segue.destination as? LibOfCongViewController
            locVC?.bFromHistory = true

            if let thisSearchObj = currentSearchObj {
                locVC?.strSearchTerm = thisSearchObj.strTerms
            }

        }
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
