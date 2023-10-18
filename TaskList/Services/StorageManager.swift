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
    
    /// Singleton property
    static let shared = StorageManager()
   
    /// DB Container
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
    
    /// DB context
    private var context = StorageManager.persistentContainer.viewContext

    // MARK: - Singleton initializer
    
    private init() {}
    
    // MARK: - Public methods
    
    /// Check context for changes & save
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
    
    // MARK: CRUD methods
    
    /// Save a new task to DB
    func save(_ taskName: String,
              _ completion: (Task) -> Void) {
        let task = Task(context: context)
        task.title = taskName
        saveContext()
        completion(task)
    }
    
    /// Get all tasks from DB
    func fetch() -> [Task] {
        let fetchRequest = Task.fetchRequest()
        do {
            return (try? context.fetch(fetchRequest)) ?? []
        } 
    }
    
    /// Update an existing task
    func update(_ updatedTask: Task,
                with newName: String,
                _ completion: (Task) -> Void) {
        let tasks = fetch()
        guard let task = tasks.first(where: { $0 == updatedTask}) else { return }
        task.title = newName
        saveContext()
        completion(task)
    }
    
    /// Delete a task from DB
    func delete(_ task: Task,
                _ completion: (Task) -> Void) {
        context.delete(task)
        saveContext()
        completion(task)
    }
}
