//
//  StorageManager.swift
//  TaskList
//
//  Created by Юрий Куринной on 16.10.2023.
//

import Foundation
import CoreData

// MARK: - Storage Manager
final class StorageManager {
    
    // MARK: - Static properties
    static let shared = StorageManager()
   
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Private properties
    private var context = StorageManager.persistentContainer.viewContext

    // MARK: - Singleton initializer
    private init() {}
    
    // MARK: - Public methods
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: CRUD
    func save(_ taskName: String) {
        let task = Task(context: context)
        task.title = taskName
        saveContext()
    }
    
    func fetch() -> [Task] {
        var taskList: [Task] = []
        let fetchRequest = Task.fetchRequest()
        
        do {
            taskList = try context.fetch(fetchRequest)
        } catch {
            print(error)
        }
        return taskList
    }
}
