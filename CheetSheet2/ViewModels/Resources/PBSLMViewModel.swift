//
//  PBSLMViewModel.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 6/19/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

struct PBSLMModel {

    typealias PBSLMClosure = (_ bSuccess: Bool, _ arrLesson: Array<pbsLesson>, _ strErrMsg: String) -> Void
    typealias PBSLMSearchValidationClosure = (_ bSuccess: Bool, _ strErrMsg: String) -> Void
    typealias PBSLMMediaURLClosure = (_ bSuccess: Bool, _ mediaURL: URL, _ strErrMsg: String) -> Void

    var myController = Controller.sharedInstance
    var myConfig = csConfig()

    func validateSearchEntries(_ txtSearch: UITextField, _ arrGrades: Array<String>, completion: PBSLMSearchValidationClosure) {

        var bIsValid = true
        var strErrMsg = ""

        if let strText = txtSearch.text {
            if strText.isEmpty {
                bIsValid = false
                strErrMsg = strErrMsg + "You must enter something to search for.\n"
            }
        } else {
            bIsValid = false
            strErrMsg = strErrMsg + "You must enter something to search for.\n"
        }

        if arrGrades.count == 0 {
            bIsValid = false
            strErrMsg = strErrMsg + "You must select a grade to search by."
        }

        completion(bIsValid, strErrMsg)
    }

    func getSearchResults(_ strToSearch: String, _ arrGrades: Array<String>, completion:@escaping PBSLMClosure) {

        var dictParams: Dictionary<String, String> = [:]
        dictParams["q"] = strToSearch

        for strGrade in arrGrades {
            let strSuffix = String(strGrade.suffix(2))
            dictParams["selected_facet"] = "grades:\(strGrade.stripSuffix(strSuffixToStrip: strSuffix))"
        }
        
        let myURLComponents = myController.apiManager.makeURLComponents("https", myConfig.pbsLearningBaseURL, myConfig.pbsLearningBasePath, dictParams)
        
        if let myURL = myURLComponents.url {
            
            Alamofire.request(myURL).responseJSON(completionHandler: { response in
                
                if let dictJSON = response.result.value as? Dictionary<String, Any> {
                    
                    var arrLessons = [pbsLesson]()
                    let decoder = JSONDecoder()
                    
                    if let arrObjects = dictJSON["objects"] as? Array<Dictionary<String, Any>> {
                        for dictThisLesson in arrObjects {
                            let lessonData = try! JSONSerialization.data(withJSONObject: dictThisLesson, options: .prettyPrinted)
                            let thisLesson = try! decoder.decode(pbsLesson.self, from: lessonData)
                            arrLessons.append(thisLesson)
                        }
                    }
                    
                    completion(true, arrLessons, "")
                   
                } else {
                    completion(false, [], "There was a problem with the JSON request.")
                }
                
            })
            
        }
        
        /*
        myController.apiManager.makeJSONCall("https", myConfig.pbsLearningBaseURL, myConfig.pbsLearningBasePath, dictParams, [:], [:], completion: { (bSuccess, dictJSON, _, _) in

            if bSuccess {
                var arrLessons = [pbsLesson]()
                //completion(bSuccess, jsonData, strMsg)
                let decoder = JSONDecoder()
                if let arrObjects = dictJSON["objects"] as? Array<Dictionary<String, Any>> {
                    for dictThisLesson in arrObjects {
                        let lessonData = try! JSONSerialization.data(withJSONObject: dictThisLesson, options: .prettyPrinted)
                        let thisLesson = try! decoder.decode(pbsLesson.self, from: lessonData)
                        arrLessons.append(thisLesson)
                    }
                }

                completion(true, arrLessons, "")

            } else {

                completion(false, [], "There was a problem parsing the JSON data.")
            }
        })
         */

    }

    func getMediaURL(_ scheme: String, _ host: String, _ path: String, _ params: Array<URLQueryItem>, completition:@escaping PBSLMMediaURLClosure) {
        
        myController.apiManager.makeJSONCall(scheme, host, path, [:], [:], [:], completion: { (bSuccess, dictJSON, _, _) in

            if bSuccess {
                if let urlString = dictJSON["canonical_url"] as? String {

                    if let mediaURL = URL(string: urlString) {

                        completition(true, mediaURL, "")
                    } else {
                        let failURL = URL(string: "fail")
                        completition(false, failURL!, "There was an error with the selected media url.")
                    }

                }

                let failURL = URL(string: "fail")
                completition(false, failURL!, "There was an error with the data returned for the selected media.")

            }
        })
        
    }

}
