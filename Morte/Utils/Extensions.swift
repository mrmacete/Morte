//
//  Extensions.swift
//  Morte
//
//  Created by ftamagni on 26/03/15.
//  Copyright (c) 2015 morte. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init( components: [CGFloat]) {
        
        if components.count == 4 {
            self.init(red: components[0], green: components[1], blue: components[2], alpha: components[3])
        } else if components.count == 3 {
            self.init(red: components[0], green: components[1], blue: components[2], alpha: 1.0)
        } else if components.count == 2 {
            self.init(white: components[0], alpha: components[1])
        } else if components.count == 1 {
            self.init(white: components[0], alpha: 1.0)
        } else {
            self.init()
        }
        
    }
    
    
    func colorByMixingWith(other: UIColor, blendFactor: CGFloat) -> UIColor {
        
        let a = self.components()
        let b = other.components()
        let c = mixComponents(a, b: b, factor: blendFactor)
        
        
        return UIColor(components: c)
    }
    
    func mix(a: CGFloat, b: CGFloat, factor: CGFloat ) -> CGFloat {
        
        return a * factor + b * (1.0 - factor)
    }
    
    func mixComponents(a: [CGFloat], b: [CGFloat], factor: CGFloat ) -> [CGFloat] {
        
        let minCount = min(a.count, b.count)
        var result = [CGFloat]()
        
        for i in 0..<minCount {
            let c = mix(a[i], b: b[i], factor: factor)
            result.append(c)
        }
        
        return result
    }
    
    
    func components() -> [CGFloat] {
        
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return [red, green, blue, alpha]
    }
    
}
