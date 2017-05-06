//
//  ViewController.swift
//  thomashamburger-pset4
//
//  Created by Thomas Hamburger on 05-05-17.
//  Copyright © 2017 Thomas Hamburger. All rights reserved.
//

import UIKit
import SQLite

class ViewController: UIViewController {

    @IBOutlet weak var createTodo: UITextField!
    
    private var db: Connection?
    
    // TODO: CREËER TABLE VIEW
    
    // The table consist of two columns: id and name.
    let todos = Table("todos")
    let id = Expression<Int64>("id")
    let name = Expression<String>("name")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDatabase()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // INSERT INTO "todos" ("name") VALUES ('Boodschappen')
    @IBAction func storeInDatabase(_ sender: Any) {
        let insert = todos.insert(name <- createTodo.text!)
        
        do {
            let rowId = try db!.run(insert)
            print(rowId)
        } catch {
            print("Error creating todo: \(error)")
        }
    }
    
    // TODO: ZOEKFUCNTIE: Wordt nu nog niet gebruikt
    func searchInDatabase() {
        do {
            for todo in try db!.prepare(todos.filter(name.like("Boodschappen"))) {
            print("id: \(todo[id]), name: \(todo[name])")
            // TODO: Plaats data in table view cells
            }
        } catch {
            // Error handling.
            print("Cannot connect to database: \(error)")
        }
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
