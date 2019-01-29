//
//  ViewController.swift
//  Plane Detection
//
//  Created by Dmitry Novosyolov on 28/01/2019.
//  Copyright © 2019 Dmitry Novosyolov. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        // Switch the light on
        sceneView.autoenablesDefaultLighting = true
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = [.horizontal, .vertical]
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func createFloor (anchor: ARPlaneAnchor) -> SCNNode {
        let node = SCNNode()
        
        let extent = anchor.extent
        
        let geometry = SCNPlane(width: CGFloat(extent.x),
                                height: CGFloat(extent.z))
        geometry.firstMaterial?.diffuse.contents = UIColor.blue
        node.geometry = geometry
        
        node.eulerAngles.x = -.pi / 2
        node.opacity = 0.25
        
        return node
    }
    
    func createWall (anchor: ARPlaneAnchor) -> SCNNode {
        let node = SCNNode()
        
        let extent = anchor.extent
        
        let geometry = SCNPlane(width: CGFloat(extent.x),
                                height: CGFloat(extent.z))
        geometry.firstMaterial?.diffuse.contents = UIColor.red
        node.geometry = geometry
        
        node.eulerAngles.x = -.pi / 2
        node.opacity = 0.25
        
        return node
    }
    
    func createCampus (anchor: ARPlaneAnchor) -> SCNNode {
        let node = SCNScene(named: "art.scnassets/Campus.scn")!
            .rootNode.clone()
        
        let center = anchor.center
        node.position = SCNVector3(center.x, 0, center.y)
        
        return node
    }
    
}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer:
        SCNSceneRenderer,
                  didAdd node: SCNNode,
                  for anchor: ARAnchor) {
        guard let anchor = anchor as?
            ARPlaneAnchor else { return }
        
        let floor = createFloor(anchor: anchor)
        let wall = createWall(anchor: anchor)
        let ship = createCampus(anchor: anchor)
        node.addChildNode(ship)
        
        // Find plane position )))
        switch anchor.alignment {
        case .horizontal:
            node.addChildNode(floor)
            print(#function, "horizontal")
        case .vertical:
            node.addChildNode(wall)
            print(#function, "vertical")
        default:
            print("not detected...")
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer,
                  didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else { return }
        guard let node = node.childNodes.first else { return }
        
        node.position.x = anchor.center.x
        node.position.y = anchor.center.y
        node.position.z = anchor.center.z
        
        guard let plane = node.geometry as? SCNPlane else { return }
        
        let extent = anchor.extent
        plane.width = CGFloat(extent.x)
        plane.height = CGFloat(extent.z)
    }
}
