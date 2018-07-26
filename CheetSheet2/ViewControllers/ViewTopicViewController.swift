//
//  ViewTopicViewController.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 5/17/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import UIKit
import RealmSwift

class ViewTopicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblTopics: UITableView!
    @IBOutlet weak var btnBack: UIButton!

    var arrTopics = [CS_Topic]()
    var arrMyTopics: Array<CS_Topic> = []
    var selectedTopic: CS_Topic?
    var myController = Controller.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {

        myController.animationManager.backButtonHandler(btnBack)

        arrMyTopics.removeAll()

        let myRealm = try! Realm()
        let arrTopics = myRealm.objects(CS_Topic.self).sorted(byKeyPath: "topicTitle", ascending: true)

        if arrTopics.count > 0 {
            arrMyTopics = Array(arrTopics)
            tblTopics.reloadData()
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return arrMyTopics.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: topicCell = tableView.dequeueReusableCell(withIdentifier: "topicCell") as! topicCell

        let thisTopic = arrMyTopics[indexPath.row]
        cell.lblCellTitle.text = thisTopic.topicTitle
        cell.lblSubTitle.text = thisTopic.topicSubTitle

        return cell

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        selectedTopic = arrMyTopics[indexPath.row]
        self.performSegue(withIdentifier: "toTopicFromTable", sender: self)

    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {

            //remove data from array
            let thisTopic = arrMyTopics[indexPath.row]
            arrMyTopics.remove(at: indexPath.row)

            //remove data from realm
            let myRealm = try! Realm()
            try! myRealm.write {
                myRealm.delete(thisTopic)
            }

            //reload table data
            tblTopics.reloadData()

        }
    }

    //MAIN - Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let topicVC = segue.destination as? AddTopicViewController {

            topicVC.bIsEditing = true
            topicVC.myTopic = selectedTopic

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
