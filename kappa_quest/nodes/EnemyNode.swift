// 敵の図形クラス
import Foundation
import SpriteKit

class EnemyNode: SKSpriteNode {

    // ステータス
    var lv = 1
    var maxHp = 10
    var hp = 10
    var str = 1
    var def = 1
    var agi = 1
    var pie = 1
    var int = 1
    var displayName = "敵"
    var heal = 0
    var range = 1.0     // 物理攻撃の距離
    var diff_agi = 0
    var key_name = "name"

    // 特殊能力
    var canFire = false
    var canFly = false   // 飛行
    var canThunder = false
    var canArrow  = false
    var canDeath = false
    var canLazer = false
    var isGhost = false
    var isMovingFree = false
    var isZombi = ""
    var isBoss = false

    // 各種フラグ
    var isDead = true
    var isAttacking = false
    
    // その他変数
    var pos = 0
    var fire : FireEmitterNode!
    var dx = 0
    var dy = 0
    
    var eSize = "free"

    class func makeEnemy(name : String, enemy_size : String = "not_free") -> EnemyNode {
        let enemy = EnemyNode(imageNamed: name)
        enemy.eSize = enemy_size

        if enemy_size == "not_free" {
                        print("not free")
            enemy.size = CGSize(width: Const.enemySize, height: Const.enemySize)
        } else {
            print("free")
            let texture = SKTexture(imageNamed: name)
            enemy.texture = texture
            enemy.size = texture.size()
        }
        enemy.anchorPoint = CGPoint(x: 0.5, y: 0)     // 中央下がアンカーポイント
        enemy.zPosition = 2
        enemy.attackTimer   = CommonUtil.rnd(100)
        enemy.fireTimer     = CommonUtil.rnd(100)
        enemy.thunderTimer  = CommonUtil.rnd(100)
        enemy.arrowTimer    = CommonUtil.rnd(100)
        enemy.lazerTimer    = CommonUtil.rnd(120)
        enemy.isDead = false
        enemy.name = "enemy"
        enemy.key_name = name
        return enemy
    }

    func makeFire(){
        fire = FireEmitterNode.makeFire()
        fire.damage = str
    }

    /***********************************************************************************/
    /******************************** ステータス  **************************************/
    /***********************************************************************************/
    func setParameterByDictionary(dictionary : NSDictionary){
        displayName = dictionary.object(forKey: "name") as! String
        maxHp   = dictionary.object(forKey: "hp") as! Int
        str     = dictionary.object(forKey: "str") as! Int
        def     = dictionary.object(forKey: "def") as! Int
        agi     = dictionary.object(forKey: "agi") as! Int
        int     = dictionary.object(forKey: "int") as! Int
        pie     = dictionary.object(forKey: "pie") as! Int
        range   = Double(dictionary.object(forKey: "range") as! CGFloat)
        hp      = maxHp
        
        if dictionary["canFire"] != nil {
            canFire = dictionary.object(forKey: "canFire") as! Bool
        }
        if dictionary["canFly"] != nil {
            canFly = dictionary.object(forKey: "canFly") as! Bool
        }
        if dictionary["canThunder"] != nil {
            canThunder = dictionary.object(forKey: "canThunder") as! Bool
        }
        if dictionary["canArrow"] != nil {
            canArrow = dictionary.object(forKey: "canArrow") as! Bool
        }
        if dictionary["canDeath"] != nil {
            canDeath = dictionary.object(forKey: "canDeath") as! Bool
        }
        if dictionary["canLazer"] != nil {
            canLazer = dictionary.object(forKey: "canLazer") as! Bool
        }

        if dictionary["heal"] != nil {
            heal = dictionary.object(forKey: "heal") as! Int
        }
        if dictionary["isGhost"] != nil {
            isGhost = dictionary.object(forKey: "isGhost") as! Bool
        }
        if dictionary["isMovingFree"] != nil {
            isMovingFree = dictionary.object(forKey: "isMovingFree") as! Bool
            isAttacking = true
        }
        if dictionary["isZombi"] != nil {
            isZombi = dictionary.object(forKey: "isZombi") as! String
        }
        
        if dictionary["dx"] != nil {
            dx = dictionary.object(forKey: "dx") as! Int
            dx *= -1
        }
        if dictionary["dy"] != nil {
            dy = dictionary.object(forKey: "dy") as! Int
        }

    }
    
    func healHP(_ heal : Int){
        hp += heal
        if hp > maxHp {
            hp = maxHp
        }
    }
    

    // ボス敵はステータス強化される
    func bossPowerUp(){
        maxHp *= 5
        hp = maxHp
        str += 1
        def += 1
        agi += 1
        int += 1
        pie += 1
        lv += 1
        isBoss = true
        
        if eSize == "not_free" {
            size = CGSize(width: Const.bossSize, height: Const.bossSize)
        }
    }
    
    // HP の割合を返す  32% ならば　32
    func hp_per() -> Double {
        let per = Double(hp)/Double(maxHp) * 100.0
        return per
    }

