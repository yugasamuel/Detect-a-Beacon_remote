//
//  ViewController.swift
//  Detect-a-Beacon
//
//  Created by Yuga Samuel on 02/10/23.
//

import UIKit
import CoreLocation

extension UIView {
    func bounceOut(duration: TimeInterval) {
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, animations: {
            self.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        }) { _ in
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5,
                           animations: {
                self.transform = CGAffineTransform.identity
            })
        }
    }
}

class ViewController: UIViewController, CLLocationManagerDelegate {
    var distanceReading: UILabel!
    var locationManager: CLLocationManager?
    var alertShown: Bool = false
    
    var circleView: UIView!
    
    var scaleFactor: Double! {
        didSet {
            circleView.contentScaleFactor = scaleFactor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        scaleFactor = 0.001
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .gray
        
        distanceReading = UILabel()
        distanceReading.text = "UNKNOWN"
        distanceReading.font = UIFont.systemFont(ofSize: 40, weight: .thin)
        distanceReading.textColor = UIColor.white
        distanceReading.layer.zPosition = 1
        distanceReading.translatesAutoresizingMaskIntoConstraints = false
        
        circleView = UIView()
        circleView.backgroundColor = .yellow
        circleView.layer.cornerRadius = 128
        circleView.translatesAutoresizingMaskIntoConstraints = false
        
        circleView.bounceOut(duration: 1)
        
        view.addSubview(distanceReading)
        view.addSubview(circleView)
        
        NSLayoutConstraint.activate([
            distanceReading.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            distanceReading.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            circleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 256),
            circleView.heightAnchor.constraint(equalToConstant: 256)
        ])
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if let beacon = beacons.first {
            update(distance: beacon.proximity)
            if !alertShown {
                showAlert()
                alertShown = true
            }
        } else {
            update(distance: .unknown)
        }
    }
    
    func showAlert() {
        let ac = UIAlertController(title: "Beacon Detected", message: "A beacon has been detected.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        ac.addAction(action)
        present(ac, animated: true, completion: nil)
    }
    
    func update(distance: CLProximity) {
        UIView.animate(withDuration: 1) {
            switch distance {
            case .far:
                self.view.backgroundColor = UIColor.blue
                self.distanceReading.text = "FAR"
                self.scaleFactor = 0.25
                
            case .near:
                self.view.backgroundColor = UIColor.orange
                self.distanceReading.text = "NEAR"
                self.scaleFactor = 0.5
                
            case .immediate:
                self.view.backgroundColor = UIColor.red
                self.distanceReading.text = "RIGHT HERE"
                self.scaleFactor = 1.0
                
            default:
                self.view.backgroundColor = .black
                self.distanceReading.text = "WHOA!"
                self.scaleFactor = 0.001
            }
            
            self.circleView.transform = CGAffineTransform(scaleX: self.scaleFactor, y: self.scaleFactor)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func startScanning() {
        let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
        let beaconRegion = CLBeaconRegion(uuid: uuid, major: 123, minor: 456, identifier: "MyBeacon")
        
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
    }
}

