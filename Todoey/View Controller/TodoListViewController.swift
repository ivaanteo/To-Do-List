//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import ChameleonFramework

class TodoListViewController: SwipeTableViewController{
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    let realm = try! Realm()
    var todoItems : Results<Item>?
//    let defaults = UserDefaults.standard
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedCategory : Category? {
        didSet{
            loadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
//        loadData()
    }


//MARK: - Table View Data Source Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = todoItems?.count ?? 1
        if count == 0{
            count = 1
        }
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        let count = todoItems?.count ?? 1
            if count != 0{
                cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row]{
            cell?.textLabel?.text = item.title
            cell?.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: UIColor(hexString: item.color) ?? FlatGreen(), isFlat: true)
            cell?.accessoryType = item.done ? .checkmark : .none
            cell?.backgroundColor = UIColor(hexString: item.color)
            }}else{
                cell?.textLabel?.text = "No items added"
            tableView.allowsSelection = false
        }
        
        return cell!
    }

//MARK: - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row]{
            do{
                try realm.write{
                    item.done = !item.done
                }
            }catch{
                print(error.localizedDescription)
            }
        }
        tableView.reloadData()
//        itemArray?[indexPath.row].done = !itemArray[indexPath.row].done
//        self.saveData()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
//MARK: - Add New Items

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (UIAlertAction) in
            //what will happen once user clicks add button
            if let currentCategory = self.selectedCategory{
                do{
                    try self.realm.write{
                        let newItem = Item()
                        newItem.done = false
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        newItem.color = UIColor.randomFlat().hexValue()
                        currentCategory.items.append(newItem)
                        self.realm.add(newItem)
                    }
                }catch{
                    print(error.localizedDescription)
                }
                self.tableView.reloadData()
            }
            
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }


    func loadData(){
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }

    override func updateModel(at indexPath: IndexPath) {
        if let itemToDelete = todoItems?[indexPath.row]{
            do{
                try realm.write{
                    realm.delete(itemToDelete)
                }
            }catch{
                print(error.localizedDescription)
            }
        }
        tableView.reloadData()
    }
    
}

//MARK: - UI Search Bar Delegate Methods
extension TodoListViewController : UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
