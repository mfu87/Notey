//
//  MemoTableViewController.swift
//  Notey
//
//  Created by Marcus Fuchs on 28.07.19.
//  Copyright © 2019 Marcus Fuchs. All rights reserved.
//

import UIKit
import CoreData

class MemoViewController:  UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    
//MARK:_______________GLOBAL VARIABLES_______________
    
    //allMemosArray to get Index for DetailedViewVC
    var allMemosArray = [Memo]()
    
    var memoArray = [Memo]()
    
    var parentFolder: Folder?
    
    var memoIndex: Int?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var memoTableView: UITableView!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBAction func backToFoldersTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "backToFolders", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.topItem?.title = parentFolder?.folderName
        loadMemos()
    }
    
    
//MARK:_______________TABLEVIEW DELEGATE METHODS_______________
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "memoCell", for: indexPath)
        
        cell.textLabel?.text = memoArray[indexPath.row].memoTitle

        cell.detailTextLabel?.text = createMemoSubtitle(content: memoArray[indexPath.row].memoContent!)
     
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let tappedMemo = memoArray[indexPath.row]
        memoIndex = allMemosArray.firstIndex(of: tappedMemo)!
        performSegue(withIdentifier: "showDetailedMemo", sender: self)
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
            context.delete(memoArray[indexPath.row])
            saveMemo()
            loadMemos()
            tableView.reloadData()
        }
    }


    
    
//MARK:________________DATA MANIPULATION METHODS________________

    @IBAction func addMemoTapped(_ sender: UIBarButtonItem) {
        
        let newMemo = Memo(context: context)
        newMemo.memoTitle = "New Notey"
        newMemo.memoContent = ""
        newMemo.parentFolder = parentFolder
        allMemosArray.append(newMemo)
        saveMemo()
        
        memoIndex = allMemosArray.firstIndex(of: newMemo)!
        performSegue(withIdentifier: "showDetailedMemo", sender: self)
  }
    
    
    func loadMemos() {
        
        let request: NSFetchRequest<Memo> = Memo.fetchRequest()
        let folderPredicate =  NSPredicate(format: "parentFolder.folderName MATCHES %@", parentFolder!.folderName!)
        request.predicate = folderPredicate
        
        let fullRequest: NSFetchRequest<Memo> = Memo.fetchRequest()
        
        do {
            memoArray = try context.fetch(request)
            allMemosArray = try context.fetch(fullRequest)
        } catch {
            print("Error while loading Memos: \(error)")
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
        if segue.identifier == "showDetailedMemo" {

            let destinationVC = segue.destination as! DetailedMemoViewController

            destinationVC.memoIndex = memoIndex
            destinationVC.parentFolder = parentFolder
        }
    }





//MARK:_______________________FURTHER METHOS______________________


    func createMemoSubtitle(content: String) -> String {
        
        let removedDoubleSpaces = content.removeMoreThanTwoSpaces1()
        let removeLeadingSpaces = removedDoubleSpaces.trimmingCharacters(in: .whitespaces)
        // cut first 20
        let memoSubtitle = removeLeadingSpaces.dropFirst(20)
        
        
        if memoSubtitle.count > 0 {
            
            return String(memoSubtitle)
            
        }   else {
            return " "
        }
    }




}


//MARK:________________________EXTENTIONS_________________________

extension String {

    func removeMoreThanTwoSpaces1() -> String {
        return self.replacingOccurrences(of: "[\\s\n]+", with: " ", options: .regularExpression, range: nil)
    }
}
