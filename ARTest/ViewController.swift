//
//  ViewController.swift
//  ARTest
//
//  Created by VAndrJ on 6/25/17.
//  Copyright © 2017 VAndrJ. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSessionDelegate {
    
    let parentBall = Ball()
    var timer: Timer?
    
    @IBOutlet weak var sceneView: ARSCNView! {
        didSet {
            let scenes = SCNScene()
            sceneView.scene = scenes
            sceneView.showsStatistics = true
            sceneView.scene.rootNode.light = SCNLight()
            sceneView.scene.rootNode.light?.type = .directional
            sceneView.session.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingSessionConfiguration()
        sceneView.session.run(configuration)
        parentBall.loadModel(isParent: true)
        sceneView.scene.rootNode.addChildNode(parentBall)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        addBall()
    }
    
    func addBall() {
        let childBall = Ball()
        childBall.loadModel()
        if let cameraPosition = sceneView.session.currentFrame?.camera.transform {
            childBall.simdTransform = getParentPosition(from: cameraPosition)
            sceneView.scene.rootNode.addChildNode(childBall)
            pushBall(childBall)
        }
    }
    
    func pushBall(_ ball: SCNNode) {
        let action = SCNAction.move(by: randomPushVector3(), duration: 1)
        ball.runAction(action)
    }
    
    // MARK: Position helpers
    
    func getParentPosition(from cameraPosition: simd_float4x4, unstable isUnstable: Bool? = false) -> simd_float4x4 {
        var translation = matrix_identity_float4x4
        let bound: Float = 0.01
        if isUnstable! {
            translation.columns.3.z = randomPosition(lowerBound: -bound, upperBound: bound)
            translation.columns.3.x = randomPosition(lowerBound: -bound, upperBound: bound)
            translation.columns.3.y = randomPosition(lowerBound: -bound, upperBound: bound)
        }
        translation.columns.3.z -= 2
        return matrix_multiply(cameraPosition, translation)
    }
    
    func randomPushVector3() -> SCNVector3 {
        let bound: Float = 1
        let x = randomPosition(lowerBound: -bound, upperBound: bound)
        let y = randomPosition(lowerBound: -bound, upperBound: bound)
        let z = randomPosition(lowerBound: -bound, upperBound: bound)
        return SCNVector3Make(x, y, z)
    }
    
    func randomPosition(lowerBound lower: Float, upperBound upper: Float) -> Float {
        return Float(arc4random()) / Float(UInt32.max) * (lower - upper) + upper
    }
    
    // MARK: Actions
    
    @IBAction func swAutoChange(_ sender: UISwitch) {
        if sender.isOn {
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { [weak self] _ in
                self?.addBall()
            })
        } else {
            timer?.invalidate()
        }
    }
    
    @IBAction func buttonResetClick(_ sender: UIButton) {
        for child in sceneView.scene.rootNode.childNodes {
            child.removeFromParentNode()
        }
        sceneView.scene.rootNode.addChildNode(parentBall)
    }
    
    // MARK: ARSessionDelegate
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if let cameraPosition = sceneView.session.currentFrame?.camera.transform {
            parentBall.simdTransform = getParentPosition(from: cameraPosition, unstable: true)
        }
    }
}

