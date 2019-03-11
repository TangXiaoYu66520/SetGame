//
//  SetCardViewBehavior.swift
//  SetGame
//
//  Created by 唐小雨 on 2019/2/21.
//  Copyright © 2019 唐小雨. All rights reserved.
//

import UIKit

class SetCardViewBehavior: UIDynamicBehavior {

    lazy var collisionBehavior: UICollisionBehavior = {
        let collision = UICollisionBehavior()
        collision.translatesReferenceBoundsIntoBoundary = true
        addChildBehavior(collision)
        return collision
    }()
    
    lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.elasticity = 1
        addChildBehavior(behavior)
        return behavior
    }()
    
    func push(item: UIDynamicItem){
        let push = UIPushBehavior(items: [item], mode: UIPushBehavior.Mode.instantaneous)
        push.setAngle(CGFloat.random(in: 0...2*CGFloat.pi), magnitude: CGFloat.random(in: 1...10))
        push.action = {[unowned self, push] in self.removeChildBehavior(push)}
        addChildBehavior(push)
    }
    
    func add(item: UIDynamicItem) -> Void {
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        push(item: item)
    }
    
    func remove(item: UIDynamicItem) -> Void {
        collisionBehavior.removeItem(item)
        itemBehavior.removeItem(item)
    }
    
    convenience init(withAnimator animator: UIDynamicAnimator){
        self.init()
        animator.addBehavior(self)
    }
}
