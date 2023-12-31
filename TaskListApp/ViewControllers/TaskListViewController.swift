//
//  ViewController.swift
//  TaskListApp
//
//  Created by Vasichko Anna on 29.06.2023.
//

import UIKit

final class TaskListViewController: UITableViewController {
    
    private let cellID = "task"
    private var taskList: [Task] = []
    
    private let storageManager = StorageManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavigationBar()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        fetchTaskList()
    }
    
    @objc private func addNewTask() {
        showAlert(withTitle: "New Task", andMessage: "What would you like to do?")
    }
    
    private func fetchTaskList() {
        storageManager.fetchData { taskList in
            self.taskList = taskList
        }
    }
    
    private func showAlert(withTitle title: String, andMessage message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addTextField()
        alertController.addTextField { textField in
            textField.placeholder = "New Task"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        let saveAction = UIAlertAction(title: "Save Task", style: .default) { [unowned self] _ in
            guard let taskName = alertController.textFields?.first?.text, !taskName.isEmpty else { return }
            
            storageManager.save(taskName) { task in
                taskList.append(task)
                
                tableView.insertRows(
                    at: [IndexPath(row: taskList.count - 1, section: 0)],
                    with: .automatic
                )
            }
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }

}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let task = taskList[indexPath.row]
        
        if editingStyle == .delete {
            storageManager.delete(task: task)
            taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let task = taskList[indexPath.row]
        
        let alertController = UIAlertController(title: "Edit note", message: nil, preferredStyle: .alert)
        
        alertController.addTextField()
        alertController.textFields?.first?.text = task.title
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let editAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
            guard let newValue = alertController.textFields?.first?.text else { return }
            
            storageManager.edit(task: task, newValue: newValue)
            
            tableView.reloadRows(
                at: [indexPath],
                with: .automatic)
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(editAction)
        
        present(alertController, animated: true)
    }
}

// MARK: - Setup UI
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = UIColor(named: "MainBlue")
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        navigationController?.navigationBar.tintColor = .white
    }
}

