//
//  ViewController.swift
//  UCSC Meets
//
//  Created by Dillon Kermani on 10/20/21.
//

import UIKit

class LoginSignUpViewController: UIViewController {

    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Button formatting
        loginBtn.layer.cornerRadius = 30
        signUpBtn.layer.cornerRadius = 30
        signUpBtn.layer.borderWidth = 2
        signUpBtn.layer.borderColor = (UIColor.systemYellow).cgColor
        
    }

    @IBAction func loginPressed(_ sender: Any) {
        loginBtn.pulsate()
        
    }
    

}

extension UIButton {
    
    func pulsate() {
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.25
        pulse.fromValue = 0.95
        pulse.toValue = 1.0
        pulse.autoreverses = false
        pulse.repeatCount = 0
        pulse.initialVelocity = 0
        pulse.damping = 0.5
        
        layer.add(pulse, forKey: nil)
    }
    
    func shake() {
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        
        let fromPoint = CGPoint(x: center.x - 5, y: center.y)
        let fromValue = NSValue(cgPoint: fromPoint)
        
        let toPoint = CGPoint(x: center.x + 5, y: center.y)
        let toValue = NSValue(cgPoint: toPoint)
        
        shake.fromValue = fromValue
        shake.toValue = toValue
        
        layer.add(shake, forKey: nil)
    }
    
}

extension UIViewController {

    func presentDetail(_ viewControllerToPresent: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        self.view.window!.layer.add(transition, forKey: kCATransition)

        present(viewControllerToPresent, animated: false)
    }

    func dismissDetail() {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)

        dismiss(animated: false)
    }
}


