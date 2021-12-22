//  MapViewController.swift
//  UCSC Meets
//
//  Created by Dillon Kermani on 10/27/21.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseAuth
import FirebaseFirestore
//import SAConfettiView

var currentUser = Auth.auth().currentUser

class MainMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var db:Firestore!
    // This dict will be written to the db upon completion of entry
    var entryDataDict = Dictionary<String, Any>()
    
    enum CardState {
        case expanded
        case collapsed
    }
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 400
    
    var cardViewController: CardViewController!
    let cardHeight:CGFloat = 300
    let cardHandleArea:CGFloat = 65
    var cardVisible = false
    var nextState:CardState {
        return cardVisible ? .collapsed : .expanded
    }
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted:CGFloat = 0
    
    @IBOutlet weak var chooseLoc_label: UILabel!
    
    @IBOutlet weak var plus_btn: CustomButton!
    @IBOutlet weak var settings_btn: CustomButton!
    @IBOutlet weak var refresh_btn: CustomButton!
    @IBOutlet weak var notif_btn: CustomButton!
    @IBOutlet weak var logOut_btn: CustomButton!
    @IBOutlet weak var menu_view: UIView!
    
    var refresh_btn_center: CGPoint!
    var notif_btn_center: CGPoint!
    var logOut_btn_center: CGPoint!
    
    var settings_expanded = false
    var plus_expanded = false
    var pinPrompt_expanded = false
    var pin_setup_complete = false
    
    let annotation = MKPointAnnotation()
    
    @IBOutlet weak var prompt_parent_view: UIView!
    @IBOutlet weak var promptParentViewCenterX: NSLayoutConstraint!
    
    
    @IBOutlet weak var ghostPin: UIButton!
    @IBOutlet weak var ghostPinCenterY: NSLayoutConstraint!
    
    
    // Each prompt view and a list containing all.
    @IBOutlet weak var promptParent_view: UIView!
    @IBOutlet weak var titleSubview: UIView!
    @IBOutlet weak var titleTextview: UITextField!
    
    
    @IBOutlet weak var timeSubview: UIView!
    @IBOutlet weak var startTimeTextview: UITextField!
    @IBOutlet weak var endTimeTextView: UITextField!
    
    @IBOutlet weak var pinSubview: UIView!
    
    @IBOutlet weak var postSubview: UIView!
    
    var promptViews: [UIView]!
    
    var currentView_index = 0
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        
        db = Firestore.firestore()
        loadGlobalPins()

        
        promptViews = [titleSubview, timeSubview, pinSubview, postSubview]
        //Causes entryParentView to load from left of view
        //promptParentViewCenterX.constant -= view.bounds.width
        ghostPinCenterY.constant -= view.bounds.height
        
        setupCard()
        
        // Saving destination locations for settings buttons at setup.
        refresh_btn_center = refresh_btn.center
        notif_btn_center = notif_btn.center
        logOut_btn_center = logOut_btn.center
        // Collapse settings buttons.
        refresh_btn.center = settings_btn.center
        notif_btn.center = settings_btn.center
        logOut_btn.center = settings_btn.center
        menu_view.center = settings_btn.center
        
        
        // Collapse menu_view
        menu_view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        // For getting location while tapping on map we need to add UITapGestureRecognizer
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleTap))
        mapView.addGestureRecognizer(longPressGesture)
        mapView.delegate = self
        
        ghostPin.isHidden = true
        
        

    }
    
    func loadGlobalPins () {
        db.collection("global_pins").getDocuments(completion: { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    // Draw map pin.
                    let geoPoint = document.get("coordinate") as! GeoPoint
                    let coordinate = CLLocationCoordinate2D.init(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                    let title = document.get("title")
                    //let subtitle = document.get("subtitle")
                    let pin = MKPointAnnotation()
                    pin.coordinate = coordinate
                    pin.title = title as? String
                    //pin.subtitle = subtitle as? String
                    self.mapView.addAnnotation(pin)
                    
                    
                }
            }
        })
    }
    
    
    
    // BEGIN Meet setup prompting.
    @objc func handleTap(gestureRecognizer: UILongPressGestureRecognizer) {
        loadGlobalPins()

        if !pinPrompt_expanded {
            presentPinPrompt()
            plus_btn_pressed()
            // Save tapped location
            let tappedLocation = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(tappedLocation,toCoordinateFrom: mapView)

            // Center screen at tappedLocation
            let region = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
            
            // Create and add ghost annotation to tappedLocation
            ghostPin.isHidden = false
            
        }
        
        
    }
    
    
    
    func presentPinPrompt() {
        // TODO: Clear all prompt text fields.
        
        UIView.transition(from: promptViews[currentView_index], to: promptViews[0], duration: 0.5, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: nil)
        currentView_index = 0
        // Present Prompt Screen (incomplete)
        UIView.animate(withDuration: 0.9, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    //self.promptParentViewCenterX.constant += self.view.bounds.width
                    self.ghostPinCenterY.constant += self.view.bounds.height
                    self.view.layoutIfNeeded()
                }, completion: nil)
        
        
        
        pinPrompt_expanded = true
        // Save meet_title
            // annotation.title =
            // annotation.subtitle =
        
        // Present When? Screen (incomplete)
            // Save start_time & end_time
        
        // Present Choose Pin Screen (incomplete)
        
        
        // If done is pressed, create new global pin and upload all saved attributes to Firestore
            // upload data to db
        // Else remove pin from map and centerViewOnUserLocation()
    }
   
    func collapsePinPrompt() {
        UIView.animate(withDuration: 0.9, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                    //self.promptParentViewCenterX.constant -= self.view.bounds.width
                    self.ghostPinCenterY.constant -= self.view.bounds.height
                    self.view.layoutIfNeeded()
                }, completion: nil)
        pinPrompt_expanded = false
    }
    
    @IBAction func nextBtn_pressed(_ sender: Any) {
        // Transition to next promptView.
        if currentView_index < promptViews.count - 1 {
            UIView.transition(from: promptViews[currentView_index], to: promptViews[currentView_index + 1], duration: 0.5, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: nil)
            currentView_index += 1
            
            
            // Not working for iPhone 6s. Lets see if it works for newer iPhones.
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
        return
        
        
    }
    
    @IBAction func prevBtn_pressed(_ sender: Any) {
        // Transition to previous promptView.
        if currentView_index > 0 {
            UIView.transition(from: promptViews[currentView_index], to: promptViews[currentView_index - 1], duration: 0.5, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: nil)
            currentView_index -= 1
        }
        return
    }
    
    
    @IBAction func plus_btn_pressed(_ sender: Any) {
        // Set in in center of screen
        
        // Display prompt view etc.
        
        if !plus_expanded {
            // Create pin in middle of screen
            ghostPin.isHidden = false
            plus_btn_pressed()
            presentPinPrompt()
        } else {
            x_btn_pressed()
        }
        

        
        
        // If center of screen is not MKUserLocation
            // Create annotation at center of screen.
    
    }
    
    
    
    func plus_btn_pressed() {
        UIView.animate(withDuration: 0.3, animations: {
                self.plus_btn.transform = CGAffineTransform(rotationAngle: 260)
                self.plus_btn.backgroundColor = UIColor.systemRed
                self.plus_btn.tintColor = UIColor.white
                self.plus_expanded = true
        })
    }
    
    func x_btn_pressed() {
        UIView.animate(withDuration: 0.3, animations: {
            self.plus_btn.transform = .identity
            self.plus_btn.backgroundColor = UIColor.systemBlue
            self.plus_btn.tintColor = UIColor.systemYellow
            self.plus_expanded = false
            
        })
        self.collapsePinPrompt()
        ghostPin.isHidden = true
    }
    
    // Post pin to public_pins
    @IBAction func post_btn_pressed(_ sender: Any) {
        // Pin attributes:
        
        let pinTitle = titleTextview.text
        let startTime = startTimeTextview.text
        let endTime = endTimeTextView.text
        let coordinate = mapView.centerCoordinate
        
        entryDataDict["startTime"] = startTime
        entryDataDict["endTime"] = endTime
        entryDataDict["coordinate"] = GeoPoint.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        
        
        db.collection("global_pins").document(pinTitle!).setData(entryDataDict)
        
        x_btn_pressed()
        
        loadGlobalPins()
        
        
    }
    
    
    
    @IBAction func settings_btn_clicked(_ sender: UIButton) {
        if settings_expanded == false {
            // Expand settings buttons.
            UIView.animate(withDuration: 0.3, animations: {
                
                // Expand menu view
                self.menu_view.transform = .identity
                
                // Rotate settings button 180 degrees
                self.settings_btn.transform = CGAffineTransform(rotationAngle: 180.0)
                
                // expand settings buttons
                self.refresh_btn.alpha = 1
                self.notif_btn.alpha = 1
                self.logOut_btn.alpha = 1
                self.menu_view.alpha = 1
                
                self.refresh_btn.center = self.refresh_btn_center
                self.notif_btn.center = self.notif_btn_center
                self.logOut_btn.center = self.logOut_btn_center
                
                self.settings_expanded = true
                
                
            })
            
        } else {
            
            // Collapse settings buttons.
            UIView.animate(withDuration: 0.3, animations: {
                // Collapse menu_view
                self.menu_view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                // Unwind settings rotation
                self.settings_btn.transform = CGAffineTransform.identity
                
                self.refresh_btn.alpha = 0
                self.notif_btn.alpha = 0
                self.logOut_btn.alpha = 0
                self.menu_view.alpha = 0
                
                self.refresh_btn.center = self.settings_btn.center
                self.notif_btn.center = self.settings_btn.center
                self.logOut_btn.center = self.settings_btn.center
                
                self.settings_expanded = false
            })
        }
        
    }
    
    // Setup for bottom info card.
    func setupCard() {

        cardViewController = CardViewController(nibName: "CardViewController", bundle: nil)
        self.addChild(cardViewController)
        self.view.addSubview(cardViewController.view)
        
        cardViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - cardHandleArea, width: self.view.bounds.width, height: cardHeight)
        
        cardViewController.view.clipsToBounds = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainMapViewController.handleCardTap(recognizer:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(MainMapViewController.handleCardPan(recognizer:)))
        
        cardViewController.handleArea.addGestureRecognizer(tapGestureRecognizer)
        cardViewController.handleArea.addGestureRecognizer(panGestureRecognizer)
        cardViewController.view.layer.cornerRadius = 12

    }
    
    @objc
    func handleCardTap(recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            animateTransitionIfNeeded(state: nextState, duration: 0.4)
        default:
            break
        }
    }
    
    @objc
    func handleCardPan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            // Start transition animation.
            startInteractiveTransition(state: nextState, duration: 0.4)
        case .changed:
            // Update transition animaiton.
            let translation = recognizer.translation(in: self.cardViewController.handleArea)
            var fractionComplete = translation.y / cardHeight
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            // Continue transition animation.
            continueInteractiveTransition()
        default:
            break
        }
    }
    
    
    func animateTransitionIfNeeded (state:CardState, duration:TimeInterval) {
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHeight
                case .collapsed:
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHandleArea
                }
            }
            
            frameAnimator.addCompletion { _ in
                self.cardVisible = !self.cardVisible
                self.runningAnimations.removeAll()
            }
            
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            
            

            
        }
    }
    
    func startInteractiveTransition(state:CardState, duration:TimeInterval) {
            if runningAnimations.isEmpty {
                animateTransitionIfNeeded(state: state, duration: duration)
            }
            for animator in runningAnimations {
                animator.pauseAnimation()
                animationProgressWhenInterrupted = animator.fractionComplete
            }
        }
        
        func updateInteractiveTransition(fractionCompleted:CGFloat) {
            for animator in runningAnimations {
                animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
            }
        }
        
        func continueInteractiveTransition (){
            for animator in runningAnimations {
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            }
        }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    func checkLocationServices() {
        // Checks whether DEVICE WIDE LOCATION is enabled.
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Show alert letting user know that they need to turn it on.
        }
        
    }
    
    func checkLocationAuthorization() {
        // Authorization status is the status of location services authorized by the user.
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            // Location services has been authorized. Setup map functionality
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            //locationManager.startUpdatingLocation() // Executes didUpdateLocations delegate func below
            break
        case .notDetermined:
            // Prompt user to enable location services.
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            // Inform user that location services is disabled and help them enable it.
            break
        case .authorizedAlways:
            break
        @unknown default:
            break
        }
    }
    

}

extension MainMapViewController {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
}
