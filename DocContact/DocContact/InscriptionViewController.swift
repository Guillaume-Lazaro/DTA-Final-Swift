//
//  InscriptionViewController.swift
//  DocContact
//
//  Created by Thomas on 27/11/2017.
//  Copyright © 2017 Cuba Libre. All rights reserved.
//

import UIKit

class InscriptionViewController: UIViewController {

    @IBOutlet weak var pickerTextField: UITextField!

    var pickOption = ["Famille", "Santé", "Proche"]

    override func viewDidLoad() {
        super.viewDidLoad()

        var pickerView = UIPickerView()
        pickerView.delegate = self
        pickerTextField.inputView = pickerView
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
