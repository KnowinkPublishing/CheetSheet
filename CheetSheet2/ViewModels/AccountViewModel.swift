//
//  AccountViewModel.swift
//  CheatSheet
//
//  Created by Steven Suranie on 11/17/17.
//  Copyright © 2017 Steven Suranie. All rights reserved.
//

import Foundation
import CoreLocation
import RealmSwift

struct accountModel {

    var completitonHandler: (_ message: Data) -> Void  = {(myData: Data) -> Void in

        let strData = String(data: myData, encoding: String.Encoding.utf8) as String?

        if let strJSON = strData {

            //do something with the data
        }

    }

    func createUser(dictData: Dictionary<String, Any>, completion: (_ bSuccess: Bool, _ userName: String)->Void) {

        let myRealm = try! Realm()

        let myController = Controller.sharedInstance
        var dictUser: Dictionary<String, Any> = [:]

        //transfer user entered data
        for(key, value) in dictData {
            dictUser[key] = value
        }

        //get path to user image
        if let imageData = dictUser["userImage"] {

            myController.fileManager.storeImageInDocumentsDirectory(imageData as! Data, "UserImage", "png", completion: { (result, strFilePath) -> Void in

                if result {
                    dictUser["userAvatarPath"] = strFilePath
                } else {
                    dictUser["userAvatarPath"] = ""
                }
            })
        }

        //get location and zip
        if let thisLocation = dictData["userLocation"] as? CLLocation {
            myController.locationManager.getZipCodeAndLocationStringFromLocation(thisLocation, completion: { (strLocation, strZipCode) -> Void in

                dictUser["userLocation"] = strLocation
                dictUser["userZipCode"] = strZipCode
            })
        } else {
            dictUser["userLocation"] = "Unknown"
            dictUser["userZipCode"] = "Unknown"
        }

        /* PHP is looking for this data
         $userName = $_POST["userName"];
         $userID = $_POST["userID"];
         $userEmail = $_POST["userEmail"];
         $userOrgID = $_POST['userOrgID'];
         $userLocation = $_POST['userLocation'];
         $userPassword = $_POST['userPassword'];
         $userZip = $_POST['userZip'];
         $userCreateDt = $_POST['userCreateDt'];
         $userActive = $_POST['bIsActive'];
         $userUpdateDt = $_POST['userUpdateDt'];
         $userLastActiveDt = $_POST['userLastActiveDt'];
         */

        //pass this data to the api manager for storing in database
        myController.apiManager.postData(dictData: dictUser, method: "register", completion: completitonHandler)

        //make local version in core data
        addToRealm(dictUser, completion: { (_ bFinished: Bool) in

            //check to see if object was added to realm
            if bFinished {

                //check realm to make sure object was added, if so pass back success and user name to avc
                let arrUsers = myRealm.objects(CS_User.self)
                if (arrUsers.count > 0) {
                    completion(true, dictUser["userName"] as! String)
                }
            }

        })
    }

    func updateUser(_ dictUserData: Dictionary<String, Any>, _ thisUser: CS_User, completion: (_ bSuccess: Bool)->Void) {

        let myRealm = try! Realm()
        try! myRealm.write {

            thisUser.userName = dictUserData["userName"] as! String
            thisUser.userEmail = dictUserData["userEmail"] as! String

            if let userOrg = dictUserData["userOrg"] {
                thisUser.userOrg = userOrg as! String
            }

            if let userOrgID = dictUserData["userOrgID"] {
                thisUser.userOrg = userOrgID as! String
            }

            //call back to let know we are done and realm can be validated
            completion(true)
        }
    }

    func addToRealm(_ dictUserData: Dictionary<String, Any>, completion: (_ bFinished: Bool)->Void) {

        let myRealm = try! Realm()
        try! myRealm.write {

            let newUser = CS_User()

            newUser.userName = dictUserData["userName"] as! String
            newUser.userEmail = dictUserData["userEmail"] as! String

            if let userOrg = dictUserData["userOrg"] {
                newUser.userOrg = userOrg as! String
            }

            if let userOrgID = dictUserData["userOrgID"] {
                newUser.userOrg = userOrgID as! String
            }

            if let imagePath = dictUserData["userAvatarPath"] {
                newUser.userAvatarPath = imagePath as! String
            }

            newUser.userLocation = dictUserData["userLocation"] as! String
            newUser.userZip = dictUserData["userZipCode"] as! String

            myRealm.add(newUser)

            //call back to let know we are done and realm can be validated
            completion(true)

        }
    }

}
