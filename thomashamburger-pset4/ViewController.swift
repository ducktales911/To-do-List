//
//  ViewController.swift
//  thomashamburger-pset4
//
//  Created by Thomas Hamburger on 05-05-17.
//  Copyright © 2017 Thomas Hamburger. All rights reserved.
//

import UIKit
import SQLite

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var createTodo: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    private var database: Connection?
    
    // The table consist of two columns: id and name.
    let todos = Table("todos")
    let id = Expression<Int64>("id")
    let name = Expression<String>("name")
    var todosArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDatabase()
        updateTodoArray()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // TODO: ZORGEN DAT INT TER GROTE VAN DE TODO LIST GERETURND WORDT (MISSCHIEN GEWOON "id"?)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todosArray.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
        
    {
        if editingStyle == .delete
        {
            let item = todos.filter(name == todosArray[indexPath.row])
            do {
                try database!.run(item.delete())
                updateTodoArray()
            } catch {
                print("Could not delete todo: \(error)")
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // TODO: INVULLEN MET DATA DIE UIT SEARCH GEHAALD WORDT
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TodoCell
        cell.todoLabel.text = todosArray[indexPath.row]
        return cell
    }

    // INSERT INTO "todos" ("name") VALUES
    @IBAction func storeInDatabase(_ sender: Any) {
        if let text = createTodo.text, !text.isEmpty {
            let insert = todos.insert(name <- text)
            do {
                try database!.run(insert)
                print("ADDED insert: \(text) to SQL")
                updateTodoArray()
            } catch {
            print("Error creating todo: \(error)")
            }
            tableView.reloadData()
            createTodo.text = ""
        }
    }
    
    // TODO: ZOEKFUCNTIE
    func updateTodoArray(){
        todosArray.removeAll()
        do {
            for todo in try database!.prepare(todos) {
                    todosArray.append(todo[name])
                    print(todo[id])
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
                t.column(id, primaryKey: .autoincrement)// "id" INTEGER IN PRIMARY KEY AUTOINCREMENT,
                t.column(name) // "name" TEXT
            })
        } catch {
            print("Failed to create table: \(error)")
        }
    }
}
