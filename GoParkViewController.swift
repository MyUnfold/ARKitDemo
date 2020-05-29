//
//  GoParkViewController.swift
//  ARKitInteraction
//
//  Created by Ibrahim Hassan on 25/05/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import ARKit

class GoParkViewController: UIViewController, ARCoachingOverlayViewDelegate {
    
    @IBOutlet weak var placeObjects: UIButton!
    
    @IBOutlet weak var sceneView: ARSCNView!

    let coachingOverlay = ARCoachingOverlayView()

    private var nodes: [SCNNode] = []
    
    // Edge case for 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let configuration = ARWorldTrackingConfiguration()
        self.sceneView.session.run(configuration)
        let arHelper = ARPlaceMenthelper.init(numberOfImages: 5, length: 5, width: 5, configuration: PlacementConfiguration.center.rawValue)
        placeObjects.isEnabled = false
        arHelper.getObjectsForConfigurations { (nodes) in
            DispatchQueue.main.async {
                self.placeObjects.isEnabled = true
                self.nodes = nodes
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.sceneView.session.pause()
        
    }
    
    @IBAction func placeObjects(_ sender: UIButton) {
        if sender.titleLabel?.text == "Load Images" {
            for node in self.nodes {
                let pictureNode = node.childNode(withName: "picture", recursively: true)
                pictureNode?.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "photo3")
            }
            print ("Load Images now")
        } else {
            DispatchQueue.main.async {
                for nNode in self.nodes {
                    self.sceneView.scene.rootNode.addChildNode(nNode)
                }
                sender.setTitle("Load Images", for: .normal)
            }
        }
    }
    
//    func setupCoachingOverlay() {
//        // Set up coaching view
//        coachingOverlay.session = sceneView.session
//        coachingOverlay.delegate = self
//
//        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
//        sceneView.addSubview(coachingOverlay)
//
//        NSLayoutConstraint.activate([
//            coachingOverlay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            coachingOverlay.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            coachingOverlay.widthAnchor.constraint(equalTo: view.widthAnchor),
//            coachingOverlay.heightAnchor.constraint(equalTo: view.heightAnchor)
//            ])
//
//        setActivatesAutomatically()
//        coachingOverlay.isHidden = false
//        // Most of the virtual objects in this sample require a horizontal surface,
//        // therefore coach the user to find a horizontal plane.
//        setGoal()
//    }
    
//    func setActivatesAutomatically() {
//        coachingOverlay.activatesAutomatically = true
//    }
//
//    /// - Tag: CoachingGoal
//    func setGoal() {
//        coachingOverlay.goal = .horizontalPlane
//    }
//
//    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
//        placeObjects.isHidden = true
//    }
//
//    /// - Tag: PresentUI
//    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
//        coachingOverlay.isHidden = true
//        placeObjects.isHidden = false
//    }

    
}
