//
//  CoreDataManager.swift
//  SpaceX-Launches
//
//  Created by Kristoffer Anger on 2023-08-19.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let instance = CoreDataManager()
    let container: NSPersistentContainer
    let context: NSManagedObjectContext
    
    init() {
        
        let idProperty = NSPropertyDescription()
        idProperty.name = "id"

        let postEntity = NSEntityDescription()
        postEntity.name = "Post"
        postEntity.properties = [idProperty]
        
        let managedObjectModel = NSManagedObjectModel()
        managedObjectModel.entities = [postEntity]
        container = NSPersistentContainer(name: CoreDataManager.containerName, managedObjectModel: managedObjectModel)
        container.loadPersistentStores { description, error in
            if let error {
                print("Error loading Core Data \(error.localizedDescription)")
            }
        }
        context = container.viewContext
    }
    
    // saving
    func save() {
        do {
            try context.save()
        }
        catch let error {
            print("Error saving to Core Data \(error.localizedDescription)")
        }
    }

    // helper methods for storing and updating data
    func fetchOrCreateEntities<Entity, IdentifiableCollection>(ofType type: Entity.Type, matchingData data: IdentifiableCollection, entityUpdate: (Entity, IdentifiableCollection.Element) -> Void) where Entity : NSManagedObject, IdentifiableCollection: Collection, IdentifiableCollection.Element: Identifiable {
        
        for element in data {
            self.fetchOrCreateEntity(id: element.id, ofType: type) { entity in
                entityUpdate(entity, element)
            }
        }
    }
    
    func fetchOrCreateEntity<Entity: NSManagedObject>(id: Any, ofType type: Entity.Type, entityUpdate: (Entity) -> Void) {
        // fetch or create
        if let storedEntity = self.fetchEntity(id: id, ofType: type) {
            // return fetched entity for updating vars
            entityUpdate(storedEntity)
        }
        else {
            // return created entity for setting vars
            entityUpdate(Entity(context: context))
        }
        // save entity
        save()
    }
    
    // helper methods for fetching data
    // make fetch request to get a specific entity
    func fetchEntity<Entity: NSManagedObject>(id: Any, ofType type: Entity.Type) -> Entity? {
        
        let request = NSFetchRequest<Entity>(entityName: type.description())
        request.predicate = NSPredicate(format: "id == %@", "\(id)")
        do {
            let result = try context.fetch(request)
            return result.first
        }
        catch let error {
            print("Error when fetching item of type: \(type.description()) with id: \(id) from Core Data: \(error.localizedDescription)")
            return nil
        }
    }
    
    // make general fetch of a certain type
    func fetchEntities<Entity: NSManagedObject>(ofType type: Entity.Type) -> [Entity] {
        let request = NSFetchRequest<Entity>(entityName: type.description())
        
        do {
            return try context.fetch(request)
        }
        catch let error {
            print("Error when fetching item of type: \(type.description()) from Core Data: \(error.localizedDescription)")
            return []
        }
    }
    
    private static var containerName: String {
        // set data container name to bundle name + "_Data"
        let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String
        return [appName, "Data"].compactMap{ $0 }.joined(separator: "_")
    }
}
