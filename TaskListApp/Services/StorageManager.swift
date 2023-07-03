//
//  StorageManager.swift
//  TaskListApp
//
//  Created by Egor Kruglov on 30.06.2023.
//

import CoreData

final class StorageManager {
    static let shared = StorageManager()
    
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
    
    private init() {}
    
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
        
        completion(task)
        
        saveContext()
    }
    
    func edit(task: Task, newValue: String) {
        task.setValue(newValue, forKey: "title")
        saveContext()
        
    }
    
    func delete(task: Task) {
        viewContext.delete(task)
        saveContext()
    }
}