    /***********************************************************************************/
    /******************************** タイマー処理  ************************************/
    /***********************************************************************************/
    var attackTimer = 100 // この数値が100になったら攻撃する
    var fireTimer = 100   // この数値が100になったら炎攻撃をする
    var thunderTimer = 100
    var arrowTimer = 100
    var deathTimer = 80
    var lazerTimer = 100
    var jumpTimer = 0     // この数値が 7 の倍数の時、小さくジャンプする

    func timerUp(){
        attackTimer += timerRnd()
        if canFire {
            fireTimer += timerRnd()
        }
        if canThunder {
            thunderTimer += timerRnd()
        }
        if canArrow {
            arrowTimer += timerRnd()
        }
        if canDeath {
            deathTimer += timerRnd()
        }
        if canLazer {
            lazerTimer += timerRnd()
        }
        
        jumpTimer += CommonUtil.rnd(3)
    }

    func timerRnd() -> Int {
        var rnd = CommonUtil.rnd(diff_agi) + 10
        if rnd >= 50 {
            rnd = 50
        }
        return rnd
    }

    func isAttack() -> Bool {
        return !isDead && attackTimer > 100 && !isMovingFree
    }

    func isFire() -> Bool {
        return canFire && fireTimer > 100
    }

    func isThunder() -> Bool {
        return canThunder && thunderTimer > 100
    }

    func isArrow() -> Bool {
        return canArrow && arrowTimer > 100
    }
    
    func isDeath() -> Bool {
        return canDeath && deathTimer > 100
    }
    
    func isLazer() -> Bool {
        return canLazer && lazerTimer > 120
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

    func thunderTimerReset(){
        if thunderTimer >= 100 {
            thunderTimer = 0
        }
    }

    func arrowTimerReset(){
        if arrowTimer >= 100 {
            arrowTimer = 0
        }
    }
    
    func deathTimerReset(){
        if deathTimer >= 100 {
            deathTimer = 0
        }
    }
    
    func lazerTimerReset(){
        if lazerTimer >= 120 {
            lazerTimer = 0
        }
    }

    /***********************************************************************************/
    /******************************** アクション    **************************************/
    /***********************************************************************************/
    func normalAttack(_ actionModel : ActionModel){
        isAttacking = true
        var timer : TimeInterval
        if isGhost {
            run(actionModel.underAttack)
            timer = 4*Const.enemyJump
        } else {
            run(actionModel.enemyAttack(range: CGFloat(range)))
            timer = 2*Const.enemyJump
        }
        _ = CommonUtil.setTimeout(delay: timer, block: { () -> Void in
            self.isAttacking = false
        })
        attackTimerReset()
    }


    /***********************************************************************************/
    /******************************** 物理属性      ************************************/
    /***********************************************************************************/
    func setPhysic(){
        var enemyPhysicSize : CGSize!
        if eSize == "not_free" {
            var enemy_size = Const.kappaSize
            if isBoss {
                enemy_size = Const.bossSize
            }
            enemyPhysicSize = CGSize(width: enemy_size, height: enemy_size)
        } else {
            let texture = SKTexture(imageNamed: key_name)
            enemyPhysicSize = texture.size()
        }
        
        let physic = SKPhysicsBody(rectangleOf: enemyPhysicSize, center: CGPoint(x: 0, y: size.height/2.0))
        if canFly {
            physic.affectedByGravity = true
        } else {
            physic.affectedByGravity = false
        }
        physic.allowsRotation = false
        physic.categoryBitMask = Const.enemyCategory
        if canFly {
            physic.contactTestBitMask = Const.worldCategory
            physic.collisionBitMask = Const.worldCategory
            physic.linearDamping = 0.0
            physic.friction = 0.0
            physic.restitution = 1.0
        } else {
            physic.contactTestBitMask = 0
            physic.collisionBitMask = 0
        }
        physicsBody = physic
    }

    // 撃破時の物理属性を適用
    let ROTATE_POWER : CGFloat = 50.0 // 吹き飛ばしの回転力
    func setBeatPhysic(){
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let yVector = CommonUtil.rnd(150)
        physicsBody?.angularDamping = 0.0
        physicsBody?.applyTorque(ROTATE_POWER)
        physicsBody?.applyImpulse(CGVector(dx: 250, dy: yVector))
    }

    func ghostMove(){
        physicsBody?.contactTestBitMask = Const.worldCategory
        physicsBody?.collisionBitMask = Const.worldCategory
        physicsBody?.linearDamping = 0.0
        physicsBody?.friction = 0.0
        physicsBody?.restitution = 1.0

        let first_dx = 30 + CommonUtil.rnd(40)
        let first_dy = 30 + CommonUtil.rnd(40)
        physicsBody?.applyImpulse(CGVector(dx: first_dx, dy: first_dy))
    }

    
    func convertDxPlus(){
        if dx < 0 {
            dx *= -1
        }
    }
    
    func convertDxMinus(){
        if dx > 0 {
            dx *= -1
        }
        if dx == 0 {
            dx = -30
        }
    }

    func convertDyPlus(){
        if dy < 0 {
            dy *= -1
        }
    }

    func convertDyMinus(){
        if dy > 0 {
            dy *= -1
        }
    }

    
}
