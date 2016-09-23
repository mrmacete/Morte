//
//  GameScene.swift
//  Morte
//
//  Created by ftamagni on 16/03/15.
//  Copyright (c) 2015 morte. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, UgoRobotDelegate {
    
    var robot: UgoRobot!
    
    var lives: Int = 5 {
        didSet {
            updateLivesLabel()
        }
    }
    
    var points: Int = 0 {
        didSet {
            updatePointsLabel()
        }
    }
    
    var labels = [String: SKLabelNode]()
    
    var obstacles: Obstacles?
    var city: City?
    
    
    
    
    override func didMove(to view: SKView) {
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody!.collisionBitMask = 1
        self.physicsBody!.categoryBitMask = 1;
        fetchLabels()

        reset()
    }
    
    func reset() {
        
        removeGameOverLabel()
        
        loadObstacles()
        loadCity()
        
        loadRobot()

        lives = 5
        points = 0

    }
    
    func fetchLabels() {
        self.enumerateChildNodes(withName: "//label*", using: { (node:SKNode, boh:UnsafeMutablePointer<ObjCBool>) -> Void in
            
            if let label = node as? SKLabelNode {
                
                self.labels[label.name!] = label
                
            }
            
        })
    }
    
    func updateLivesLabel() {
        if let label = labels["label_lives"] {
            label.text = "Lives: \(lives)"
        }
    }
    
    func updatePointsLabel() {
        if let label = labels["label_points"] {
            label.text = "Points: \(points)"
        }

    }
    
    func createGameOverLabel() {
        let label = SKLabelNode(text: "GAME OVER")
        label.name = "gameover_label"
        label.fontName = "Helvetica Neue Medium"
        label.fontSize = 64
        label.fontColor = UIColor.white
        
        label.position = CGPoint(x: 512, y:440)
        
        addChild(label)
        
    }
    
    func removeGameOverLabel() {
        if let label = childNode(withName: "gameover_label") {
            label.removeFromParent()
        }
    }
    
    func loadRobot() {
        
        robot = UgoRobot(fileName: "UgoScene")
        
        if let robotNode = childNode(withName: "robot") {
            robotNode.removeAllChildren()
            robotNode.addChild(robot.root)
            robot.delegate = self
        }
        
    }
    
    func loadCity() {
        if let cityNode = childNode(withName: "dynamic_background") {
            cityNode.removeAllChildren()
            city = City(fileName: "CityScene", rootNode: cityNode, nLayers: 3)
        }
    }
    
    func loadObstacles() {
        if let obstaclesNode = childNode(withName: "obstacles") {
            obstaclesNode.removeAllChildren()
            self.obstacles = Obstacles(rootNode: obstaclesNode)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameIsOver {
            reset()
            
            gameIsOver = false
        } else {
        
            let location = moveToPosition(touches: touches)
            
            robot?.grabPosition(position: location)
            robot?.startMoving(position: location)
        }

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let location = moveToPosition(touches: touches)
        
        robot?.grabPosition(position: location)
        robot?.move(position: location)
        

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        robot?.stopMoving()
    }
    
    func moveToPosition(touches: Set<NSObject>) -> CGPoint {
        
        
        var location = CGPoint(x: 0,y: 0)
        
        for touch: AnyObject in touches {
            let loc = touch.location(in: self)
            
            location.x += loc.x
            location.y += loc.y
            
            
        }
        
        location.x /= CGFloat(touches.count)
        location.y /= CGFloat(touches.count)
        
        
        return location

    }
   
    override func update(_ currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        robot?.update(currentTime: currentTime)
        obstacles?.update(currentTime: currentTime)
        city?.update(currentTime: currentTime)
    }
    
    
    var gameIsOver = false
    
    func robotDead(robot: UgoRobot) {
        
        if lives > 1 {
            
            lives -= 1
        
            let oldSensitivity = robot.sensitivity
            
            loadRobot()
            
            obstacles?.maxHeight += 2000
            obstacles?.frequency *= 1.2
            
            self.robot.sensitivity = oldSensitivity * 1.1
            
        } else {
            
            lives -= 1
            
            createGameOverLabel();
            
            gameIsOver = true
        }
    }
    
    func robotDidFly(robot: UgoRobot, flyTime: Double) {
        
        points += Int(flyTime * Double(robot.sensitivity) * 10.0)
    }
    
}
