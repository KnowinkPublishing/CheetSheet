//
//  ResourceViewModel.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 5/24/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import Foundation

struct ResourceModel {

    typealias ResourceClosure = (_ bSuccess: Bool, _ arrData: Array<Any>, _ strErrMsg: String) -> Void
    typealias KhanDisplayClosure = (_ bSuccess: Bool, _ arrData: Array<Dictionary<String, Any>>, _ strErrMsg: String) -> Void

    var myController = Controller.sharedInstance
    var myConfig = csConfig()

    var arrResources = [["id": 0, "name": "Khan", "type": "api", "baseURL": "www.khanacademy.org", "mainPath": "/api/v1/topic/", "needsLabel": false, "topLevelSubs": [["subtopic": "math", "path": "/api/v1/topic/math", "display": "Math", "kind": "topic"], ["subtopic": "science", "path": "/api/v1/topic/science", "display": "Science", "kind": "topic"], ["subtopic": "economics-finance-domain", "path": "/api/v1/topic/economics-finance-domain", "display": "Economics/Finance", "kind": "topic"], ["subtopic": "humanities", "path": "/api/v1/topic/humanities", "display": "Humanities", "kind": "topic"], ["subtopic": "computing", "path": "/api/v1/topic/computing", "display": "Computing", "kind": "topic"]]], ["id": 1, "name": "Quizlet", "type": "api", "baseURL": "https://api.quizlet.com/", "mainPath": "/2.0/", "needsLabel": true, "topLevelSubs": []], ["id": 2, "name": "pbslm", "type": "api", "baseURL": "", "mainPath": "", "needsLabel": false, "topLevelSubs": []], ["id": 3, "name": "dictionary", "type": "api", "baseURL": "", "mainPath": "", "needsLabel": false, "topLevelSubs": []], ["id": 4, "name": "newton", "type": "api", "baseURL": "", "mainPath": "", "needsLabel": false, "topLevelSubs": []], ["id": 5, "name": "loc", "type": "api", "baseURL": "", "mainPath": "", "needsLabel": false, "topLevelSubs": []]]

    //mendeley  ["id":2, "name":"mendeley", "type":"api", "baseURL":"api.mendeley.com", "mainPath":"/subject_areas", "needsLabel":false, "topLevelSubs":[]]

    //

    func retrieveResource(_ dictData: Dictionary<String, Any>, completion: ResourceClosure) {

        switch dictData["id"] as? Int {
        case 0:
            displayKhanTopics(dictData, completion: {(bSuccess, arrData, strErrMsg) in
                if bSuccess {
                    myConfig.arrOriginalData = arrData
                    completion(true, arrData, "")
                } else {
                    completion(false, [], strErrMsg)
                }
            })

        case 1:
            print(dictData)
        default:
            print("nothing to do")
        }
    }

    private func displayKhanTopics(_ dictData: Dictionary<String, Any>, completion: KhanDisplayClosure) {
        if let arrTopLevelSubs = dictData["topLevelSubs"] as? Array<Dictionary<String, Any>> {
            completion(true, arrTopLevelSubs, "")
        } else {
            completion(false, [], "There was a problem retrieving the main topics for Khan Academy.")
        }
    }

    private func retrieveKhanTopics(_ dictData: Dictionary<String, Any>) {

        if let dictPath = dictData["paths"] as? Dictionary<String, Any>, let baseURL = dictData["baseURL"] as? String, let strPath = dictPath["topictree"] as? String {
            myController.apiManager.makeJSONCall("http", baseURL, strPath, [:], [:], [:], completion: {(bSuccess, _, _, _) in
                print(bSuccess)
            })
        } else {
            print("Something went wrong")
        }

    }
}
