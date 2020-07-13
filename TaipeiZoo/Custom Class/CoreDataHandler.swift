//
//  CoreDataHandler.swift
//  TaipeiZoo
//
//  Created by Finn on 2020/6/17.
//  Copyright © 2020 Finn. All rights reserved.
//

import UIKit
import CoreData

class CoreDataHandler {
    
    var context: NSManagedObjectContext! = nil
    private let favoriteEntityName = "Favorite"
    
    // MARK: - Initialize
    
    init(context:NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Handle Function
    
    // Insert
    func insertFavorite(chName: String?,
                        imgData: Data?,
                        speciesData: Data?,
                        isAnimal: Bool) -> Bool {
        
        guard let okData    = speciesData,
              let okChName  = chName else { return false }
        
        let insertData = NSEntityDescription.insertNewObject(forEntityName: favoriteEntityName,
                                                             into: context)
                
        insertData.setValue(okChName, forKey: "chName")
        insertData.setValue(okData,   forKey: "speciesData")
        insertData.setValue(isAnimal, forKey: "isAnimal")
        insertData.setValue(NSDate(timeIntervalSinceNow: 0), forKey: "addTime")
        
        if let okImgData = imgData {
            insertData.setValue(okImgData, forKey: "imgData")
        }
        
        do {
            try context.save()
            return true
        } catch {
            fatalError("Insert favorite error \(error)")
        }
    }
    
    // Fetch
    func fetchFavorite(predicateString: String?) -> [NSManagedObject]? {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: favoriteEntityName)
        
        if let okPredicate = predicateString {
            request.predicate = NSPredicate(format: okPredicate)
        }
        
        request.sortDescriptors = [NSSortDescriptor(key: "addTime", ascending: false)]

        do {
            return try context.fetch(request) as? [NSManagedObject]
        } catch {
            fatalError("get Favorite error \(error)")
        }
    }

    // Delete
    func deleteFavorite(chName: String?) -> Bool {
        
        if  let okChName = chName,
            let filter = fetchFavorite(predicateString: "chName == '\(okChName)'") {

            for fav in filter {
                context.delete(fav)
            }
            
            do {
                try context.save()
                return true
            } catch {
                fatalError("Delete favorite error \(error)")
            }
        }
        return false
    }
    
    // Check
    func isContain(chName: String?) -> Bool {
        
        if let okChName = chName,
           let filter = fetchFavorite(predicateString: "chName == '\(okChName)'") {
            return !filter.isEmpty
        }
        return false
    }
}
