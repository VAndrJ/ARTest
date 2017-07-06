//
//  SpaceShip.swift
//  ARTest
//
//  Created by VAndrJ on 6/25/17.
//  Copyright © 2017 VAndrJ. All rights reserved.
//

import ARKit

class Ball: SCNNode {
    func loadModel(isParent: Bool? = false) {
        let sphere = SCNSphere(radius: (isParent! ? 0.06 : 0.04))
        let wrapperNode = SCNNode(geometry: sphere)
        if isParent! {
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.gray
            sphere.firstMaterial = material
            wrapperNode.light = SCNLight()
            wrapperNode.light?.type = .spot
            wrapperNode.castsShadow = true
        }
        self.addChildNode(wrapperNode)
    }
}
