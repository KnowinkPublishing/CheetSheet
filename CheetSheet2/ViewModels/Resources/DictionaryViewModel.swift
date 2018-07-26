//
//  DictionaryViewModel.swift
//  CheetSheet2
//
//  Created by Steven Suranie on 6/28/18.
//  Copyright © 2018 Steven Suranie. All rights reserved.
//

import Foundation

class DictionaryViewModel: NSObject, XMLParserDelegate {

    enum TagType {

        case wav
        case dt
    }

    var myController = Controller.sharedInstance
    var myConfig = csConfig()
    var myXMLParser = XMLParser()
    var xmlSearchWord: String?
    var bAddToEntry = false
    var bIsDefinition = false
    var bIsPOS = false
    var bIsSound = false
    var arrDefinitions = [mw_definition]()
    var strSearchWord: String?
    var strSoundURL: String?
    var strPOS = "noun"

    func makeXMLCall(_ strWordToSearch: String, _ searchOption: Int) {

        strSearchWord = strWordToSearch
        arrDefinitions.removeAll()

        var path = myConfig.dictionaryStudentBaaePath
        var key = myConfig.dictionaryStudentKey
        if searchOption == 1 {
            path = myConfig.dictionaryThesaurusBasePath
            key = myConfig.dictionaryThesaurusKey
        }

        let xmlParams = ["key": key]

        path = path + strWordToSearch

        let myURLComps = myController.apiManager.makeURLComponents("https", myConfig.dictionaryBaseURL, path, xmlParams)

        if let myURL = myURLComps.url {

            xmlSearchWord = myURLComps.url?.lastPathComponent

            let myXMLParser = XMLParser(contentsOf: myURL)
            myXMLParser?.delegate = self

            myXMLParser?.parse()

        }

    }

    // MARK: - XML Parser Delegates
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {

        if elementName == "entry" {

            let bHasSuffix = attributeDict["id"]?.hasSuffix("]")

            if attributeDict["id"] == xmlSearchWord || bHasSuffix! {
                bAddToEntry = true
            } else {
                bAddToEntry = false
            }

        } else if elementName == "wav" {
            bIsSound = true
        } else {
            bIsSound = false
        }

        if bAddToEntry {

            if elementName == "dt" || elementName == "fl" {
                if elementName == "dt" {
                    bIsDefinition = true
                } else if elementName == "fl" {
                    bIsPOS = true
                } else if elementName == "sound" {

                }
            } else {
                bIsDefinition = false
                bIsPOS = false
            }

        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {

        if bAddToEntry {

            if bIsDefinition {

                let strDefinition = string.stripPrefix(":")

                if !strDefinition.isEmpty {

                    var newDefinition = mw_definition()
                    newDefinition.mw_description = strDefinition.capitalizeFirstWordOfSentence(strDefinition)
                    arrDefinitions.append(newDefinition)
                }

            }

            if bIsPOS {
                strPOS = string
            }

            if bIsSound {
                strSoundURL = string
            }

        }

    }

    func parserDidEndDocument(_ parser: XMLParser) {

        var newEntry = dictionaryEntry()

        newEntry.strWord = strSearchWord!
        newEntry.arrDefinitions = arrDefinitions

        if let strURL = strSoundURL {
            newEntry.urlSound = strURL
        }

        NotificationCenter.default.post(name: Notification.Name("dictionaryXMLParsed"), object: nil, userInfo: ["Entry": newEntry])

    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {

        print("XML Failure: ", parseError.localizedDescription)
    }

    func getAudioURL(_ strEndPoint: String) -> URL {

        //check for special prefixes
        var path = myConfig.dictionarySoundBasePath
        if strEndPoint.hasPrefix("gg") {
            path =  path + "gg/"
        } else if strEndPoint.hasPrefix("bix") {
            path = path + "bix/"
        } else {
            let subStrPrefix = strEndPoint.prefix(1)
            let strPrefix = String(subStrPrefix)

            if strPrefix.isNumeric() {
                path = path + "number/"
            } else {
                path = path + strPrefix + "/"
            }
        }

        return URL(string: "https://" + myConfig.dictionarySoundBaseURL + path + strEndPoint)!

    }

}
