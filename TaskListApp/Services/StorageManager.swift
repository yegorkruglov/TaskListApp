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
    
    lazy var viewContext = persistentContainer.viewContext
    
    func saveContext () {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func fetchData(completion: ([Task]) -> Void) {
        let fetchRequest = Task.fetchRequest()
        
        do {
           let taskList = try viewContext.fetch(fetchRequest)
            completion(taskList)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func save(_ taskName: String, completion: (Task) -> Void) {
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
    
    func edit(oldValue: String, newValue: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "title = %@", oldValue)
        
        let results = try? viewContext.fetch(fetchRequest) as? [NSManagedObject]
        
        results?.first?.setValue(newValue, forKey: "title")
        
        do {
            try viewContext.save()
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    func delete(task: Task) {
        viewContext.delete(task)
        
        do {
            try viewContext.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
