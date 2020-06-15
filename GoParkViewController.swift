//
//  GoParkViewController.swift
//  ARKitInteraction
//
//  Created by Ibrahim Hassan on 25/05/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import ARKit

class GoParkViewController: UIViewController {
    
    @IBOutlet weak var placeObjects: UIButton!
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBAction func goBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private var nodes: [SCNNode] = []
    
    private let configuration = ARWorldTrackingConfiguration.init()
    
    var length : CGFloat = 0.0
    var width : CGFloat = 0.0
    var numberOfImages : CGFloat = 0.0
    var configurationPicked = 0
    
    // Edge case for 3
    
    private func registerGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(search))
        self.sceneView.addGestureRecognizer(tap)
    }
    
    @objc func search(sender: UITapGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView
        let location = sender.location(in: sceneView)
        let results = sceneView.hitTest(location, options: [SCNHitTestOption.searchMode : 1,
                                                            SCNHitTestOption.ignoreChildNodes : false])
        
        if results.filter( { $0.node.name != nil }).count != 0 {
            performSegue(withIdentifier: "showDetails", sender: nil)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? DetailsViewController {
            
        }
    }
    
    private var arHelper: ARPlaceMenthelper?
    private var selectedPageNumber = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true        
        registerGestureRecognizer()
        configuration.isAutoFocusEnabled = false
        sceneView.session.delegate = self
        self.sceneView.session.run(configuration)
        
        let arHelper = ARPlaceMenthelper.init(numberOfImages: Int(numberOfImages), length: Float(length), width: Float(width), configuration: configurationPicked)
        self.arHelper = arHelper
        self.arHelper?.getObjectsForConfigurations(pageNumber: selectedPageNumber, loadedHandler: { nodes in
            DispatchQueue.main.async {
                self.placeObjects.isEnabled = true
                self.nodes = nodes
            }
        })
        placeObjects.isEnabled = false
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
            for (index, node) in self.nodes.enumerated() {
                let pictureNode = node.childNode(withName: "picture", recursively: true)
                pictureNode?.name = "\(index)"
                pictureNode?.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "photo3")
            }
        } else {
            for nNode in self.nodes {
                self.sceneView.scene.rootNode.addChildNode(nNode)
            }
            sender.setTitle("Load Images", for: .normal)
        }
    }
    
    @IBAction func loadNextImages(_ sender: UIButton) {
        if ((self.arHelper?.getObjectsForConfigurations(pageNumber: selectedPageNumber + 1, loadedHandler: { nodes in
            DispatchQueue.main.async {
                self.placeObjects.isEnabled = true
                self.nodes = nodes
                for noteToDelete in self.nodes {
                    noteToDelete.removeFromParentNode()
                }
                
            }
        })) ?? false) {
            self.selectedPageNumber += 1
        }
    }
    
    @IBAction func loadPreviousImages(_ sender: UIButton) {
        for noteToDelete in self.nodes {
            noteToDelete.removeFromParentNode()
        }
        if ((self.arHelper?.getObjectsForConfigurations(pageNumber: selectedPageNumber - 1, loadedHandler: { nodes in
            DispatchQueue.main.async {
                self.placeObjects.isEnabled = true
                self.nodes = nodes
            }
        })) ?? false) {
            self.selectedPageNumber -= 1
        }
    }
}


extension GoParkViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if frame.camera.trackingState.recommendation == "TRACKING LIMITED" {
            configuration.isAutoFocusEnabled = false
            self.sceneView.session.run(configuration)
        }
    }
}
