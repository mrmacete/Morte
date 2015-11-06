//
//  UgoRobot.swift
//  Morte
//
//  Created by ftamagni on 18/03/15.
//  Copyright (c) 2015 morte. All rights reserved.
//

import SpriteKit

private let dismemberingDuration = 0.5


protocol UgoRobotDelegate: class {
    func robotDead(robot: UgoRobot);
    func robotDidFly(robot: UgoRobot, flyTime: Double);
}

class UgoRobot: NSObject {
    
    var sensitivity: CGFloat = 3.0
    
    var root: SKNode
    
    var torso: SKNode!
    
    var arm_hand_right: SKNode!
    var arm_root_right: SKNode!
    
    var arm_hand_left: SKNode!
    var arm_root_left: SKNode!
    
    var leg_root_right: SKNode!
    var leg_foot_right: SKNode!
    
    var leg_root_left: SKNode!
    var leg_foot_left: SKNode!
    
    var skate: SKNode!
    var left_foot_socket: SKNode!
    var right_foot_socket: SKNode!
    
    var startPosition = CGPointZero
    var startSkatePosition = CGPointZero
    
    var dismembering = false
    
    weak var delegate: UgoRobotDelegate?
    
    var flying = false
    var flyingStartTime: NSDate?
    var flyTotalTime = 0.0
    
    var autoStopTimer: NSTimer?
    
    var t = 0.0
    
   
    required init(fileName: String) {
        
        if let ugoScene = GameScene.unarchiveFromFile(fileName) {
            
            root = (ugoScene.children[0] ).copy() as! SKNode
            
            for arm in root["//arm*"] {
                
                
                
                (arm as SKNode).reachConstraints?.lowerAngleLimit = -90.0
                (arm as SKNode).reachConstraints?.upperAngleLimit = 90.0
                
                if arm.name == "arm_hand_right" {
                    arm_hand_right = arm
                }
                else if arm.name == "arm_root_right" {
                    arm_root_right = arm
                }
                else if arm.name == "arm_leg_root_right" {
                    leg_root_right = arm
                }
                else if arm.name == "arm_foot_right" {
                    leg_foot_right = arm
                }
                else if arm.name == "arm_leg_root_left" {
                    leg_root_left = arm
                }
                else if arm.name == "arm_foot_left" {
                    leg_foot_left = arm
                } else if arm.name == "arm_hand_left" {
                    arm_hand_left = arm
                }
                else if arm.name == "arm_root_left" {
                    arm_root_left = arm
                }

                
            }
            
            skate = root.childNodeWithName("skate")
            skate.physicsBody!.usesPreciseCollisionDetection = true
            torso = root.childNodeWithName("torso")
            left_foot_socket = skate.childNodeWithName("left_foot_socket")
            right_foot_socket = skate.childNodeWithName("right_foot_socket")
            
            skate.constraints = [SKConstraint.zRotation(SKRange(lowerLimit: -1.0, upperLimit: 1.0))]
            
        } else {
            root = SKNode()
        }
        

        super.init()
        
        addGroove()
        

    }
    
    func addGroove()
    {
        addGrooveTo(arm_hand_right, root: arm_root_right )
        addGrooveTo(arm_hand_left, root: arm_root_left )

    }
    
    private var grooving = false
    private let grooveAmplitude = CGPointMake(10.0, 10.0)
    private let grooveFreq = CGPointMake(10.0, 10.0)
    private let grooveSampling = 0.2
    
    func addGrooveTo(arm: SKNode, root: SKNode) {
        
        if let rnode = self.root.scene {
            grooving = true
            
            let delta = CGPointMake(cos(CGFloat(t) * grooveFreq.x) * grooveAmplitude.x , sin(CGFloat(t) * grooveFreq.y) * grooveAmplitude.y )
            
            var pos = arm.convertPoint(CGPointZero, toNode: rnode);
            pos.x += delta.x
            pos.y += delta.y
            
            arm.runAction(SKAction.reachTo(pos, rootNode: root, duration: grooveSampling), completion: {
                self.addGrooveTo(arm, root: root)
                })
            
        }
        
        
    }
    
    
    var grabbing = false
    
    func grabPosition(position: CGPoint) {
        
        arm_hand_left?.removeAllActions()
        arm_hand_right?.removeAllActions()
        
        grooving = false
        grabbing = true
        
        arm_hand_right?.runAction(SKAction.reachTo(position, rootNode: arm_root_right, duration: 0.1))
        arm_hand_left?.runAction(SKAction.reachTo(position, rootNode: arm_root_left, duration: 0.1), completion: {
            if !self.grooving {
                self.addGroove()
            }
            
            self.grabbing = false
        })
        
        //dismember()
        
    }
    
