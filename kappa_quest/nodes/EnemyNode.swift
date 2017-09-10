import Foundation
import SpriteKit

class EnemyNode: SKSpriteNode {

    var lv = 1
    var maxHp = 10
    var hp = 10
    var str = 1
    var def = 1
    var agi = 1
    var pie = 1
    var int = 1
    var exp = 1
    var displayName = "敵"
    var isDead = true
    var range = 1.0     // 物理攻撃の距離
    
    var canFire = false
    var canFly = false   // 飛行
    
    var fire : FireEmitterNode!

    var isAttacking = false

    var attackTimer = 100 // この数値が100になったら攻撃する
    var fireTimer = 100   // この数値が100になったら炎攻撃をする
    var jumpTimer = 0     // この数値が 7 の倍数の時、小さくジャンプする
    
    var pos = 0
    
    class func makeEnemy(name : String) -> EnemyNode {
        let enemy = EnemyNode(imageNamed: name)
        enemy.size = CGSize(width: Const.enemySize, height: Const.enemySize)
        enemy.anchorPoint = CGPoint(x: 0.5, y: 0)     // 中央下がアンカーポイント
        enemy.zPosition = 2
        enemy.attackTimer = CommonUtil.rnd(100)
        enemy.isDead = false
        enemy.setPhysic()
        enemy.name = "enemy"
        return enemy
    }
    
    func makeFire(){
        fire = FireEmitterNode.makeFire()
        fire.damage = str
    }
    
    func setParameterByDictionary(dictionary : NSDictionary, set_lv : Int){
        displayName = dictionary.object(forKey: "name") as! String
        maxHp   = dictionary.object(forKey: "hp") as! Int
        hp      = dictionary.object(forKey: "hp") as! Int
        str     = dictionary.object(forKey: "str") as! Int
        def     = dictionary.object(forKey: "def") as! Int
        agi     = dictionary.object(forKey: "agi") as! Int
        int     = dictionary.object(forKey: "int") as! Int
        pie     = dictionary.object(forKey: "pie") as! Int
        exp     = dictionary.object(forKey: "exp") as! Int
        range   = Double(dictionary.object(forKey: "range") as! CGFloat)
        canFire = dictionary.object(forKey: "canFire") as! Bool
        
        // LVの分だけ強さをかける
        lv = set_lv
        maxHp *= lv
        hp *= lv
        str *= lv
        def *= lv
        agi *= lv
        int *= lv
        pie *= lv
        exp += lv
    }
    
    // HP の割合を返す  32% ならば　32
    func hp_per() -> Double {
        let per = Double(hp)/Double(maxHp) * 100.0
        return per
    }
    
    func timerUp(){
        attackTimer += timerRnd()
        if canFire {
            fireTimer += timerRnd()
        }
        jumpTimer += CommonUtil.rnd(3)
    }
    
    func timerRnd() -> Int {
        var rnd = CommonUtil.rnd(agi) + 10
        if rnd >= 50 {
            rnd = 50
        }
        return rnd
    }
    
    
    func isAttack() -> Bool {
        return !isDead && attackTimer > 100
    }

    func isFire() -> Bool {
        return canFire && fireTimer > 100
    }

    func attackTimerReset(){
        if attackTimer >= 100 {
            attackTimer -= 100
        }
    }
    
    func fireTimerReset(){
        if fireTimer >= 100 {
            fireTimer -= 100
        }
    }
    
    func jumpTimerReset(){
        if jumpTimer > 100 {
            jumpTimer = 0
        }
    }

    
    func setPhysic(){
        let physic = SKPhysicsBody(rectangleOf: CGSize(width: Const.kappaSize, height: Const.kappaSize))
        physic.affectedByGravity = false
        physic.allowsRotation = false
        physic.categoryBitMask = Const.enemyCategory
        physic.contactTestBitMask = Const.worldCategory
        physic.collisionBitMask = Const.worldCategory
        physic.linearDamping = 0
        physic.friction = 0
        self.physicsBody = physic
    }
    
    
    // 撃破時の物理属性を適用
    func setBeatPhysic(){
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        physicsBody?.allowsRotation = true

        let yVector = CommonUtil.rnd(150)
        physicsBody?.applyImpulse(CGVector(dx: 250, dy: yVector))
        physicsBody?.applyTorque(Const.beatRotatePower)
    }

}
