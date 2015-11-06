//
//  Obstacles.swift
//  Morte
//
//  Created by ftamagni on 23/03/15.
//  Copyright (c) 2015 morte. All rights reserved.
//

import SpriteKit

class Obstacles: NSObject {
    
    let rootNode: SKNode
    let sceneSize: CGSize
    
    var frequency = 0.5
    var maxHeight: UInt32 = 200000
    var speed = 600.0
    
    var nextTimeInterval: CFTimeInterval!
    var lastTime: CFTimeInterval!
    
    
    init(rootNode: SKNode) {
        
        self.rootNode = rootNode
        
        self.sceneSize = rootNode.scene!.size
        
        super.init()
    }
    
    func update(currentTime: CFTimeInterval) {
        
        if let next = nextTimeInterval {
            
            if next <= currentTime {
                createObstacle()
                
                nextTimeInterval = calcNextObstacleTime(currentTime)
            }
            
        } else {
            createObstacle()
            
            nextTimeInterval = calcNextObstacleTime(currentTime)
        }
        
        
        
    }
    
    func calcNextObstacleTime(currentTime: CFTimeInterval) -> CFTimeInterval {
        return currentTime + 1.0/frequency + Double(arc4random_uniform(200000))/100000.0 - 1.0
    }
    
    func createObstacle() {
        
        let w = CGFloat(arc4random_uniform(maxHeight))/1000.0 + 20.0
        let h = CGFloat(arc4random_uniform(maxHeight))/1000.0 + 20.0
        
        let randSize = CGSizeMake(w, h)
        
        let obstacle = SKSpriteNode(color: UIColor.lightGrayColor(), size: randSize)
        
        obstacle.anchorPoint = CGPointZero
        
        obstacle.physicsBody = SKPhysicsBody(rectangleOfSize: randSize, center: CGPointMake(randSize.width/2, randSize.height/2))
        obstacle.physicsBody!.affectedByGravity = false
        obstacle.physicsBody!.dynamic = true
        obstacle.physicsBody!.usesPreciseCollisionDetection = true
        obstacle.physicsBody!.allowsRotation = false
        obstacle.physicsBody!.mass = 1000.0
        obstacle.physicsBody!.collisionBitMask = 2;
        obstacle.physicsBody!.categoryBitMask = 4;

        obstacle.position = CGPointMake(sceneSize.width, 0)
        obstacle.zRotation = 0
        
        
        rootNode.addChild(obstacle)
        
        let dur = Double(sceneSize.width) / speed
        
        obstacle.runAction(SKAction.sequence([SKAction.moveTo(CGPointMake(-randSize.width, 0), duration: dur), SKAction.removeFromParent()]))
    }
}
