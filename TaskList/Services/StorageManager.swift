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
    func save(_ taskName: String,
              _ completion: (Task) -> Void) {
        let task = Task(context: context)
        task.title = taskName
        saveContext()
        completion(task)
    }
    
    func fetch() -> [Task] {
        let fetchRequest = Task.fetchRequest()
        do {
            return (try? context.fetch(fetchRequest)) ?? []
        } 
    }
    
    func update(_ updatedTask: Task,
                with newName: String,
                _ completion: (Task) -> Void) {
        let tasks = fetch()
        guard let task = tasks.first(where: { $0 == updatedTask}) else { return }
        task.title = newName
        saveContext()
        completion(task)
    }
    
    func delete(_ task: Task,
                _ completion: (Task) -> Void) {
        context.delete(task)
        saveContext()
        completion(task)
    }
}
