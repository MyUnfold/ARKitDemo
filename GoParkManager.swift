//
//  GoParkManager.swift
//  ARKitInteraction
//
//  Created by Ibrahim Hassan on 25/05/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import ARKit

enum PlacementConfiguration : Int {
    
    
    case center = 0, corner0Quarter, corner1Quarter, corner2Quarter, corner3Quarter, side0Center, side1Center, side2Center, side3Center
    
    func isQuarterConfiguration() -> Bool {
        if 1...4 ~= self.rawValue {
            return true
        } else {
            return false
        }
    }
    
    func isLineConfiguration() -> Bool {
        if 5...8 ~= self.rawValue {
            return true
        } else {
            return false
        }
    }
    
}

class ARPlaceMenthelper {
    
    var numberOfImages = 0
    var length: Float = 0.0
    var width: Float = 0.0
    var configuration = PlacementConfiguration.center
    
    let colors = [UIColor.red, UIColor.green, UIColor.blue, UIColor.black, UIColor.gray, UIColor.white]
    
    init(numberOfImages:Int, length: Float, width: Float, configuration: Int) {
        self.numberOfImages = numberOfImages
        self.length = length
        self.width = width
        self.configuration = PlacementConfiguration.init(rawValue: configuration) ?? PlacementConfiguration.center
    }
    
    func getRadius() -> CGFloat {
        var smallerSide = min(length, width)
        if configuration == .center {
            smallerSide /= 2
        } else if configuration.isQuarterConfiguration() {
            return CGFloat(smallerSide)
        } else if configuration.isLineConfiguration() {
            return CGFloat(smallerSide)
        }
        return CGFloat(smallerSide)
    }
    
    func getAngualarPlacementAngle() -> Float {
        var angleToPlace = Float.pi
        if configuration.isQuarterConfiguration() {
            angleToPlace /= 2
        } else if configuration == .center {
            angleToPlace *= 2
        }
        return angleToPlace / Float(numberOfImages)
    }
    
    func getObjectsForConfigurations(loadedHandler: @escaping ([SCNNode]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let radius = self.getRadius()
            let angularPlacement = CGFloat(self.getAngualarPlacementAngle())
            var nodes: [SCNNode] = []
            for i in 0 ..< self.numberOfImages {
                if let node = ObjectLoaderHelper.getNode() {
                    let theta = CGFloat(i) * angularPlacement
                    node.position = SCNVector3.init(radius * cos(theta), 0, radius * sin(theta))
                    var rotationAngle = theta
                    if (theta >= 0 && theta < pie / 2) {
                        rotationAngle = pie / 2 - rotationAngle
                        node.geometry?.firstMaterial?.diffuse.contents = self.colors[0]
                    } else if (theta >= pie / 2 && theta < pie) {
                        rotationAngle = pie / 2 - rotationAngle
                        node.geometry?.firstMaterial?.diffuse.contents = self.colors[1]
                    } else if (theta >= pie && theta <= 3 * pie / 2) {
                        rotationAngle = rotationAngle - pie
                        node.geometry?.firstMaterial?.diffuse.contents = self.colors[2]
                    } else if (theta >= 3 * pie / 2 && theta < 2 * pie) {
                        rotationAngle = rotationAngle - pie
                        node.geometry?.firstMaterial?.diffuse.contents = self.colors[3]
                    }
                    node.eulerAngles.y = Float(rotationAngle)
                    nodes.append(node)
                }
            }
            loadedHandler(nodes)
        }
    }
}

class ObjectLoaderHelper {
    static var scenePath = "Models.scnassets/box.scn"
    static func getNode() -> SCNNode? {
        let modelsURL = Bundle.main.url(forResource: scenePath, withExtension: nil)!
        guard let subscene = try? SCNScene(url: modelsURL, options: nil) else { return nil }
        if let node = subscene.rootNode.childNode(withName: "box", recursively: true) {
            return node
        }
        return nil
    }
}

let pie = CGFloat.pi
