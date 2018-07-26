//
//  SearchCache.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 7/1/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import Foundation

struct SearchCache {

    func cacheThisSearch(_ arrTerms: String, _ dictJSON: String, _ xmlResults: String, _ dtSearch: Date, _ resourceType: ResourceSourceType) {

        let thisSearchObject = CheetSheetSearch()
        thisSearchObject.strTerms = arrTerms
        thisSearchObject.strJSON = dictJSON
        thisSearchObject.xmlResult = xmlResults
        thisSearchObject.dtSearch = dtSearch
        thisSearchObject.resourceType = resourceType.rawValue

        //save the search

    }
}
