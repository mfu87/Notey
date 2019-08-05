//
//  DetailedMemoViewController.swift
//  Notey
//
//  Created by Marcus Fuchs on 28.07.19.
//  Copyright © 2019 Marcus Fuchs. All rights reserved.
//

import UIKit
import CoreData

class DetailedMemoViewController: UIViewController {
    
    
    
//MARK:_______________GLOBAL VARIABLES_______________
    
    var memoIndex: Int?
    
    var parentFolder: Folder?

    var allMemosArray = [Memo]()

    @IBOutlet weak var navigationBar: UINavigationBar!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var titleTextLabel: UILabel!
    
    @IBOutlet weak var contentTextField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMemo()
        navigationBar.topItem?.title = "Your Notey"
    }
    
    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        
        if checkIfContentFieldEmpty(textView: contentTextField) == true {
            updateMemo()
            save()
            performSegue(withIdentifier: "backToMemos", sender: self)
        } else {
                context.delete(allMemosArray[memoIndex!])
                save()
                performSegue(withIdentifier: "backToMemos", sender: self)
                }
    }
    
    
    
//MARK:________________DATA MANIPULATION METHODS________________

    func loadMemo() {
        
        let request: NSFetchRequest<Memo> = Memo.fetchRequest()
        
        do {
            try allMemosArray = context.fetch(request)
        } catch {
            print("Error while loading MemoContent: \(error)")
        }
        
        titleTextLabel.text = allMemosArray[memoIndex!].memoTitle
        contentTextField.text = allMemosArray[memoIndex!].memoContent
    }

    
    func updateMemo() {

        allMemosArray[memoIndex!].memoTitle = createMemoTitle(content: contentTextField.text!)
        allMemosArray[memoIndex!].memoContent = contentTextField.text!
        allMemosArray[memoIndex!].parentFolder = parentFolder
    }

    
    
    func save() {
        
        do {
            try context.save()
        } catch {
            print("Error while updating Memo: \(error)")
        }
    }
    
    
    
//MARK:_______________________SEGUE METHOD_______________________

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToMemos" {
            
            let destinationVC = segue.destination as! MemoViewController
            destinationVC.parentFolder = parentFolder
        }
    }
    
    
    
    
//MARK:_______________________FURTHER METHOS______________________

    
    func checkIfContentFieldEmpty(textView: UITextView) -> Bool {
        guard let text = textView.text,
            !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
                // this will be reached if the text is nil (unlikely)
                // or if the text only contains white spaces
                // or no text at all
                return false
        }
        return true
    }
    
    
    func createMemoTitle(content: String) -> String {
        
        let removedDoubleSpaces = content.removeMoreThanTwoSpaces2()
        let removeLeadingSpaces = removedDoubleSpaces.trimmingCharacters(in: .whitespaces)
        let stringLenght = removeLeadingSpaces.count
        
        if stringLenght > 30 {
            // return first 20
            var memoTitle = removeLeadingSpaces.dropLast(stringLenght - 20)
            memoTitle.append(contentsOf: "...")
            return String(memoTitle)
        }
            else {
            
                return removeLeadingSpaces
            }
    }
    

}




//MARK:________________________EXTENTIONS_________________________

extension String {
    
    func removeMoreThanTwoSpaces2() -> String {
        return self.replacingOccurrences(of: "[\\s\n]+", with: " ", options: .regularExpression, range: nil)
    }
}

