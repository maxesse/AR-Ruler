//
//  ViewController.swift
//  AR Ruler
//
//  Created by Max Sanna on 13/03/2018.
//  Copyright © 2018 Max Sanna. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            if let hitResult = hitTestResults.first {
                addDot(at: hitResult)
            }
            
        }
    }
    
    func addDot(at hitResult : ARHitTestResult) {
        let dotGeometry = SCNSphere(radius: 0.005)
        let dotNode = SCNNode(geometry: dotGeometry)
        let dotMaterial = SCNMaterial()
        dotMaterial.diffuse.contents = UIColor.red
        dotGeometry.materials = [dotMaterial]
        dotNode.position = SCNVector3(x: hitResult.worldTransform.columns.3.x, y: hitResult.worldTransform.columns.3.y, z: hitResult.worldTransform.columns.3.z)

        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2 {
            calculate()
        }
    }
    
    func calculate() {
        let start = dotNodes[0]
        let end = dotNodes[1]
        print(start.position)
        print(end.position)
        
        let a = end.position.x - start.position.x
        let b = end.position.y - start.position.y
        let c = end.position.z - start.position.z
        
        let distance = sqrt(pow(a, 2) + pow(b, 2) + pow(c, 2))
        
        updateText(text: "\(distance)", atPosition: end.position)
        // distance = √ ((x2-x1)^2 + (y2-y1)^2 + (x2-x1)^2)
    }
    
    func updateText(text: String, atPosition position: SCNVector3) {
        textNode.removeFromParentNode()
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        textNode = SCNNode(geometry: textGeometry)
        if let camera = sceneView.pointOfView {
            textNode.orientation = camera.orientation
        }
        textNode.position = SCNVector3(x: position.x, y: position.y + 0.01, z: position.z)
        textNode.scale = SCNVector3(x: 0.01, y: 0.01, z: 0.01)
        sceneView.scene.rootNode.addChildNode(textNode)
    }
}
