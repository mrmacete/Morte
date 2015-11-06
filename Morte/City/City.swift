//
//  City.swift
//  Morte
//
//  Created by ftamagni on 24/03/15.
//  Copyright (c) 2015 morte. All rights reserved.
//

import SpriteKit
import GLKit


class City: NSObject {
    
    
    var maxBuildingWidth = 200.0
    var maxBuildingHeight = 700.0
    
    var minBuildingWidth = 100.0
    var minBuildingHeight = 300.0
    
    var buildingColor = UIColor.blackColor()
    
    var buildingShader = SKShader(fileNamed: "Building.fsh")

    
    let rootNode: SKNode
    let backgroundNode: SKSpriteNode
    let sceneSize: CGSize
    var layers = [String:SKNode]()
    
    var speed: Double = 600.0 {
        didSet {
            slowSpeed = speed / 10.0
        }
    }
    
    private var slowSpeed: Double
    private var lastTime: CFTimeInterval
    
    private var noiseTexture = SKTexture(imageNamed: "hardnoise")
    
    
    required init(fileName: String, rootNode: SKNode, nLayers: Int) {
        
        self.rootNode = rootNode
        
        self.sceneSize = rootNode.scene!.size
        
        if let cityScene = GameScene.unarchiveFromFile(fileName) {
            
            for node: SKNode in cityScene.children {
                
                rootNode.addChild(node.copy() as! SKNode)
                
            }
            
            backgroundNode = (cityScene as! SKScene).childNodeWithName("background_node") as! SKSpriteNode
            
        } else {
            backgroundNode = SKSpriteNode()
        }
        
        slowSpeed = speed / 10.0
        lastTime = 0
        
        super.init()
        
        rootNode.enumerateChildNodesWithName("//layer*", usingBlock: { (node:SKNode, boh:UnsafeMutablePointer<ObjCBool>) -> Void in
            
            self.layers[node.name!] = node
            
        })
        
        for z in 0..<nLayers {
            let layer = SKNode()
            
            rootNode.addChild(layer)
            
            layer.zPosition = CGFloat(-z-1);
            
            
            createSkyline(0, layer: layer, depth: Double(z)/Double(nLayers-1) )
        }

    }
    
    func createSkyline(startX: CGFloat = 0, layer: SKNode, depth: Double) {
        
        
        var x = CGFloat(startX)
        
        while ( x < sceneSize.width * 2.0 ){
            
            let building = createBuilding(depth)
            building.position.x = x
            
            layer.addChild(building)
            
            x += building.size.width
            
            x += CGFloat(arc4random_uniform(UInt32((minBuildingWidth/3.0) * 1000.0))) / 1000.0 * CGFloat(depth)
            
            x += CGFloat(arc4random_uniform(UInt32((minBuildingWidth/10.0) * 1000.0))) / 1000.0
            
            
            let slide = SKAction.moveToX(-building.size.width, duration:Double(x / depthToSpeed(depth)))
            
            building.runAction(SKAction.sequence([slide, SKAction.removeFromParent()]), completion: { () -> Void in
                
                self.checkAndRebuild(layer, depth: depth)
                
            })
            
        }
            
        
        
    }
    
    func depthToSpeed(depth: Double) -> CGFloat {
        let maxSpeed = speed / 5.0
        let minSpeed = speed / 50.0
        
        return CGFloat(minSpeed * depth + maxSpeed * (1.0 - depth))
    }
    
    func createBuilding(depth: Double = 0.0) -> SKSpriteNode {
        
        let h = Double(arc4random_uniform(UInt32((maxBuildingHeight - minBuildingHeight) * 1000.0))) / 1000.0 + minBuildingHeight
        let w = Double(arc4random_uniform(UInt32((maxBuildingWidth - minBuildingWidth) * (1.0-depth) * 1000.0))) / 1000.0 + minBuildingWidth * (1.0 - (depth * 0.5))
        
        
        let size = CGSizeMake(CGFloat(w), CGFloat(h * depth + (h/1.4) * (1.0-depth)))
        
        let building = SKSpriteNode(color: buildingColor, size: size)
        
        building.position.y = 0
        building.anchorPoint = CGPointZero
                
        building.shader = createBuildingShader(depth, size: size)
        
        
        building.color = backgroundNode.color.colorByMixingWith(building.color, blendFactor: CGFloat(depth*0.9))
        
        return building
    }
    
    func createBuildingShader(depth: Double, size: CGSize) -> SKShader {
        let shader = SKShader(fileNamed: "Building.fsh")
        let aspect = (Float(arc4random_uniform(1000)) / 1000.0 + 1.0)
        let sx = Float(20.0 * (1.0-depth*0.7))
        let sy = sx / aspect
                
        let subX = ceil(Float(size.width) / sx)
        let subY = ceil(Float(size.height) / sy)
        
        
        shader.uniforms = [
            SKUniform(name: "u_winPaddingX", float: 0.1),
            SKUniform(name: "u_winPaddingY", float: 0.1 / aspect),
            SKUniform(name: "u_winLightDim", float: Float(1.0-(depth * 0.7))),
            SKUniform(name: "u_noiseTexture", texture: noiseTexture),
            SKUniform(name: "u_seedX", float: Float(arc4random_uniform(1000)) / 1000.0),
            SKUniform(name: "u_seedY", float: Float(arc4random_uniform(1000)) / 1000.0),
            SKUniform(name: "u_subdivX", float: subX),
            SKUniform(name: "u_subdivY", float: subY),

        ]
        
        
        return shader
    }
    
    func update(currentTime: CFTimeInterval) {
        
        
    }
    
    func checkAndRebuild(layer: SKNode, depth: Double) {
        
        var maxRight = CGFloat(0.0)
        
        for child in layer.children {
            
            if let building = child as? SKSpriteNode {
                
                let right = building.position.x + building.size.width
                
                if right > maxRight {
                    maxRight = right
                }
            }
            
        }
        
        if maxRight <= sceneSize.width + CGFloat(maxBuildingWidth) {
            
            createSkyline(maxRight, layer: layer, depth: depth)
            
        }

    }
    
}
