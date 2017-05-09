//
//  ViewController.swift
//  thomashamburger-pset4
//
//  Created by Thomas Hamburger on 05-05-17.
//  Copyright © 2017 Thomas Hamburger. All rights reserved.
//
//
//
//

import UIKit
import SQLite

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var createTodo: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    private var database: Connection?
    
    // The table consist of three columns: id, name and checkedOff.
    let todos = Table("todos")
    let id = Expression<Int64>("id")
    let name = Expression<String>("name")
    let checkedOff = Expression<Bool>("checkedOff")
    
    var todosArray = [(id: Int64, text: String, done: Bool)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDatabase()
        updateTodoArray()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return todosArray.count }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return true }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
        
    {
        if editingStyle == .delete
        {
            let item = todos.filter(id == todosArray[indexPath.row].id)
            do {
                try database!.run(item.delete())
                updateTodoArray()
            } catch {
                print("Could not delete todo: \(error)")
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TodoCell
            cell.todoLabel.text = todosArray[indexPath.row].text
            if(todosArray[indexPath.row].done == true) {
                cell.accessoryType = .checkmark
            }
            else {
                cell.accessoryType = .none
            }
        return cell
    }
    
    // Handles the checkmarks
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let todoID = todosArray[indexPath.row].id
        let checkThisOff = todos.filter(id == todoID)
        do {
            if try database!.run(checkThisOff.update(checkedOff <- !checkedOff)) > 0 {
                print("Todo checked off")
            } else {
                print("Todo to check off not found")
            }
        } catch {
            print("update failed: \(error)")
        }
        updateTodoArray()
        tableView.reloadData()
    }

    // INSERT INTO "todos" ("name") VALUES
    @IBAction func storeInDatabase(_ sender: Any) {
        if let text = createTodo.text, !text.isEmpty {
            let insert = todos.insert(name <- text, checkedOff <- false)
            do {
                try database!.run(insert)
                updateTodoArray()
            } catch {
            print("Error creating todo: \(error)")
            }
            tableView.reloadData()
            createTodo.text = ""
        }
    }
    
    // Recreates the array used to store todos from the data in the database.
    func updateTodoArray(){
        todosArray.removeAll()
        do {
            for todo in try database!.prepare(todos) {
                todosArray.append((todo[id], todo[name], todo[checkedOff]))
            }
        } catch {
            // Error handling.
            print("Cannot connect to database: \(error)")
        }
    }
    
    private func setupDatabase() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        do {
            database = try Connection("\(path)/db.sqlite3")
            createTable()
        } catch {
            // Error handling here.
            print("Cannot connect to database: \(error)")
        }
    }

    private func createTable() {    
        do {
            try database!.run(todos.create(ifNotExists: true) { t in // CREATE TABLE "todos"
                t.column(id, primaryKey: .autoincrement)// "id" INTEGER // primaryKey: .autoincrement
                t.column(name) // "name" STRING
                t.column(checkedOff) // "checkedOff" BOOLEAN
            })
        } catch {
            print("Failed to create table: \(error)")
        }
    }
}
