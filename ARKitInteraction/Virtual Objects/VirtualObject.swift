/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A `SCNReferenceNode` subclass for virtual objects placed into the AR scene.
*/

import Foundation
import SceneKit
import ARKit

protocol AudioTapped: class {
    func audioButtonTapped(url: String)
}

class VirtualObject: SCNNode {
    
    /// The model name derived from the `referenceURL`.
//    var modelName: String {
//        return referenceURL.lastPathComponent.replacingOccurrences(of: ".scn", with: "")
//    }
        
    private var audioUrl: String?
    
    func set(image: UIImage?, text: String?, audio: String?) {
        audioUrl = audio
        let childrenNodes = self.childNodes
        for child in childNodes {
            for subChilden in child.childNodes {
                if subChilden.name == "frame" {
                    let frameChildren = subChilden.childNodes
                    for c in frameChildren {
                        if c.name == "picture" {
                            c.geometry?.firstMaterial?.diffuse.contents = image
                        }
                    }
                }
                if subChilden.name == "painting" {
                    let frameChildren = subChilden.childNodes
                    print (frameChildren)
                    for c in frameChildren {

                        if let text = c.geometry as? SCNText {
                            text.isWrapped = true
                            text.containerFrame = CGRect.init(x: 0, y: 0, width: 200, height: 50)
                            text.string = "Hello world"//text ?? ""
                        }
                    }
                }
            }
        }
    }
    
    /// The alignments that are allowed for a virtual object.
    
    /// Rotates the first child node of a virtual object.
    /// - Note: For correct rotation on horizontal and vertical surfaces, rotate around
    /// local y rather than world y.
    var objectRotation: Float {
        get {
            return childNodes.first!.eulerAngles.y
        }
        set (newValue) {
            childNodes.first!.eulerAngles.y = newValue
        }
    }
    
    /// The object's corresponding ARAnchor.
    var anchor: ARAnchor?

    /// The raycast query used when placing this object.
    var raycastQuery: ARRaycastQuery?
    
    /// The associated tracked raycast used to place this object.
    var raycast: ARTrackedRaycast?
    
    /// The most recent raycast result used for determining the initial location
    /// of the object after placement.
    var mostRecentInitialPlacementResult: ARRaycastResult?
    
    /// Flag that indicates the associated anchor should be updated
    /// at the end of a pan gesture or when the object is repositioned.
    var shouldUpdateAnchor = false
    
    /// Stops tracking the object's position and orientation.
    /// - Tag: StopTrackedRaycasts
    func stopTrackedRaycast() {
        raycast?.stopTracking()
        raycast = nil
    }
}

extension VirtualObject {
    // MARK: Static Properties and Methods
    /// Loads all the model objects within `Models.scnassets`.
    
    func makeObject() {
        let baseObject = SCNBox.init(width: 1, height: 1, length: 0.025, chamferRadius: 0)
        baseObject.firstMaterial?.diffuse.contents = UIColor.clear
        let boxNode = SCNNode.init(geometry: baseObject)
        
    }
    
    static func getObjects(forData: [VirtualObjectData]) -> [VirtualObject] {
        let object = VirtualObject.availableObject
        var objectCollection: [VirtualObject] = []
        for data in forData {
            object.set(image: data.image, text: data.text, audio: data.audioUrl)
            objectCollection.append(object)
        }
        return objectCollection
    }
    
    private static let availableObject: VirtualObject = {
//        let modelsURL = Bundle.main.url(forResource: "Models.scnassets", withExtension: nil)!
//
//        let fileEnumerator = FileManager().enumerator(at: modelsURL, includingPropertiesForKeys: [])!
//
//        return fileEnumerator.compactMap { element in
//            let url = element as! URL
//
//            guard url.pathExtension == "scn" && !url.path.contains("lighting") else { return nil }
//            return VirtualObject(url: url)
//        }
        let object = VirtualObject.init()
        object.addChildNode(SCNScene(named: "Models.scnassets/painting1/painting.scn")!.rootNode)
        return object
    }()
    
    /// Returns a `VirtualObject` if one exists as an ancestor to the provided node.
    static func existingObjectContainingNode(_ node: SCNNode) -> VirtualObject? {
        if let virtualObjectRoot = node as? VirtualObject {
            return virtualObjectRoot
        }
        
        guard let parent = node.parent else { return nil }
        
        // Recurse up to check if the parent is a `VirtualObject`.
        return existingObjectContainingNode(parent)
    }
}

class VirtualObjectData {
    
    var image: UIImage?
    var text: String?
    var audioUrl: String?
    
    init(image: UIImage?, text:String?, audioUrl: String?) {
        self.image = image
        self.text = text
        self.audioUrl = audioUrl
    }
}
