//
//  StorageManager.swift
//  TaskListApp
//
//  Created by Egor Kruglov on 30.06.2023.
//

import CoreData

final class StorageManager {
    static let shared = StorageManager()
    
    private init() {}
    
    private let persistentContainer: NSPersistentContainer = {
    
        let container = NSPersistentContainer(name: "TaskListApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func fetchData(completion: ([Task]) -> Void) {
        let viewContext = persistentContainer.viewContext
        
        let fetchRequest = Task.fetchRequest()
        
        do {
           let taskList = try viewContext.fetch(fetchRequest)
            completion(taskList)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func save(_ taskName: String, completion: (Task) -> Void) {
        let viewContext = persistentContainer.viewContext
        
        let task = Task(context: viewContext)
        task.title = taskName
        
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                completion(task)
            } catch {
                print(error)
            }
        }
    }
    
    func delete(task: Task) {
        let viewContext = persistentContainer.viewContext
        
        viewContext.delete(task)
        
        do {
            try viewContext.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
