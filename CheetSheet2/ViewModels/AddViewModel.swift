//
//  AddViewModel.swift
//  iOSInterviewCheatSheet
//
//  Created by Steven Suranie on 11/2/17.
//  Copyright © 2017 Steven Suranie. All rights reserved.
//

import Foundation
import RealmSwift

struct AddViewModel {

    let myController = Controller.sharedInstance

    func validateForm(_ dictData: Dictionary<String, Any>, completion: (_ bIsValid: Bool, _ strErrMsg: String)->Void) {

        var bIsValid = true
        var strErrMsg = ""

        if let strTitle = dictData["topicTitle"] as? String {

            if strTitle.isEmpty {
                bIsValid = false
                strErrMsg = strErrMsg + "A topic title is required.\n"
            }
        } else {
            bIsValid = false
            strErrMsg = strErrMsg + "A topic title is required.\n"
        }

        if let strDesc = dictData["topicDesc"] as? String {

            if strDesc.isEmpty {
                bIsValid = false
                strErrMsg = strErrMsg + "A topic description is required.\n"
            }

        } else {
            bIsValid = false
            strErrMsg = strErrMsg + "A topic description is required.\n"
        }

        completion(bIsValid, strErrMsg)

    }

    func createTopic(dictData: Dictionary<String, Any>, completion: (_ bSuccess: Bool, _ topicTitle: CS_Topic, _ strErrMsg: String)->Void) {

        //make local version in realm
        addToRealm(dictData, completion: { (_ bFinished: Bool, _ thisTopic: CS_Topic, _ strErrMsg: String) in
            completion(bFinished, thisTopic, strErrMsg)
        })
    }

    func addToRealm(_ dictData: Dictionary<String, Any>, completion: (_ bFinished: Bool, _ thisTopic: CS_Topic, _ strErrMsg: String)->Void) {

        let newTopic = CS_Topic()
        var bSuccess = true
        var strErrMsg = ""
        
        if let strTitle = dictData["topicTitle"] as? String {
            newTopic.topicTitle = strTitle
        }
        
        if let strDescription = dictData["topicDesc"] as? String {
            newTopic.topicDescription = strDescription
        }
        
        if let bHasImage = dictData["hasImage"] as? Bool {
            newTopic.topicHasImages = bHasImage
        }

        if let thisSubTopic = dictData["subTopic"] as? String {
            newTopic.topicSubTitle = thisSubTopic
        } else {
            bSuccess = false
            strErrMsg = "Could not read subtopic."
        }

//            if let thisSection = dictData["sectionTitle"] as? String {
//                newTopic.topicSection = thisSection
//            } else {
//                bSuccess = false
//                strErrMsg = "Could not read section."
//            }

        //add list of image paths to realm
        if let arrImageObjs = dictData["imageObjs"] as? Array<CS_ImagePath> {

            for thisObj in arrImageObjs {
                thisObj.topicID = newTopic.topicID
                newTopic.topicImagePaths.append(thisObj)
            }

        } else {
            bSuccess = false
            strErrMsg = "Could not get images."
        }

        myController.dataManager.saveRealmObject(newTopic)

        //call back to let know we are done and realm can be validated
        completion(bSuccess, newTopic, strErrMsg)

    }

    func updateTopic(_ dictData: Dictionary<String, Any>, _ thisTopic: CS_Topic, completion: (_ bSuccess: Bool, _ topicTitle: String)->Void) {

        let myRealm = try! Realm()
        try! myRealm.write {

            thisTopic.topicTitle = dictData["topicTitle"] as! String
            thisTopic.topicDescription = dictData["topicDesc"] as! String

            if let thisSubTopic = dictData["subTopic"] as? String {
                thisTopic.topicSubTitle = thisSubTopic
            }

            if let thisSection = dictData["sectionTitle"] as? String {
                thisTopic.topicSection = thisSection
            }

            thisTopic.topicUpdateDt = Date()
            thisTopic.topicLastActiveDt = Date()
        }

        completion(true, thisTopic.topicTitle)
    }

    func createImagePathObject(_ strPath: String, _ strIdentifier: String) -> CS_ImagePath {

        let newPath = CS_ImagePath()

        let myRealm = try! Realm()
        try! myRealm.write {
            newPath.imagePath = strPath
            newPath.imagePHLIdentifier = strIdentifier
        }

        return newPath

    }

}
