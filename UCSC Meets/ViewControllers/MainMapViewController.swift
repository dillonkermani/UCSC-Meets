//  MapViewController.swift
//  UCSC Meets
//
//  Created by Dillon Kermani on 10/27/21.
//

import UIKit
import MapKit
import CoreLocation

class MainMapViewController: UIViewController, CLLocationManagerDelegate {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        
        setupCard()

    }
    
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
            animateTransitionIfNeeded(state: nextState, duration: 0.9)
        default:
            break
        }
    }
    
    @objc
    func handleCardPan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            // Start transition animation.
            startInteractiveTransition(state: nextState, duration: 0.9)
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
