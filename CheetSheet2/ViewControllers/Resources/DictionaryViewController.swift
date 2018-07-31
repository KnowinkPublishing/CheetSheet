//
//  DictionaryViewController.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 6/28/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase

class DictionaryViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var segSearchOptions: UISegmentedControl!
    @IBOutlet weak var vDefinitionWrapper: UIView!
    @IBOutlet weak var lblWord: UILabel!
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var btnSound: UIButton!
    @IBOutlet weak var tblDefinitions: UITableView!

    var myController = Controller.sharedInstance
    var myConfig = csConfig()
    var myModel = DictionaryViewModel()

    var strWord: String?
    var arrDefinitons = [mw_definition]()
    var strAudioURL: String?
    var bFromHistory = false
    var strSearchTerm: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        //register for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.displayEntry(_:)), name: Notification.Name("dictionaryXMLParsed"), object: nil)

        tblDefinitions.rowHeight = UITableViewAutomaticDimension
        tblDefinitions.estimatedRowHeight = 120
        
        Analytics.setScreenName("Merriam Webster", screenClass: "DictionaryViewController")

    }

    override func viewDidAppear(_ animated: Bool) {
        myController.animationManager.backButtonHandler(btnBack)

        if bFromHistory {
            if let strSearchWord = strSearchTerm {
                txtSearch.text = strSearchWord
                searchForWord(strSearchWord)
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: - Search Methods
    func searchForWord(_ strWordToSearch: String) {
        myModel.makeXMLCall(strWordToSearch, 0)
    }

    @objc func displayEntry(_ note: Notification) {

        if let dictUserInfo = note.userInfo, let thisEntry = dictUserInfo["Entry"] as? dictionaryEntry {

            if let strSearchWord = thisEntry.strWord {
                strWord = strSearchWord
                arrDefinitons = thisEntry.arrDefinitions
                strAudioURL = thisEntry.urlSound
            }

            btnSound.alpha = 1.0

            DispatchQueue.main.async {

                self.lblWord.text = self.strWord
                self.lblCount.text = String(self.arrDefinitons.count) + " definitions."
                self.tblDefinitions.reloadData()
            }

            //store search
            let thisSearchCache = CheetSheetSearch()
            let resourceType: ResourceSourceType = .dictionaryResource
            let segueType: ResourceSequeType = .dictionarySegue

            thisSearchCache.strTerms = self.strWord ?? ""
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

        }

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrDefinitons.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: UITableViewCell = tblDefinitions.dequeueReusableCell(withIdentifier: "reuseCell", for: indexPath)
        let thisDefinition = arrDefinitons[indexPath.row]

        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping

        //get string height
        if let strDefinition = thisDefinition.mw_description {

            let labelHeigth = strDefinition.height(withConstrainedWidth: cell.textLabel!.frame.size.width, font: UIFont(name: "AvenirNext-Regular", size: 16.0)!)
            var labelFrame = cell.textLabel!.frame
            labelFrame.size.height = labelHeigth
            cell.contentView.frame = labelFrame

            cell.textLabel!.text = thisDefinition.mw_description
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    @IBAction func playSound(_ sender: Any) {

        if let strAudioEndPoint = strAudioURL {
            let audioURL =  myModel.getAudioURL(strAudioEndPoint)

            var downloadTask: URLSessionDownloadTask
            downloadTask = URLSession.shared.downloadTask(with: audioURL, completionHandler: { [weak self](URL, _, _) -> Void in

                if let thisURL = URL {
                    self!.myController.soundManager.playSound(thisURL, .wav)
                }

            })

            downloadTask.resume()

            //play audio

        } else {
            myController.alert.presentAlert("No Sound Available", "There is no sound available for the word: \(String(describing: strWord))", self)
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

        if let strWord = textField.text {
            if !strWord.isEmpty {
                searchForWord(strWord)
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
