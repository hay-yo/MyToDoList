//
//  ViewController.swift
//  MyToDoList
//
//  Created by t2023-m0023 on 2024/01/10.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    // 할 일 목록을 저장할 어레이
    var tasks: [NSManagedObject] = []
    
    // Define context as a property of the ViewController - 뭔지 모르는데 이게 있어야 오류가 해결됨. context를 쓰려면 넣어야함
       var context: NSManagedObjectContext {
           return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
       }

    override func viewDidLoad() {
        super.viewDidLoad()
        // 타이틀
        title = "To Do List"
        navigationController?.navigationBar.prefersLargeTitles = true
        // 테이블뷰 셀 등록
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        // 네비게이션 바 우측 상단에 + 버튼 추가
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 코어 데이터에서 할 일 목록을 가져오기
        fetchTasks()
    }
    
    // Method - 할 일 추가
    @objc func addTask() {
        // alert
        let alert = UIAlertController(title: "새로운 할 일", message: "새로운 할 일을 입력하기", preferredStyle: .alert)
        alert.addTextField()
        // addAction 새로운 할 일 입력하고 추가
        alert.addAction(UIAlertAction(title: "추가", style: .default) { [unowned self] action in
            guard let textField = alert.textFields?.first, let taskName = textField.text else { return }
            self.saveTask(name: taskName)
            self.tableView.reloadData()
        })
        // present - alert 나오게 하기
        present(alert, animated: true)
    }
    
    // Method - 할 일을 코어데이터에 저장
    func saveTask(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Task", in: context)!
        let task = NSManagedObject(entity: entity, insertInto: context)
        task.setValue(name, forKey: "name")
        do {
            try context.save()
            tasks.append(task)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    // Method - 코어데이터에서 할 일 목록을 가져오기
    func fetchTasks() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Task")
        do {
            tasks = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    // Method - 테이블뷰에 rows가 몇 줄 필요한지 count하고 return
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    // configure a cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = tasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = task.value(forKey: "name") as? String
        return cell
    }
    

    // Method - 할 일 업데이트(수정)
    func updateTask(at indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        let alert = UIAlertController(title: "할 일 수정", message: "할 일을 수정하기", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = task.value(forKey: "name") as? String
        }
        alert.addAction(UIAlertAction(title: "수정", style: .default) { [unowned self] action in
            guard let textField = alert.textFields?.first, let taskName = textField.text else { return }
            task.setValue(taskName, forKey: "name")
            do {
                try self.context.save()
                self.tableView.reloadData()
            } catch let error as NSError {
                print("Could not update. \(error), \(error.userInfo)")
            }
        })
        present(alert, animated: true)
    }

    // Method - 할 일 지우기
    func deleteTask(at indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        self.context.delete(task)
        tasks.remove(at: indexPath.row)
        do {
            try self.context.save()
            self.tableView.reloadData()
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
    
    
    // 테이블뷰 row 선택
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateTask(at: indexPath)
    }

    
    // 테이블뷰에서 row 삭제
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteTask(at: indexPath)
        }
    }
    
}
