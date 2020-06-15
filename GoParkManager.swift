//
//  GoParkManager.swift
//  ARKitInteraction
//
//  Created by Ibrahim Hassan on 25/05/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation
import ARKit


let pie = CGFloat.pi

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
    
    var loadingIndex = 0
    private var numberOfPages = 1
    
    let colors = [UIColor.red, UIColor.green, UIColor.blue, UIColor.black, UIColor.gray, UIColor.white]
    
    func getSinglePictureFrame(loaded: @escaping (SCNNode) -> ()) {
        DispatchQueue.global(qos: .userInitiated).sync {
            if let node = ObjectLoaderHelper.getNode() {
                node.position = SCNVector3.init(1.0, 0, 1.0)
                loaded(node)
            }
        }
    }
    
    init() {}
    
    init(numberOfImages:Int, length: Float, width: Float, configuration: Int) {
        self.numberOfImages = numberOfImages
        self.length = length
        self.width = width
        if configuration == 0 {
            self.configuration = PlacementConfiguration.init(rawValue: 0) ?? PlacementConfiguration.center
        } else if configuration == 1 {
            self.configuration = PlacementConfiguration.init(rawValue: 1) ?? PlacementConfiguration.center
        } else if configuration == 2  {
            self.configuration = PlacementConfiguration.init(rawValue: 5) ?? PlacementConfiguration.center
        }
        
        var numberOfPagesTemp = getNumberOfPages()
        numberOfPagesTemp.round(.up)
        let val = numberOfPagesTemp.magnitude
        self.numberOfPages = Int(val)
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
        return angleToPlace / Float(getNumberOfImagesForPage())
    }
    
    @discardableResult func getObjectsForConfigurations(pageNumber: Int, loadedHandler: @escaping ([SCNNode]) -> Void) -> Bool {
        print (pageNumber)
        if !(pageNumber >= 0 && pageNumber <= self.numberOfPages) {
            return false
        }
        DispatchQueue.global(qos: .userInitiated).sync {
            var nodes: [SCNNode] = []
            let radius = self.getRadius()
            let angularPlacement = CGFloat(self.getAngualarPlacementAngle())
            var startingAngle : CGFloat = 0
            let scale = Float(self.getScaleMultiplier())
            if self.configuration == .center {
                startingAngle = 0
            } else if self.configuration.isQuarterConfiguration() {
                if self.configuration == .corner0Quarter {
                    startingAngle = 3 * pie / 2
                }else if self.configuration == .corner2Quarter {
                    startingAngle = 3 * pie / 2
                    //                    startingAngle = pie / 2
                } else if self.configuration == .corner1Quarter {
                    //                    startingAngle = 3 * pie / 2
                    startingAngle = pie
                } else if self.configuration == .corner3Quarter {
                    //                    startingAngle = 3 * pie / 2
                    startingAngle = pie
                }
            } else if self.configuration.isLineConfiguration() {
                if self.configuration == .side0Center {
                    startingAngle = pie
                } else if self.configuration == .side1Center {
                    startingAngle = pie
                } else if self.configuration == .side2Center {
                    startingAngle = pie
                } else if self.configuration == .side3Center {
                    startingAngle = pie
                }
            }
            
            for i in 0 ..< self.getNumberOfImagesForPage() {
                if let node = ObjectLoaderHelper.getNode() {
                    let backgroundNode = node.childNode(withName: "picture", recursively: true)
                    node.name = self.getNodeName(forPageNumber: pageNumber, index: i)
                    let theta = startingAngle + CGFloat(i) * angularPlacement
                    node.position = SCNVector3.init(radius * cos(theta), 0, radius * sin(theta))
                    var rotationAngle = theta
                    if (theta >= 0 && theta <= pie / 2) {
                        rotationAngle = pie / 2 - rotationAngle
                    } else if (theta >= pie / 2 && theta < pie) {
                        rotationAngle = -rotationAngle + .pi / 2
                    } else if (theta >= pie && theta < 3 * pie / 2) {
                        rotationAngle = -rotationAngle + (3 * pie / 2 + pie)
                    } else if (theta >= 3 * pie / 2 && theta < 2 * pie) {
                        rotationAngle = -rotationAngle + (3 * pie / 2 + pie)
                    }
                    
                    backgroundNode?.geometry?.firstMaterial?.diffuse.contents = colors[pageNumber % 6]
                    
                    node.eulerAngles.y = Float(rotationAngle)
                    node.scale = SCNVector3(x: scale, y: scale, z: scale)
                    nodes.append(node)
                }
            }
            loadedHandler(nodes)
        }
        return true
    }
    
    
    
    private func getNodeName(forPageNumber: Int, index: Int) -> String {
        return "\((forPageNumber * getNumberOfImagesForPage()) + index)"
    }
    
    private func getCircumference() -> CGFloat {
        var multiplier: CGFloat = 0
        if self.configuration.isLineConfiguration() {
            multiplier = 1
        } else if self.configuration.isQuarterConfiguration() {
            multiplier = 0.5
        } else {
            multiplier = 2
        }
        return (multiplier * pie * self.getRadius())
    }
    
    private func getScaleMultiplier() -> CGFloat {
        let scale: CGFloat = getCircumference() / (1.5 * CGFloat(self.getNumberOfImagesForPage()))
        if getNumberOfPages() > 1 {
            return 1.0
        }
        return scale
    }
    
    private func getNumberOfPages() -> CGFloat {
        return CGFloat(self.numberOfImages) / (getCircumference() / 1.5)
    }
    
    private func getNumberOfImagesForPage() -> Int {
        self.numberOfImages / self.numberOfPages
    }
    
}

class ObjectLoaderHelper {
    static var scenePath = "Models.scnassets/box.scn"
    static func getNode() -> SCNNode? {
        let modelsURL = Bundle.main.url(forResource: scenePath, withExtension: nil)!
        guard let subscene = try? SCNScene(url: modelsURL, options: nil) else { return nil }
        if let node = subscene.rootNode.childNode(withName: "painting", recursively: true) {
            return node
        }
        return nil
    }
}

func rad2deg(_ number: CGFloat) -> CGFloat {
    return number * 180 / CGFloat.pi
}
