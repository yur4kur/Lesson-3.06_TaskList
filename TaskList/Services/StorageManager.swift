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
    
    // MARK: - Singleton property
    
    static let shared = StorageManager()
    
    // MARK: - Private properties
   
    /// DB Container
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    /// DB context
    private let context: NSManagedObjectContext

    // MARK: - Initializers
    
    /// DB context initializer
    private init() {
        context = persistentContainer.viewContext
    }
    
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
    func fetch(completion: (Result <[Task], Error>) -> Void)  {
        let fetchRequest = Task.fetchRequest()
        
        do {
            let tasks = try context.fetch(fetchRequest)
            completion(.success(tasks))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    /// Update an existing task
    func update(_ updatedTask: Task,
                with newName: String,
                _ completion: (Task) -> Void) {
        updatedTask.title = newName
        saveContext()
        completion(updatedTask)
    }
    
    /// Delete a task from DB
    func delete(_ task: Task,
                _ completion: (Task) -> Void) {
        context.delete(task)
        saveContext()
        completion(task)
    }
}
