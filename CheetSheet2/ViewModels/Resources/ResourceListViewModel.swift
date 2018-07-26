//
//  ResourceListViewModel.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 5/24/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import Foundation

struct ResourceListModel {

    typealias KhanAPIClosure = (_ bSuccess: Bool, _ dictJSON: Dictionary<String, Any>, _ strErrMsg: String, _ strPath: String) -> Void
    typealias KhanParseClosure = (_ bSuccess: Bool, _ arrResults: Array<Dictionary<String, Any>>, _ strErrMsg: String) -> Void

    var myController = Controller.sharedInstance
    var myConfig = csConfig()

    func retrieveKhanAPI(_ scheme: String, _ host: String, _ path: String, completion:@escaping KhanAPIClosure) {

        myController.apiManager.makeJSONCall(scheme, host, path, [:], [:], [:], completion: {(bSuccess, dictJSON, _, _) in
            if bSuccess {
                completion(true, dictJSON, "", path)
            } else {
                completion(false, [:], "There was an error retrieving the JSON from Khan Academy", path)
            }
        })
    }

    func parseJSON(_ dictJSON: Dictionary<String, Any>, completion: KhanParseClosure) {

        var arrResults: Array<Dictionary<String, Any>> = []
        if let arrChildren = dictJSON["children"] as? Array<Any> {

            for thisChild in arrChildren {

                if let dictChild = thisChild as? Dictionary<String, Any> {

                    let strKind = dictChild["kind"] as? String ?? ""
                    let strNodeSlug = dictChild["node_slug"] as? String ?? ""
                    let strDescription = dictChild["description"] as? String ?? ""
                    let strDisplay = dictChild["title"] as? String ?? ""
                    let strPath = myConfig.khanMainPath + strNodeSlug
                    let strURL = dictChild["url"] as? String ?? ""
                    let strIconURL = dictChild["icon_large"] as? String ?? ""

                    let dictThisChild = [
                        "kind": strKind.lowercased(),
                        "node_slug": strNodeSlug,
                        "description": strDescription,
                        "display": strDisplay,
                        "path": strPath,
                        "url": strURL,
                        "iconURL": strIconURL
                    ]

                    arrResults.append(dictThisChild)
                }
            }

            completion(true, arrResults, "")

        } else {

            completion(false, [], "There was an error retrieving the subtopics from Khan Academy.")
        }
    }
}
