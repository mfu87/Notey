//
//  NewFolderViewController.swift
//  Notey
//
//  Created by Marcus Fuchs on 29.07.19.
//  Copyright © 2019 Marcus Fuchs. All rights reserved.
//

import UIKit
import CoreData

class FolderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
//MARK:_______________GLOBAL VARIABLES_______________
    
    var folderArray = [Folder]()
    
    var memosToDelete = [Memo]()
    
    var selectedFolder: Folder?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var folderTableView: UITableView!
    
    
    override func viewDidLoad() {
        loadFolders()
        super.viewDidLoad()
    }
    
    
//MARK:_______________TABLEVIEW DELEGATE METHODS_______________
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folderArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath)
        
        cell.textLabel?.text = folderArray[indexPath.row].folderName
        
        return cell
    }
    
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var tappedCellIndex = tableView.indexPathForSelectedRow
        selectedFolder = folderArray[tappedCellIndex!.row]
        performSegue(withIdentifier: "showMemos", sender: self)
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {

            selectedFolder = folderArray[indexPath.row]
            //delete connencted Memos in that folder
            //push all Memos to delete in memosToDelete-Array
            //Delete them + save...
            deleteMemosInFolder()
            saveMemo()

            
            context.delete(folderArray[indexPath.row])
            saveFolders()
            loadFolders()
            tableView.reloadData()
            
            
           
            
        }
    }

    

//MARK:________________DATA MANIPULATION METHODS________________
    
    @IBAction func addFolderTapped(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Create New Folder", message: "", preferredStyle: .alert)
        var textField = UITextField()
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newFolder = Folder(context: self.context)
            newFolder.folderName = textField.text
            self.folderArray.append(newFolder)
            self.selectedFolder = newFolder
            self.saveFolders()
            self.performSegue(withIdentifier: "showMemos", sender: self)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Folder Name"
            textField = alertTextField
        }
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
       
    func loadFolders() {
        
        let fullFolderRequest: NSFetchRequest<Folder> = Folder.fetchRequest()
        
        
        do {
            folderArray = try context.fetch(fullFolderRequest)

        } catch {
            print("Error while loading Folders: \(error)")
        }
    }


    func saveFolders() {

        do {
            try context.save()
        } catch {
            print("Error while saving new Folder: \(error)")
        }
    }
    
    
    
    func deleteMemosInFolder() {
        
        let request: NSFetchRequest<Memo> = Memo.fetchRequest()
        let predicate =  NSPredicate(format: "parentFolder.folderName MATCHES %@", selectedFolder!.folderName!)
        request.predicate = predicate
        
//        do {
//            memosToDelete = try context.fetch(request)
//        } catch {
//            print("Error while loading Memos to delete: \(error)")
//        }
        
        if let memosToDelete = try? context.fetch(request) {
            for object in memosToDelete {
                context.delete(object)
            }
        }
    }

    func saveMemo() {
        
        do {
            try context.save()
        } catch {
            print("Error while saving Memo: \(error)")
        }
    }
    
    
    
//MARK:_______________________SEGUE METHOD_______________________

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showMemos" {
            
            let destinationVC = segue.destination as! MemoViewController
            destinationVC.parentFolder = selectedFolder
        }
    }
    
}





