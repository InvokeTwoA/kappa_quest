// 雷のエミッター
import SpriteKit
class ThunderEmitterNode: SKEmitterNode {
    
    var damage = 1
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    class func makeThunder() -> ThunderEmitterNode {
        let particle = ThunderEmitterNode(fileNamed: "thunder")!
        particle.zPosition = 5
        particle.name = "thunder"
        particle.setPhysic()
        return particle
    }

    class func makeArrow() -> ThunderEmitterNode {
        let particle = ThunderEmitterNode(fileNamed: "arrow")!
        particle.zPosition = 5
        particle.name = "arrow"
        particle.setPhysic()
        return particle
    }

    class func makeDark() -> ThunderEmitterNode {
        let particle = ThunderEmitterNode(fileNamed: "dark")!
        particle.zPosition = 5
        particle.name = "dark"
        particle.setPhysic()
        particle.physicsBody?.affectedByGravity = false
        particle.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 250))

        
        return particle
    }
    
    
    // 物理属性を適用
    func setPhysic(){
        let physic = SKPhysicsBody(rectangleOf: CGSize(width: Const.fireSize, height: Const.fireSize))
        physic.affectedByGravity = true
        physic.allowsRotation = true
        physic.categoryBitMask = Const.thunderCategory
        physic.contactTestBitMask = Const.worldCategory
        physic.collisionBitMask = 0
        self.physicsBody = physic
    }    
}
