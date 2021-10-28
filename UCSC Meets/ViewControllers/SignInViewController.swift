//
//  SignInViewController.swift
//  UCSC Meets
//
//  Created by Dillon Kermani on 10/20/21.
//

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.layer.cornerRadius = 20
        emailTextField.layer.masksToBounds = true
        passwordTextField.layer.cornerRadius = 20
        passwordTextField.layer.masksToBounds = true
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
