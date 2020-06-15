//
//  SinglePainitngViewController.swift
//  ARKitInteraction
//
//  Created by Ibrahim Hassan on 15/06/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit
import ARKit

class SinglePainitngViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    private let configuration = ARWorldTrackingConfiguration.init()
    
    var width: Float = 100.0
    var height: Float = 100.0
    
    private var lastRotation: Float = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configuration.isAutoFocusEnabled = false
        self.sceneView.session.run(configuration)
        dispatchAfter(duration: 0.4, after: {
            let helper = ARPlaceMenthelper()
            helper.getSinglePictureFrame { node in
                DispatchQueue.main.async {
                    node.scale = SCNVector3.init(x: self.width * Float(0.0254), y: self.height * Float(0.0254), z: 1.0)
                    guard let frame = self.sceneView.session.currentFrame else {
                        return
                    }
                    node.position = SCNVector3.init(0, 0, -1)
                    node.eulerAngles.y = (frame.camera.eulerAngles.y - Float(pie))
                    self.sceneView.scene.rootNode.addChildNode(node)
                }
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    //    private func addRotationGesture() {
    //        let panGesture = UIRotationGestureRecognizer(target: self, action: #selector(didRotate(_:)))
    //        self.sceneView.addGestureRecognizer(panGesture)
    //    }
    
    //    @objc func didRotate(_ gesture: UIRotationGestureRecognizer) {
    //        guard let node = selectedNode else { return }
    //        switch gesture.state {
    //        case .changed:
    //            // change node y angel
    //            node.eulerAngles.y = self.lastRotation + Float(gesture.rotation)
    //        case .ended:
    //            // save last rotation
    //            self.lastRotation += Float(gesture.rotation)
    //        default:
    //            break
    //        }
    //    }
}


func dispatchAfter(duration: Double, after: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: after)
}


