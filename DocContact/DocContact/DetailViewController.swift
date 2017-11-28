//
//  DetailViewController.swift
//  DocContact
//
//  Created by Thomas on 27/11/2017.
//  Copyright © 2017 Cuba Libre. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Mon Contact"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Modifier", style: .plain, target: self, action: #selector(goToEditContact))
    }
    
    @objc func goToEditContact(){
        let contactVC = AddEditContactViewController(nibName: nil, bundle: nil)
        let navVC = UINavigationController(rootViewController: contactVC)
        self.present(navVC, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
