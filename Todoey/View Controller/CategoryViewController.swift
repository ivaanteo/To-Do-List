//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Ivan Teo on 25/6/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
//import SwipeCellKit

class CategoryViewController: SwipeTableViewController {
    let realm = try! Realm()
    
    var categoryArray : Results<Category>?
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
        tableView.rowHeight = 80.0
    }
    @IBAction func barButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let action = UIAlertAction(title: "Add category", style: .default) { (UIAlertAction) in
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat().hexValue()
            self.save(category: newCategory)
        }


        let alert = UIAlertController(title: "Add new category", message: "Enter the title of the category", preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Type the category here"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }


    // MARK: - Table View Data Source Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = categoryArray?.count ?? 1
        if count == 0{
            count = 1
        }
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        let count = categoryArray?.count ?? 1
        if count != 0{
            cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let categoryAtRow = categoryArray?[indexPath.item] {
            cell?.textLabel?.text = categoryAtRow.name
            cell?.backgroundColor = UIColor(hexString: categoryAtRow.color)
            cell?.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: UIColor(hexString: categoryAtRow.color) ?? FlatGreen(), isFlat: true)
            }}
        else{
            cell?.textLabel?.text = "No Categories added yet"
            tableView.allowsSelection = false
        }
        return cell!
    }

    //MARK: - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }

    //MARK: - Data Manipulation Methods
    func save(category: Category){
        do{
            try realm.write{
                realm.add(category)
            }
        }catch{
            print(error.localizedDescription)
        }
        self.tableView.reloadData()
    }

    func loadCategory(){
        categoryArray = realm.objects(Category.self)
        self.tableView.reloadData()
    }
    override func updateModel(at indexPath: IndexPath){
        if let categoryToDelete = self.categoryArray?[indexPath.row]{
            do{
                try self.realm.write{
                    self.realm.delete(categoryToDelete)
                }
            }catch{
                print(error.localizedDescription)
            }
        }
        tableView.reloadData()
    }
    
}

//MARK: - Swipe Table View Delegate Methods
