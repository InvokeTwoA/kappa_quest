// カッパの画像クラス
import Foundation
import SpriteKit

class KappaNode: SKSpriteNode {

    // ステータス
    var lv = 1
    var job_lv = 1
    var maxHp = 10
    var hp = 10
    var str = 1
    var def = 1
    var agi = 1
    var int = 1
    var pie = 1
    var luc = 1
    var nextExp = 10
    var exp = 0

    var mode = ""

    // フラグ
    var konjoEndFlag = false
    var isTornado = false

    // パラメーターを userDefault から読み取り
    func setParameterByUserDefault(){
        // FIXME guard
        if UserDefaults.standard.object(forKey: "lv") == nil {
            return
        }

        lv      = UserDefaults.standard.integer(forKey: "lv")
        maxHp   = UserDefaults.standard.integer(forKey: "hp")
        str     = UserDefaults.standard.integer(forKey: "str")
        def     = UserDefaults.standard.integer(forKey: "def")
        agi     = UserDefaults.standard.integer(forKey: "agi")
        int     = UserDefaults.standard.integer(forKey: "int")
        pie     = UserDefaults.standard.integer(forKey: "pie")
        luc     = UserDefaults.standard.integer(forKey: "luc")
        exp     = UserDefaults.standard.integer(forKey: "exp")
        
        hp  = maxHp
    }

    // LVアップ
    func LvUp(_ jobModel : JobModel){
        lv += 1
        jobModel.lv += 1
        maxHp += jobModel.hp
        hp  += jobModel.hp
        str += jobModel.str
        def += jobModel.def
        agi += jobModel.agi
        int += jobModel.int
        pie += jobModel.pie
        luc += jobModel.luc
        exp = 0
        setNextExp(jobModel)        
    }

    func heal(){
        hp = maxHp
    }

    func setNextExp(_ jobModel : JobModel){
        nextExp = lv + jobModel.lv*10
    }

    func saveParam(){
        UserDefaults.standard.set(lv,  forKey: "lv")
        UserDefaults.standard.set(maxHp,  forKey: "hp")
        UserDefaults.standard.set(str, forKey: "str")
        UserDefaults.standard.set(def, forKey: "def")
        UserDefaults.standard.set(agi, forKey: "agi")
        UserDefaults.standard.set(int, forKey: "int")
        UserDefaults.standard.set(pie, forKey: "pie")
        UserDefaults.standard.set(luc, forKey: "luc")
        UserDefaults.standard.set(exp, forKey: "exp")
    }

    // 物理属性を適用
    func setPhysic(){
        let physic = SKPhysicsBody(rectangleOf: CGSize(width: Const.kappaSize, height: Const.kappaSize))
        physic.affectedByGravity = false
        physic.allowsRotation = false
        physic.isDynamic = false
        physic.categoryBitMask = Const.kappaCategory
        physic.contactTestBitMask = Const.fireCategory | Const.enemyCategory | Const.thunderCategory
        physic.collisionBitMask = 0
        physic.linearDamping = 0
        physic.friction = 0
        self.physicsBody = physic
    }

    // カッパの華麗なる攻撃
    // 画像をランダムに変更
    func attack(){
        let images = ["kappa_punch", "kappa_upper", "kappa_kick", "kappa_body", "kappa_punch_r", "kappa_flying"]
        let image = images[CommonUtil.rnd(images.count)]
        texture = SKTexture(imageNamed: image)
        setPhysic()
    }

    func walkRight(){
        xScale = 1
        texture = SKTexture(imageNamed: "kappa")
    }

    func walkLeft(){
        xScale = -1
        texture = SKTexture(imageNamed: "kappa")
    }

    // カッパ頭突き
    func head(){
        xScale = 1
        zRotation = CGFloat(-90.0  / 180.0 * .pi)
    }

    // カッパ昇竜拳
    func upper(){
        xScale = 1
        texture = SKTexture(imageNamed: "kappa_upper")
    }

    // カッパ竜巻旋風脚
    func tornado(){
        texture = SKTexture(imageNamed: "kappa_kick")
        isTornado = true
    }

    // カッパ波動砲
    func hado(){
        xScale = 1
        texture = SKTexture(imageNamed: "kappa_punch")
    }

    func dead(){
        texture = SKTexture(imageNamed: "kappa_dead")
    }
    
    class func setInitLv(){
        UserDefaults.standard.set(1, forKey: "lv")
    }

}
