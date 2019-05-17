# Placing Objects and Handling 3D Interaction

Place virtual content on real-world surfaces, and enable the user to interact with virtual content by using gestures. 

## Overview

The key facet of an AR experience is the ability to intermix virtual and real-world objects. A flat surface is the optimum location for setting a virtual object. To assist ARKit with finding surfaces, you tell the user to move their device in ways that help ARKit initialize the session. ARKit provides a view that tailors its instructions to the user for you, guiding them to the surface that your app needs. 

To enable the user to put a virtual item on the real-world surface when they tap the screen, ARKit incorporates ray casting, which provides a 3D location in physical space that corresponds to the screen's touch location. If the user wants to rotate or otherwise move the virtual items they place, you respond to the respective touch gestures and correlate that input to the virtual content's look in the physical environment. 

- Note: ARKit requires a device with an A9 or later processor. ARKit is not available in iOS Simulator.

## Set a Goal to Coach the User's Movement

To enable your app to detect real-world surfaces, you use a world tracking configuration. For ARKit to establish tracking, the user must physically move their device to allow ARKit to get a sense of perspective. To communicate this need to the user, you use a view provided by ARKit that presents the user with instructional diagrams and verbal guidance, called [ARCoachingOverlayView][1]. For example, when you start the app, the first thing the user sees is a message and animation from the coaching overlay telling them to move their device left and right, repeatedly, in order to get started. 

To enable the user to place virtual content on a horizontal surface, you set the coaching overlay goal accordingly. 

