// 炎のエミッター
import SpriteKit

class FireEmitterNode: SKEmitterNode {

    var damage = 1
    
    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    class func makeFire() -> FireEmitterNode {

        let particle = FireEmitterNode(fileNamed: "fire")!
        particle.zPosition = 5
        
//        particle.xAcceleration = -30
//        particle.yAcceleration = -40
        

        particle.setPhysic()
        return particle
    }
    
    // 物理属性を適用
    func setPhysic(){
        let physic = SKPhysicsBody(rectangleOf: CGSize(width: Const.kappaSize, height: Const.kappaSize))
        physic.affectedByGravity = true
        physic.allowsRotation = true
        
        physic.categoryBitMask = Const.fireCategory
        // physic.contactTestBitMask = goalCategory | coinCategory | worldCategory | wallCategory | enemyCategory | itemCategory | blockCategory | downWorldCategory
        physic.collisionBitMask = 0
        //        physic.contactTestBitMask = worldCategory
        //        physic.collisionBitMask = worldCategory
        //        physic.linearDamping = 0
        //        physic.friction = 0
        self.physicsBody = physic
    }
    
    func shot(){
        
        
        physicsBody?.applyImpulse(CGVector(dx: -70, dy: 350))
    }

}
