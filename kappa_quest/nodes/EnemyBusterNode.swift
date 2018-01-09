// ２章専用
// 敵の弾の図形クラス
import Foundation
import SpriteKit
class EnemyBusterNode: SKShapeNode {
    
    var str = 1
    
    class func createEnemyBuster(_ enemy : EnemyNode) -> EnemyBusterNode {
        let BUSTER_RADIUS : CGFloat = 24.0
        let height = (enemy.texture?.size().height)!
        let tmpHeight = CommonUtil.rnd(Int(height))
        let busterHeight = enemy.position.y + CGFloat(tmpHeight)
        let circle = EnemyBusterNode(circleOfRadius: BUSTER_RADIUS)
        circle.physicsBody = busterEnemyPhysic(BUSTER_RADIUS)
        circle.physicsBody?.affectedByGravity = enemy.canBusterGravity
        circle.fillColor = UIColor.red
        circle.position = CGPoint(x: enemy.position.x, y: busterHeight)
        circle.zPosition = 11
        circle.str = enemy.str
        return circle
    }
    
    func shot(){
        let BUSTER_LONG : CGFloat = -800.0
        var BUSTER_SPEED : TimeInterval = 1.3
        if AbilityModel.haveSkill("eyes") {
            BUSTER_SPEED = 2.0
        }
        
        let busterAction = SKAction.sequence([
            SKAction.moveBy(x: BUSTER_LONG, y: 0, duration: BUSTER_SPEED),
            SKAction.removeFromParent()
            ])
        run(busterAction)
    }
    
    class func busterEnemyPhysic(_ r : CGFloat) -> SKPhysicsBody {
        let physics = SKPhysicsBody(rectangleOf: CGSize(width: r*2.0, height: r*2.0))
        physics.categoryBitMask = Const.busterEnemyCategory
        physics.contactTestBitMask = 0
        physics.collisionBitMask = 0
        return physics
    }
}

