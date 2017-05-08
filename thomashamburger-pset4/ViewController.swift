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
    
    private var db: Connection?
    
    // The table consist of two columns: id and name.
    let todos = Table("todos")
    let id = Expression<Int64>("id")
    let name = Expression<String>("name")
    var todosArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDatabase()
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
              todosArray[indexPath.row] = ""
//            let normalInt = indexPath.row
//            let sixfourInt = Int64(normalInt)
//            let todo = todos.filter(id == sixfourInt)
//            do {
//                try db?.run(todo.delete())
//            } catch {
//                print("could not delete todo")
//            }
            tableView.reloadData()
        }
    }

    // TODO: INVULLEN MET DATA DIE UIT SEARCH GEHAALD WORDT
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TodoCell
        let todoEntry = todosArray[indexPath.row]
        cell.todoLabel.text = todoEntry
        return cell
    }

    // INSERT INTO "todos" ("name") VALUES
    @IBAction func storeInDatabase(_ sender: Any) {
        if let text = createTodo.text, !text.isEmpty {
            // let insert = todos.insert(name <- text)
            //do {
                // let rowId = try db!.run(insert)
                // print(rowId)
                todosArray.append(text)
                tableView.reloadData()
           // } catch {
            //    print("Error creating todo: \(error)")
            //}
        }
    }
    
    // TODO: ZOEKFUCNTIE
    func searchInDatabase(normalInt: Int) -> String {
        let sixfourInt = Int64(normalInt)
        var todoString = ""
        do {
            for todo in try db!.prepare(todos.filter(id == sixfourInt)) {
            print("id: \(todo[id]), name: \(todo[name])")
            todoString = todo[name]
            // TODO: Plaats data in table view cells
            }
        } catch {
            // Error handling.
            print("Cannot connect to database: \(error)")
            todoString = "hai"
        }
        return todoString
    }
    
    private func setupDatabase() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        do {
            db = try Connection("\(path)/db.sqlite3")
            createTable()
        } catch {
            // Error handling here.
            print("Cannot connect to database: \(error)")
        }
    }

    private func createTable() {    
        do {
            try db!.run(todos.create(ifNotExists: true) { t in // CREATE TABLE "todos"
                
                t.column(id, primaryKey: .autoincrement)// "id" INTEGER IN PRIMARY KEY AUTOINCREMENT,
                t.column(name) // "name" TEXT UNIQUE NOT NULL
            })
        } catch {
            print("Failed to create table: \(error)")
        }
    }
}
