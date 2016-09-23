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
                
                nextTimeInterval = calcNextObstacleTime(currentTime: currentTime)
            }
            
        } else {
            createObstacle()
            
            nextTimeInterval = calcNextObstacleTime(currentTime: currentTime)
        }
        
        
        
    }
    
    func calcNextObstacleTime(currentTime: CFTimeInterval) -> CFTimeInterval {
        return currentTime + 1.0/frequency + Double(arc4random_uniform(200000))/100000.0 - 1.0
    }
    
    func createObstacle() {
        
        let w = CGFloat(arc4random_uniform(maxHeight))/1000.0 + 20.0
        let h = CGFloat(arc4random_uniform(maxHeight))/1000.0 + 20.0
        
        let randSize = CGSize(width: w, height: h)
        
        let obstacle = SKSpriteNode(color: UIColor.lightGray, size: randSize)
        
        obstacle.anchorPoint = CGPoint.zero
        
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: randSize, center: CGPoint(x:randSize.width/2, y:randSize.height/2))
        obstacle.physicsBody!.affectedByGravity = false
        obstacle.physicsBody!.isDynamic = true
        obstacle.physicsBody!.usesPreciseCollisionDetection = true
        obstacle.physicsBody!.allowsRotation = false
        obstacle.physicsBody!.mass = 1000.0
        obstacle.physicsBody!.collisionBitMask = 2;
        obstacle.physicsBody!.categoryBitMask = 4;

        obstacle.position = CGPoint(x:sceneSize.width, y:0)
        obstacle.zRotation = 0
        
        
        rootNode.addChild(obstacle)
        
        let dur = Double(sceneSize.width) / speed
        
        obstacle.run(SKAction.sequence([SKAction.move(to: CGPoint(x:-randSize.width, y:0), duration: dur), SKAction.removeFromParent()]))
    }
}
