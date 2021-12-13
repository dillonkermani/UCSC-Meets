//
//  TakePFPViewController.swift
//  UCSC Meets
//
//  Created by Dillon Kermani on 12/7/21.
//

import UIKit

class TakePFPViewController: UIViewController {
    
    @IBOutlet weak var pfp_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
        
    }
    
    @IBAction func pfp_btn_pressed(_ sender: Any) {
        pfp_btn.layer.cornerRadius = 100
        pfp_btn.layer.borderWidth = 0
        pfp_btn.pulsate()
        
    }
    

    
    
    
}
