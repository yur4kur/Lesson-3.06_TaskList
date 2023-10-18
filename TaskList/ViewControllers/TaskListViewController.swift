//
//  ViewController.swift
//  TaskList
//
//  Created by Alexey Efimov on 02.04.2023.
//

import UIKit
import CoreData

// MARK: - TaskListViewController

final class TaskListViewController: UITableViewController {
    
    // MARK: - Private properties
    
    private let cellID = Constants.cellID
    private var taskList: [Task] = []

    // MARK: Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Private methods

    /// Show alert for adding a task
    private func addNewTask() {
        showAlert(withTitle: Constants.newTaskAlertTitle,
                  andMessage: Constants.newTaskAlertMessage)
    }
    
    /// Show alert for changing a task
    private func updateTask(_ task: Task) {
        showAlert(withTitle: Constants.updateTaskAlertTitle,
                  andMessage: Constants.updateTaskAlertMessage,
                  task: task)
    }
    
    // MARK: TaskList CRUD methods
    
    /// Save a task to DB and add it to the list
    private func save(_ taskName: String) {
        StorageManager.shared.save(taskName) { task in
            taskList.append(task)
        }
        
        let indexPath = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    /// Get tasks from DB
    private func fetchData() {
        taskList = StorageManager.shared.fetch()
    }
    
    /// Update a task in DB as well as in the list
    private func update(oldTask: Task, with newTaskName: String)  {
        StorageManager.shared.update(oldTask, with: newTaskName) { task in
            if let index = taskList.firstIndex(of: oldTask) {
            taskList[index] = task
            }
        }
        tableView.reloadData()
    }
    
    /// Delete task from DB and also from the list
    private func delete(_ task: Task, index: Int) {
        StorageManager.shared.delete(task) { task in
            taskList.remove(at: index)
        }
    }
}

// MARK: - UITableViewDataSource

extension TaskListViewController {
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID,
                                                 for: indexPath)
        let task = taskList[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        cell.selectionStyle = .none
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TaskListViewController {
    
    // MARK: Update task in a row
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        let task = taskList[indexPath.row]
        updateTask(task)
    }
    
    // MARK: Delete task and row
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deletedTask = taskList[indexPath.row]
            delete(deletedTask, index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - Setting View

private extension TaskListViewController {
    
    func setupUI() {
        
        setupView()
        
        setupNavigationBar()
        
        setupTableView()
        
        fetchData()
    }
}

// MARK: - Setting elements
private extension TaskListViewController {
    
    // MARK: Configure view
    
    func setupView() {
        view.backgroundColor = .white
    }
    
    // MARK: Configure Navigation Bar
    
    func setupNavigationBar() {
        
        title = Constants.navBarTitle
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = UIColor(named: Constants.navBarColor)
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .add,
            primaryAction: UIAction { [unowned self] _ in
                addNewTask()
            }
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    // MARK: Configure TableView
    
    func setupTableView() {
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: cellID)
    }
}

// MARK: - AlertContoroller

private extension TaskListViewController {
    
    func showAlert(withTitle title: String,
                   andMessage message: String,
                   task: Task? = nil) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: Constants.alertSaveButtonTitle,
                                       style: .default) { [weak self] _ in
            guard let newTask = alert.textFields?.first?.text, !newTask.isEmpty else { return }
            if let task = task {
                self?.update(oldTask: task, with: newTask)
            } else {
                self?.save(newTask)
            }
        }
        
        let cancelAction = UIAlertAction(title: Constants.alertCancelButtonTitle,
                                         style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            if task != nil {
                textField.text = task?.title
            } else {
                textField.placeholder = Constants.alertPlaceholderText
            }
        }
        
        present(alert, animated: true)
    }
}

// MARK: - Constants

private extension TaskListViewController {
    
    enum Constants {
        
        /// TableView Cell
        static let cellID = "task"
        
        /// New Task Alert
        static let newTaskAlertTitle = "New Task"
        static let newTaskAlertMessage = "What do you want to do?"
        
        /// Update Task Alert
        static let updateTaskAlertTitle = "Update Task"
        static let updateTaskAlertMessage = "What do you want to change?"
        
        /// Navigation Bar
        static let navBarTitle = "Task List"
        static let navBarColor = "MilkBlue"
        
        /// Alert Controller Elements
        static let alertSaveButtonTitle = "Save"
        static let alertCancelButtonTitle = "Cancel"
        static let alertPlaceholderText = "New Task"
    }
}


