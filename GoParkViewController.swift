//
//  GoParkViewController.swift
//  ARKitInteraction
//
//  Created by Ibrahim Hassan on 25/05/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import ARKit
import WebKit

class GoParkViewController: UIViewController, ARCoachingOverlayViewDelegate {
    
    @IBOutlet weak var placeObjects: UIButton!
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    let coachingOverlay = ARCoachingOverlayView()
    
    private var nodes: [SCNNode] = []
    
    private let webView = WKWebView(frame: .zero)
    
    var length : CGFloat = 0.0
    var width : CGFloat = 0.0
    var numberOfImages : CGFloat = 0.0
    
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
        
//        guard sender.state == .began else { return }
        for result in results.filter( { $0.node.name != nil }) {
            print(result.node.name)
            if (result.node.name == "0" || result.node.name == "1" || result.node.name == "2" || result.node.name == "3") {
                self.webView.isHidden = false
                /*
                 UIView.transition(with: button, duration: 0.4,
                 options: .transitionCrossDissolve,
                 animations: {
                 button.hidden = false
                 })
                 */
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.isHidden = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.webView)
        // You can set constant space for Left, Right, Top and Bottom Anchors
        NSLayoutConstraint.activate([
            self.webView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.webView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.webView.topAnchor.constraint(equalTo: self.view.topAnchor),
        ])
        // For constant height use the below constraint and set your height constant and remove either top or bottom constraint
        //self.webView.heightAnchor.constraint(equalToConstant: 200.0),
        
        self.view.setNeedsLayout()
        let request = URLRequest(url: URL.init(string: "https://www.google.com")!)
        self.webView.load(request)
        
        registerGestureRecognizer()
        let configuration = ARWorldTrackingConfiguration()
        self.sceneView.session.run(configuration)
        let arHelper = ARPlaceMenthelper.init(numberOfImages: Int(numberOfImages), length: Float(length), width: Float(width), configuration: PlacementConfiguration.center.rawValue)
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
            for (index, node) in self.nodes.enumerated() {
                let pictureNode = node.childNode(withName: "picture", recursively: true)
                pictureNode?.name = "\(index)"
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
