//
//  ContactListTableViewController.swift
//  DocContact
//
//  Created by Thomas on 27/11/2017.
//  Copyright © 2017 Cuba Libre. All rights reserved.
//

import UIKit
import CoreData
import SideMenu

class ContactListTableViewController: UITableViewController{
    
    var contacts = [Contact]()
    var resultController : NSFetchedResultsController<Contact>!
    let netProvider = NetworkProvider.sharedInstance
    
    // SearchBar
    @IBOutlet weak var searchBarView: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let drawerController  = SideDrawerViewController(nibName: nil, bundle: nil)
            // Menu a gauche
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: drawerController)
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        
        SideMenuManager.default.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        
        
		
        //let netProvider = NetworkProvider.sharedInstance
        self.netProvider.getContacts()
        
        // Get the list of contacts
        let fetchRequest = NSFetchRequest<Contact>(entityName : "Contact")
        let sortFirstName = NSSortDescriptor(key: "firstName", ascending: true)
        let sortLastName = NSSortDescriptor(key: "lastName", ascending: true)
        fetchRequest.sortDescriptors = [sortFirstName , sortLastName]
        resultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: netProvider.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        resultController.delegate = self
        try? resultController.performFetch()
        self.tableView.reloadData()
        
        // Set the title with correct parameters
        self.title = NSLocalizedString("MyContacts", comment: "")
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "Domine", size: 19)! ]
        
        let nib = UINib(nibName: "ContactTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ContactCell")
        
        searchBarView.delegate = self
        searchBarView.placeholder = NSLocalizedString("NameOrPhoneNumber", comment: "")
        searchBarView.barTintColor = UIColor.DocColors.blue
        
        let validateCreation = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(goToEditContact))
        self.navigationItem.rightBarButtonItem = validateCreation
        
        //Hide the keyboard if you click elsewhere on the screen
        self.hideKeyboardWhenTappedAround()
        
    }
    
    @objc func goToEditContact(){
        let contactVC = AddEditContactViewController(nibName: nil, bundle: nil)
        contactVC.isInEditionMode = false   //On précise à la view AddEdit qu'il s'agit d'un ajout
        self.navigationController?.pushViewController(contactVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let frc = self.resultController {
            return frc.sections!.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.resultController?.sections else {
            fatalError("No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
        
        // Change cell color
        if (indexPath.row+1)%2 == 0 {
            cell.contentView.backgroundColor = UIColor.DocColors.cellDarkColor
        } else {
            cell.contentView.backgroundColor = UIColor.DocColors.cellLightColor
        }
        
        if let contactCell = cell as? ContactTableViewCell {
            let contact = resultController.object(at: indexPath)
            contactCell.firstNameLabel.text = contact.firstName
            contactCell.lastNameLabel.text = contact.lastName
            contactCell.phoneNumber = contact.phone
            
            if contact.gravatar == ""{
                contactCell.gravatarHash = "https://www.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50"
            } else {
                contactCell.gravatarHash = contact.gravatar     //Envoie le hash Gravatar à la cellule
            }
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let contact = self.resultController?.object(at: indexPath) else{
            return
        }
        
        let detailViewController = DetailViewController(nibName: nil, bundle: nil)
        //detailViewController.delegate = self
        detailViewController.contact = contact
        self.navigationController?.pushViewController(detailViewController, animated: true)
        
    }

    
    func searchBarResearch(research : String){
        var predicate : NSPredicate?
        let lastNamePredicate = NSPredicate(format: "lastName CONTAINS[cd] %@", research)
        let firstNamePredicate = NSPredicate(format: "firstName CONTAINS[cd] %@", research)
        predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [lastNamePredicate,firstNamePredicate])
     
        
        let phoneRegexPattern = "^[0-9]+$"
        let phoneRegex = try! NSRegularExpression(pattern: phoneRegexPattern,
                                                  options: .caseInsensitive)
        let matches = phoneRegex.matches(in: research, range: NSMakeRange(0, research.count))
        if(matches.count>0){
            let phonePredicate = NSPredicate(format: "phone BEGINSWITH %@", research)
            predicate = phonePredicate
        }
        
        // Get the list of contacts
        let fetchRequest = NSFetchRequest<Contact>(entityName : "Contact")
        let sortFirstName = NSSortDescriptor(key: "firstName", ascending: true)
        let sortLastName = NSSortDescriptor(key: "lastName", ascending: true)
        fetchRequest.sortDescriptors = [sortFirstName , sortLastName]
        fetchRequest.predicate = predicate
        resultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.netProvider.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        resultController.delegate = self
        
        do {
            try resultController.performFetch()
        } catch {
            print(error)
        }
        self.tableView.reloadData()
    }
    
    func displayAllContacts(){
        let fetchRequest = NSFetchRequest<Contact>(entityName : "Contact")
        let sortFirstName = NSSortDescriptor(key: "firstName", ascending: true)
        let sortLastName = NSSortDescriptor(key: "lastName", ascending: true)
        fetchRequest.sortDescriptors = [sortFirstName , sortLastName]
        resultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.netProvider.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        resultController.delegate = self
        
        do {
            try resultController.performFetch()
        } catch {
            print(error)
        }
        self.tableView.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchBarView.text?.isEmpty ?? true
    }
}

extension ContactListTableViewController : NSFetchedResultsControllerDelegate{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.reloadData()
    }
}

extension ContactListTableViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let empty = searchBarIsEmpty()
        if(!empty){
            let research = searchBarView.text!
            searchBarResearch(research: research)
        }else{
            displayAllContacts()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Appui sur search")
        self.view.endEditing(true)
    }
}
