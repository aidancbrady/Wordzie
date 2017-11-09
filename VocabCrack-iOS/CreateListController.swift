//
//  CreateListController.swift
//  Wordzie
//
//  Created by aidancbrady on 12/15/14.
//  Copyright (c) 2014 aidancbrady. All rights reserved.
//

import UIKit

class CreateListController: UITableViewController
{
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var activity:UIActivityIndicatorView!
    
    var editingList:(String, String)?
    
    var terms:[(String, String)] = [(String, String)]()
    
    func listEdited()
    {
        if terms.count < 10
        {
            saveButton.isEnabled = false
        }
        else {
            saveButton.isEnabled = true
        }
    }
    
    @IBAction func newTermButton(_ sender: AnyObject)
    {
        if editingList != nil && terms.count == 0
        {
            return
        }
        
        if terms.count < 50
        {
            let editTerm:UINavigationController = self.storyboard?.instantiateViewController(withIdentifier: "EditTermNavigation") as! UINavigationController
            
            self.present(editTerm, animated: true, completion: nil)
        }
        else {
            Utilities.displayAlert(self, title: "Error", msg: "List cannot contain more than 50 terms.", action: nil)
        }
    }
    
    @IBAction func saveButton(_ sender: AnyObject)
    {
        if editingList != nil && terms.count == 0
        {
            return
        }
        
        if terms.count < 10
        {
            if terms.count > 0
            {
                Utilities.displayAlert(self, title: "Error", msg: "List must contain at least 10 terms.", action: nil)
            }
            
            return
        }
        
        showEntry()
    }
    
    func showEntry()
    {
        if editingList == nil
        {
            Utilities.displayInput(self, title: "Upload List", msg: "Enter a unique identifier for your word list.", placeholder: "List Identifier", handler: {str in
                if str == nil || str == ""
                {
                    Utilities.displayAlert(self, title: "Error", msg: "Please enter an identifier.", action: {action in
                        self.showEntry()
                        return
                    })
                }
                else if str != nil
                {
                    if !Utilities.isValidCredential(str!)
                    {
                        Utilities.displayAlert(self, title: "Error", msg: "Invalid characters.", action: {action in
                            self.showEntry()
                            return
                        })
                    }
                    else if (str!).count > 18
                    {
                        Utilities.displayAlert(self, title: "Error", msg: "Too many characters.", action: {action in
                            self.showEntry()
                            return
                        })
                    }
                    else {
                        self.activity.startAnimating()
                        self.saveButton.isEnabled = false
                        Handlers.listHandler.confirmList(WeakWrapper(value: self), identifier: Utilities.trim(str!))
                    }
                }
            })
        }
        else {
            self.activity.startAnimating()
            self.saveButton.isEnabled = false
            Handlers.listHandler.editList(WeakWrapper(value: self))
        }
    }
    
    func compileList() -> String
    {
        let str:NSMutableString = NSMutableString()
        
        for term in terms
        {
            str.append(term.0 + Constants.SPLITTER_2 + term.1)
            str.append(Constants.SPLITTER_1)
        }
        
        return str as String
    }

    @IBAction func cancelButton(_ sender: AnyObject)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        activity.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        activity.hidesWhenStopped = true
        activity.stopAnimating()
        activity.center = CGPoint(x: 120, y: activity.frame.height/2)
        
        let barButton:UIBarButtonItem = UIBarButtonItem(customView: activity)
        toolbarItems!.append(barButton)
        self.setToolbarItems(toolbarItems, animated: false)
        
        if editingList != nil
        {
            navigationItem.title = "Edit List"
            
            activity.startAnimating()
            WordListHandler.loadListForEdit(editingList!, controller: WeakWrapper(value: self))
        }
        else {
            saveButton.isEnabled = false
        }
        
        self.navigationController!.setToolbarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        navigationController!.setToolbarHidden(false, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return terms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TermCell", for: indexPath) as! TermCell

        cell.wordLabel.text = terms[(indexPath as NSIndexPath).row].0

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            terms.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            listEdited()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let indexPath = tableView.indexPathForSelectedRow
        {
            if segue.destination is TermDetailController
            {
                (segue.destination as! TermDetailController).term = terms[(indexPath as NSIndexPath).row]
                (segue.destination as! TermDetailController).index = (indexPath as NSIndexPath).row
            }
        }
    }
}
