// ２章ボス　うさぎ
import Foundation
import SpriteKit
class UsagiNode: SKSpriteNode {
    
    class func makeUsagi() -> UsagiNode {
        let usagi = UsagiNode(imageNamed: "last_usagi")
        usagi.anchorPoint = CGPoint(x: 0.5, y: 0)     // 中央下がアンカーポイント
        usagi.zPosition = 2
        return usagi
    }
    
    
    func attack(from : CGPoint,  to : CGPoint){
        let attackAction = SKAction.sequence([
            SKAction.move(to: to, duration: 0.5),
            SKAction.wait(forDuration: 0.2),
            SKAction.move(to: from, duration: 1.0)
            ])
        run(attackAction)
    }
    
    /***********************************************************************************/
    /******************************** 物理属性      ************************************/
    /***********************************************************************************/
    func setPhysic(){
        var physicSize : CGSize!
        let texture = SKTexture(imageNamed: "last_usagi")
        physicSize = texture.size()
        
        let physic = SKPhysicsBody(rectangleOf: physicSize, center: CGPoint(x: 0, y: size.height/2.0))
        physic.allowsRotation = false
        physic.affectedByGravity = false
        physic.categoryBitMask = Const.usagiCategory
        physic.contactTestBitMask = 0
        physic.collisionBitMask = 0
        physicsBody = physic
    }
    
    
    
}
