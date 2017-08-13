import Foundation
import SpriteKit

class EnemyNode: SKSpriteNode {

    var hp = 10
    var str = 1
    var def = 1
    var agi = 1
    var pie = 1
    var exp = 1
    var isMagic = false
    var displayName = "敵"
    var isDead = false
    
    var weaponNode : SKSpriteNode!



    var attackTimer = 100 // この数値が10になったら攻撃する
    
    
    class func makeEnemy(name : String) -> EnemyNode {
        let enemy = EnemyNode(imageNamed: name)
        enemy.size = CGSize(width: Const.enemySize, height: Const.enemySize)
        enemy.anchorPoint = CGPoint(x: 0.5, y: 0)     // 中央下がアンカーポイント
        enemy.zPosition = 2
        enemy.attackTimer = CommonUtil.rnd(10)
        return enemy
    }
    
    func makeWeapon(){
        weaponNode = SKSpriteNode(imageNamed: "hatena")
        weaponNode.position = position
        weaponNode.zPosition = 3
    }
    
    
    func setParameterByDictionary(dictionary : NSDictionary){
        displayName = dictionary.object(forKey: "name") as! String
        hp      = dictionary.object(forKey: "hp") as! Int
        str     = dictionary.object(forKey: "str") as! Int
        def     = dictionary.object(forKey: "def") as! Int
        agi     = dictionary.object(forKey: "agi") as! Int
        pie     = dictionary.object(forKey: "pie") as! Int
        exp     = dictionary.object(forKey: "exp") as! Int
        isMagic = dictionary.object(forKey: "isMagic") as! Bool
    }
    

    func timerUp(){
        attackTimer += CommonUtil.rnd(agi) + 1
    }
    
    func isAttack() -> Bool {
        return !isDead && attackTimer > 100
    }
    
    func timerReset(){
        attackTimer = 0
    }
    
    
    // 撃破時の物理属性を適用
    func setBeatPhysic(){
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let physic = SKPhysicsBody(rectangleOf: CGSize(width: Const.kappaSize, height: Const.kappaSize))
        physic.affectedByGravity = false
        physic.allowsRotation = true
        //        physic.categoryBitMask = kappaCategory
        //        physic.contactTestBitMask = goalCategory | coinCategory | worldCategory | wallCategory | enemyCategory | itemCategory | blockCategory | downWorldCategory
        //        physic.collisionBitMask = worldCategory | wallCategory | horizonWorldCategory | downWorldCategory
        //        physic.contactTestBitMask = worldCategory
        //        physic.collisionBitMask = worldCategory
        //        physic.linearDamping = 0
        //        physic.friction = 0
        self.physicsBody = physic
    }

}
