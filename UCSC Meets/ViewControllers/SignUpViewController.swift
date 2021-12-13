//
//  SignUpViewController.swift
//  UCSC Meets
//
//  Created by Dillon Kermani on 10/20/21.
//

import UIKit

class SignUpViewController: UIViewController {
    
    var placeholderStrings:[String] = ["First Name", "Last Name", "Enter your @ucsc.edu email", "Password", "Confirm Password"]
    
    @IBOutlet var signUpTextFields: [UITextField]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for (i, tf) in signUpTextFields.enumerated() {
            tf.layer.cornerRadius = 20
            tf.layer.masksToBounds = true
            
            tf.attributedPlaceholder = NSAttributedString(string: placeholderStrings[i], attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
