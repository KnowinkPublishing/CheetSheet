//
//  DataManager.swift
//  iOSInterviewCheatSheet
//
//  Created by Steven Suranie on 11/2/17.
//  Copyright © 2017 Steven Suranie. All rights reserved.
//
enum DataTypes {
    case storedTopicType, sequenceType, sectionType
}

import Foundation
import UIKit
import CoreData
import RealmSwift

struct DataManager {

    func deleteFromRealm(_ objToDelete: Object) {

        let myRealm = try! Realm()
        try? myRealm.write {
            myRealm.delete(objToDelete)
        }

        //let arrResults = myRealm.objects(CS_User.self)
        //print(arrResults)
    }

    func checkRealmSchema() {

        let config = Realm.Configuration(
            schemaVersion: 1,

            migrationBlock: { migration, oldSchemaVersion in

                if oldSchemaVersion < 1 {
                    migration.enumerateObjects(ofType: CS_Topic.className()) { _, newObject in
                        newObject
                    }
                }
            }
        )

        Realm.Configuration.defaultConfiguration = config
    }

    func saveRealmObject(_ objToSave: Object) {

        let myRealm = try! Realm()
        try? myRealm.write {
            myRealm.add(objToSave)
        }

    }

    func checkForDuplicateSearch(_ searchObj: CheetSheetSearch) -> Bool {

        let myRealm = try! Realm()
        let listObjects = myRealm.objects(CheetSheetSearch.self)
        var bMakeObj = true

        if listObjects.count > 0 {

            let myFilter = NSPredicate(format: "strTerms = '\(searchObj.strTerms)' AND grade = '\(searchObj.grade)' AND resourceType = '\(searchObj.resourceType)'")
            let arrMatches = listObjects.filter(myFilter)

            if arrMatches.count > 0 {
                bMakeObj = false
            }
        }

        return bMakeObj
    }

    /*
    func storeData (_ dictData: Dictionary<String, Any>, _ entityName:String) -> Bool  {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return false
        }
        
        let moc = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: entityName,
                                                in: moc)!
        
        let cdObj = NSManagedObject(entity: entity,
                                          insertInto: moc)
        
        for (key, value) in dictData {
            cdObj.setValue(value, forKeyPath: key)
        }
        
        
        
        do {
            try moc.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return false
        }
        
        return true
        
    }
    */

    /*
    func validateSave <T: NSManagedObject>(_ entityName:String, _ theUUID:String, _ entity: T.Type) -> Bool {
        
        let arrData = fetchCoreData(entityName, nil, entity)
        
        let arrResults = arrData.filter { $0.topicID == theUUID }
        if arrResults.count > 0 {
            return true
        }
        
        
        return false
        
    }
     */

    /*
    func deleteObject<T: NSManagedObject>(_ entity: T.Type, _ objID:String, _ attributeName:String, _ dataType:DataTypes) -> Bool {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return false
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        if let arrData = fetchCoreData(entity, nil) {
            
            _ = arrData.map {
                
                if dataType == .storedTopicType {
                    
                    let thisStoredTopic = $0 as! StoredTopic
                    if thisStoredTopic.topicID == objID {
                        managedContext.delete(thisStoredTopic)
                    }
                }
            }
        }
            
        do {
            try managedContext.save()
        } catch {
            assert(false, error.localizedDescription)
        }
        return true
    }
    */

    func fetchCoreData <T: NSManagedObject>(_ entity: T.Type, _ predicate: NSPredicate?) -> [T]? {

        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return []
        }

        var results: [T]?

        //let fetchRequest = NSFetchRequest<StoredTopic>(entityName: entityName)
        //let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: managedContext)
        //fetchRequest.entity = entityDescription
        /*
        
         */

        let managedContext = appDelegate.persistentContainer.viewContext

        if let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as? NSFetchRequest<T> {

            if let thisPredicate = predicate {
                fetchRequest.predicate = thisPredicate
            }

            /*
            let sort = NSSortDescriptor(key: "dtCreate", ascending: false)
            fetchRequest.sortDescriptors = [sort]
            */

            do {
                results = try managedContext.fetch(fetchRequest)
            } catch {
                assert(false, error.localizedDescription)
            }
        } else {
            assert(false, "Error: cast to NSFetchRequest<T> failed")
        }

            return results
    }

}