``` swift
func setGoal() {
    coachingOverlay.goal = .horizontalPlane
}
```
[View in Source](x-source-tag://CoachingGoal)

The coaching overlay then tailors its instructions according to the goal you choose. After ARKit gets a sense of perspective, the coaching overlay instructs the user to find a surface. 

## Respond to Coaching Events

To make sure the coaching overlay provides guidance to the user whenever ARKit determines it's necessary, you set [`activatesAutomatically`][6] to `true`. 

``` swift
func setActivatesAutomatically() {
    coachingOverlay.activatesAutomatically = true
}
```
[View in Source](x-source-tag://CoachingActivatesAutomatically)

The coaching overlay activates automatically when the app starts, or when tracking degrades past a certain threshold. In those situations, ARKit notifies your delegate by calling [`coachingOverlayViewWillActivate`][7]. In response to this event, hide your app's UI to enable the user to focus on the instructions that the coaching overlay provides. 

``` swift
func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
    upperControlsView.isHidden = true
}
```
[View in Source](x-source-tag://HideUI)

When the coaching overlay determines that the goal has been met, it disappears from the user's view. ARKit notifies your delegate that the coaching process has ended, which is when you show your app's main user interface. 

``` swift
func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
    upperControlsView.isHidden = false
}
```
[View in Source](x-source-tag://PresentUI)

## Place Virtual Content

To give the user an idea of where they can place virtual content, annotate the environment to give them a preview. The sample app draws a square that gives the user visual confirmation of the shape and alignment of the surfaces that ARKit is aware of.  

To figure out where to put the square in the real world, you use an [ARRaycastQuery][2] to ask ARKit where any surfaces exist in the real world. First, you create a ray-cast query that defines the 2D point on the screen you're interested in. Because the focus square is aligned with the center of the screen, you create a query for the screen center.  

``` swift
func getRaycastQuery() -> ARRaycastQuery? {
    return sceneView.raycastQuery(from: screenCenter, allowing: .estimatedPlane, alignment: .any)
}
```
[View in Source](x-source-tag://GetRaycastQuery)

Then, you execute the ray-cast query by asking the session to cast it. 

``` swift
func getTrackedRaycast(_ query: ARRaycastQuery, virtualObject: VirtualObject) -> ARTrackedRaycast? {
    return session.trackedRaycast(query) { (results) in
        self.setVirtualObject3DPosition(results, with: virtualObject)
    }
}
```
[View in Source](x-source-tag://GetTrackedRaycast)

ARKit returns a position in the `results` parameter that includes the depth of where that point lies on a surface in the real world, and how the surface is angled with respect to gravity. That information is wrapped in the ray cast result's [`worldTransform`][16], which you set on your virtual object's [`simdWorldTransform`][15] to effectively place your virtual object in the physical environment.

``` swift
func setPosition(of virtualObject: VirtualObject, with result: ARRaycastResult) {
    virtualObject.simdWorldTransform = result.worldTransform
}
```
[View in Source](x-source-tag://Set3DPosition)

If your app offers different types of virtual content, give the user an interface to choose from. The sample app exposes a selection menu when the user taps the plus button. When the user chooses an item from the list, you instantiate the corresponding 3D model and anchor it in the world at the focus square's current position. 

``` swift
func placeVirtualObject(_ virtualObject: VirtualObject) {
    guard focusSquare.state != .initializing,
    let query = sceneView.raycastQuery(from: screenCenter, allowing: .estimatedPlane, alignment: virtualObject.allowedAlignment) else {
        self.statusViewController.showMessage("CANNOT PLACE OBJECT\nTry moving left or right.")
        if let controller = self.objectsViewController {
            self.virtualObjectSelectionViewController(controller, didDeselectObject: virtualObject)
        }
        return
    }
    
    virtualObject.raycast = getTrackedRaycast(query, virtualObject: virtualObject)
    virtualObjectInteraction.selectedObject = virtualObject
}
```
[View in Source](x-source-tag://PlaceVirtualObject)

## Refine the Position of Virtual Content Over Time

As the session runs, ARKit analyzes each camera image and learns more about the layout of the physical environment. When ARKit updates its estimated size, shape, and position of real-world planes, you may need to update the position of your app's virtual content. Opt in to notification of these events by creating an [ARTrackedRaycast][3], and providing a ray-cast query that tells ARKit which updates you're interested in. 

``` swift
func getTrackedRaycast(_ query: ARRaycastQuery, virtualObject: VirtualObject) -> ARTrackedRaycast? {
    return session.trackedRaycast(query) { (results) in
        self.setVirtualObject3DPosition(results, with: virtualObject)
    }
}
```
[View in Source](x-source-tag://GetTrackedRaycast)

As ARKit repeats your ray-cast query, it gives you the results only when they differ from prior results. Pass a closure to the [`trackedRaycast`][8] to define your response to these events, where you update the position of your app's virtual content accordingly. 

``` swift
func setVirtualObject3DPosition(_ results: [ARRaycastResult], with virtualObject: VirtualObject) {
    guard let result = results.first else {
        fatalError("Unexpected case: the update handler is always supposed to return at least one result.")
    }
    
    if virtualObject.allowedAlignment == .any && self.virtualObjectInteraction.trackedObject == virtualObject {
        
        // If an object that's aligned to a surface is being dragged, then
        // smoothen its orientation to avoid visible jumps, and apply only the translation directly.
        virtualObject.simdWorldPosition = result.worldTransform.translation
        
        let previousOrientation = virtualObject.simdWorldTransform.orientation
        let currentOrientation = result.worldTransform.orientation
        virtualObject.simdWorldOrientation = simd_slerp(previousOrientation, currentOrientation, 0.1)
    } else {
        self.setPosition(of: virtualObject, with: result)
    }
    
    // If the virtual object is not yet in the scene, add it.
    if virtualObject.parent == nil {
        self.sceneView.scene.rootNode.addChildNode(virtualObject)
        virtualObject.shouldUpdateAnchor = true
    }
    
    if virtualObject.shouldUpdateAnchor {
        virtualObject.shouldUpdateAnchor = false
        self.updateQueue.async {
            self.sceneView.addOrUpdateAnchor(for: virtualObject)
        }
    }
}
```
[View in Source](x-source-tag://ProcessRaycastResults)

- Note: If you don't need to continue to improve the position of your app's virtual content as ARKit refines its model of the world, execute a one time query via [`raycast(_:)`][9] instead of using a tracked ray cast.

## Manage Tracked Ray Casts

Because ARKit continues to call them, tracked ray casts can increasingly consume resources with the more virtual content a user places. Stop the tracked ray cast when you're satisfied with its associated virtual object's position, or when you remove the virtual object from your scene.

``` swift
func removeVirtualObject(at index: Int) {
    guard loadedObjects.indices.contains(index) else { return }
    
    loadedObjects[index].removeFromParentNode()
    loadedObjects[index].raycast?.stopTracking()
    loadedObjects[index].raycast = nil
    loadedObjects[index].unload()
    loadedObjects.remove(at: index)
}
```
[View in Source](x-source-tag://RemoveVirtualObject)

## Enable User Interaction with Virtual Content

To allow users to move virtual content in the world after they've placed it, implement a pan gesture recognizer. 

``` swift
func createPanGestureRecognizer(_ sceneView: VirtualObjectARView) {
    let panGesture = ThresholdPanGesture(target: self, action: #selector(didPan(_:)))
    panGesture.delegate = self
    sceneView.addGestureRecognizer(panGesture)
}
```
[View in Source](x-source-tag://CreatePanGesture)

When you move a virtual object, you keep the object subscribed for positional updates from ARKit by updating its tracked ray cast with a new query. 

``` swift
func translate(_ object: VirtualObject, basedOn screenPos: CGPoint) {
    if let query = sceneView.raycastQuery(from: screenPos, allowing: .estimatedPlane, alignment: object.allowedAlignment) {
        object.raycast?.update(query)
    }
}
```
[View in Source](x-source-tag://DragVirtualObject)

Ray casting gives you orientation information about the surface at a given screen point. While dragging, you avoid quick changes in orientation by subtracting the gesture's rotation from the current object rotation. 

``` swift
@objc
func didRotate(_ gesture: UIRotationGestureRecognizer) {
    guard gesture.state == .changed else { return }
    
    trackedObject?.objectRotation -= Float(gesture.rotation)
    
    gesture.rotation = 0
}
```
[View in Source](x-source-tag://DidRotate)

## Handle Interruption in Tracking

In cases where tracking conditions are poor, ARKit invokes your delegate's [`sessionWasInterrupted(_:)`][5]. In these circumstances, the positions of your app's virtual content may be inaccurate with respect to the camera feed, so you hide your virtual content. 

``` swift
func hideVirtualContent() {
    virtualObjectLoader.loadedObjects.forEach { $0.isHidden = true }
}
```
[View in Source](x-source-tag://HideVirtualContent)

Restore your app's virtual content when tracking conditions improve. To notify you of improved conditions, ARKit calls your delegate's [`session(_:,cameraDidChangeTrackingState:)`][10] function, passing in a camera [`trackingState`][11] equal to [`normal`][12].  

``` swift
func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    statusViewController.showTrackingQualityInfo(for: camera.trackingState, autoHide: true)
    switch camera.trackingState {
    case .notAvailable, .limited:
        statusViewController.escalateFeedback(for: camera.trackingState, inSeconds: 3.0)
    case .normal:
        statusViewController.cancelScheduledMessage(for: .trackingStateEscalation)
        showVirtualContent()
    }
}
```
[View in Source](x-source-tag://ShowVirtualContent)

## Restore an Interrupted AR Experience

When a session is interrupted, ARKit asks if you want to try to restore the AR experience. You do that by opting in to *relocalization*, by overriding [`sessionShouldAttemptRelocalization(_:)`][13] and returning `true`. 

``` swift
func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
    return true
}
```
[View in Source](x-source-tag://Relocalization)

During relocalization, the coaching overlay displays tailored instructions to the user. To allow the user to focus on the coaching process, hide your app's UI when coaching is enabled. 

``` swift
func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
    upperControlsView.isHidden = true
}
```
[View in Source](x-source-tag://HideUI)

When ARKit succeeds in restoring the experience, show your app's UI again so everything appears the way it was before the interruption. When the coaching overlay disappears from the user's view, ARKit invokes your [`coachingOverlayViewDidDeactivate(_:)`][14] callback, which is where you restore your app's UI. 

``` swift
func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
    upperControlsView.isHidden = false
}
```
[View in Source](x-source-tag://PresentUI)

## Enable the User to Start Over Rather Than Restore

If the user decides to give up on restoring the session, you restart the experience in your delegate's [coachingOverlayViewDidRequestSessionReset(_:)][4] function. ARKit invokes this callback when the user taps the coaching overlay's Start Over button. 

``` swift
func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
    restartExperience()
}
```
[View in Source](x-source-tag://StartOver)

[1]:https://developer.apple.com/documentation/arkit/arcoachingoverlayview
[2]:https://developer.apple.com/documentation/arkit/arraycastquery
[3]:https://developer.apple.com/documentation/arkit/artrackedraycast
[4]:https://developer.apple.com/documentation/arkit/arcoachingoverlayviewdelegate/3192182-coachingoverlayviewdidrequestses
[5]:https://developer.apple.com/documentation/arkit/arsessionobserver/2891620-sessionwasinterrupted
[6]:https://developer.apple.com/documentation/arkit/arcoachingoverlayview/3152976-activatesautomatically
[7]:https://developer.apple.com/documentation/arkit/arcoachingoverlayviewdelegate/3152985-coachingoverlayviewwillactivate
[8]:https://developer.apple.com/documentation/arkit/arsession/3132066-trackedraycast
[9]:https://developer.apple.com/documentation/arkit/arsession/3132065-raycast
[10]:https://developer.apple.com/documentation/arkit/arsessionobserver/2887450-session
[11]:https://developer.apple.com/documentation/arkit/arcamera/2880259-trackingstate
[12]:https://developer.apple.com/documentation/arkit/artrackingstate/artrackingstatenormal
[13]:https://developer.apple.com/documentation/arkit/arsessionobserver/2941046-sessionshouldattemptrelocalizati
[14]:https://developer.apple.com/documentation/arkit/arcoachingoverlayviewdelegate/3152983-coachingoverlayviewdiddeactivate
[15]:https://developer.apple.com/documentation/scenekit/scnnode/2881868-simdworldtransform
[16]:https://developer.apple.com/documentation/arkit/arraycastresult/3132062-worldtransform