    func startMoving(position: CGPoint) {
        startPosition = position
        startSkatePosition = skate.position
        skate.physicsBody?.affectedByGravity = false
        
        if let ast = autoStopTimer {
            ast.invalidate()
            autoStopTimer = nil
        }
        
        autoStopTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("stopMoving"), userInfo: nil, repeats: false)
    }
    
    func stopMoving() {
        
        if let ast = autoStopTimer {
            ast.invalidate()
            autoStopTimer = nil
        }
        
        skate.physicsBody?.affectedByGravity = true
    }
    
    func move(position: CGPoint) {
        
        
        let dx = (position.x - startPosition.x) * sensitivity
        let dy = (position.y - startPosition.y) * sensitivity
        
        let to = CGPointMake(startSkatePosition.x + dx, startSkatePosition.y + dy)
        
        skate?.runAction(SKAction.moveTo(to, duration: 0.2))
    }

    
    func update(currentTime: CFTimeInterval) {
        
        t = currentTime
        
        if !grooving && !grabbing {
            addGroove()
        }
        
        
        if !dismembering {
            
            torso.position = CGPointMake(skate.position.x - tan(skate.zRotation)*50, skate.position.y + 150 * cos(skate.zRotation)  )

            torso.zRotation = skate.zRotation * 0.3
            
            if let rootParent = root.parent {
                if let rootParentParent = rootParent.parent {
                    
                    leg_foot_right?.runAction(SKAction.reachTo(right_foot_socket.convertPoint(CGPointZero, toNode: rootParentParent), rootNode: leg_root_right, duration: 0.01))
                    
                    leg_foot_left?.runAction(SKAction.reachTo(left_foot_socket.convertPoint(CGPointZero, toNode: rootParentParent), rootNode: leg_root_left, duration: 0.01))
                    
                    
                    
                }
            }
            
            let torsoFrame = torso.calculateAccumulatedFrame()
            let torsoOrigin = root.scene!.convertPoint(torsoFrame.origin, fromNode: torso.parent!)
            
            let torsoGlobalFrame = CGRectMake(torsoOrigin.x, torsoOrigin.y, torsoFrame.width, torsoFrame.height)
            
            if !torsoGlobalFrame.intersects(root.scene!.frame) {
                
                skate?.runAction(SKAction.moveTo(CGPointZero, duration: 0.5))
                dismember()
                
                NSTimer.scheduledTimerWithTimeInterval(dismemberingDuration * 5, target: self, selector: Selector("notifyDeath"), userInfo: nil, repeats: false)
                
            }
            
            if root.scene!.convertPoint(skate.position, fromNode: skate.parent!).y > 50.0 {
                
                if !flying {
                    flying = true
                    flyingStartTime = NSDate()
                }
                
            } else {
                
                if flying && flyingStartTime != nil {
                    
                    flying = false
                    
                    let elapsed = NSDate().timeIntervalSinceDate(flyingStartTime!)
                    
                    flyTotalTime += elapsed
                                        
                    delegate?.robotDidFly(self, flyTime: elapsed)
                    
                }
                
            }

        }

        
    }
    
    func dismember() {
        
        dismembering = true
        
        let sw = UInt32(root.scene!.size.width)
        let sh = UInt32(root.scene!.size.width)
        
        for arm in torso["*"] {
            explodeNode(arm, horizExtent: sw, vertExtent: sh)
        }
        
        explodeNode(torso, horizExtent: sw, vertExtent: sh)

        
    }
    
    func explodeNode(arm: SKNode, horizExtent: UInt32, vertExtent: UInt32) {
        if let node = arm as? SKSpriteNode {
            
            if node == skate {
                return
            }
            
            node.physicsBody = SKPhysicsBody(rectangleOfSize: node.size, center: node.anchorPoint)
            node.physicsBody?.mass = 0.1
            
            
            let dx = CGFloat(arc4random() % horizExtent) - CGFloat(horizExtent/2)
            let dy = CGFloat(arc4random() % vertExtent) - CGFloat(vertExtent/2)
            
            let endPoint = CGPointMake(dx, dy)
            
            node.runAction(SKAction.moveTo(endPoint, duration: dismemberingDuration))
            
            
        }

    }
    
    func notifyDeath() {
        
        delegate?.robotDead(self)
        
    }
}
