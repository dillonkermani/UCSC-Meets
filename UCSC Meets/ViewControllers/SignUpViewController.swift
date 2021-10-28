//
//  SignUpViewController.swift
//  UCSC Meets
//
//  Created by Dillon Kermani on 10/20/21.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet var signUpTextFields: [UITextField]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for tf in signUpTextFields {
            tf.layer.cornerRadius = 20
            tf.layer.masksToBounds = true
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
