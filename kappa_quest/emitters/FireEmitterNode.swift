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
        particle.name = "fire"
//        particle.xAcceleration = -30
//        particle.yAcceleration = -40
        particle.setPhysic()
        return particle
    }

    // 物理属性を適用
    func setPhysic(){
        let physic = SKPhysicsBody(rectangleOf: CGSize(width: Const.fireSize, height: Const.fireSize))
        physic.affectedByGravity = true
        physic.allowsRotation = true

        physic.categoryBitMask = Const.fireCategory
        physic.contactTestBitMask = Const.worldCategory
        physic.collisionBitMask = 0
        //        physic.linearDamping = 0
        //        physic.friction = 0
        self.physicsBody = physic
    }

    func shot(){
        let dx = CommonUtil.rnd(100) + 10
        physicsBody?.applyImpulse(CGVector(dx: -dx, dy: 200))
        physicsBody?.applyTorque(5.0)
    }
}
