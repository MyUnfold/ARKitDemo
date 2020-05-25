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
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        placeObjects.isHidden = true
//        setupCoachingOverlay()
        let configuration = ARWorldTrackingConfiguration()
        self.sceneView.session.run(configuration)
        let arHelper = ARPlaceMenthelper.init(numberOfImages: 6, length: 5, width: 5, configuration: PlacementConfiguration.center.rawValue)
        arHelper.getObjectsForConfigurations { (nodes) in
            DispatchQueue.main.async {
                self.nodes = nodes
                for node in nodes {
                    guard let frame = self.sceneView.session.currentFrame else {
                        continue
                    }
//                    node.eulerAngles.y = frame.camera.eulerAngles.y
                }
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
        for node in nodes {
            sceneView.scene.rootNode.addChildNode(node)
        }
    }
    
    func setupCoachingOverlay() {
        // Set up coaching view
        coachingOverlay.session = sceneView.session
        coachingOverlay.delegate = self
        
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        sceneView.addSubview(coachingOverlay)
        
        NSLayoutConstraint.activate([
            coachingOverlay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            coachingOverlay.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            coachingOverlay.widthAnchor.constraint(equalTo: view.widthAnchor),
            coachingOverlay.heightAnchor.constraint(equalTo: view.heightAnchor)
            ])
        
        setActivatesAutomatically()
        coachingOverlay.isHidden = false
        // Most of the virtual objects in this sample require a horizontal surface,
        // therefore coach the user to find a horizontal plane.
        setGoal()
    }
    
    func setActivatesAutomatically() {
        coachingOverlay.activatesAutomatically = true
    }

    /// - Tag: CoachingGoal
    func setGoal() {
        coachingOverlay.goal = .horizontalPlane
    }
    
    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
        placeObjects.isHidden = true
    }
    
    /// - Tag: PresentUI
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        coachingOverlay.isHidden = true
        placeObjects.isHidden = false
    }

    
}
