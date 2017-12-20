// カッパの画像クラス
import Foundation
import SpriteKit

class KappaNode: SKSpriteNode {

    // ステータス
    var lv = 1
    var job_lv = 1
    var maxHp = 15
    var hp = 15
    var str = 2
    var agi = 2
    var int = 2
    var luc = 2
    var beauty = 2
    var nextExp = 10
    var exp = 0
    var physic_type = "normal"
    var mode = ""
    
    // フラグ
    var konjoEndFlag = false  // スキル根性が発動したかどうか（１ゲームに１回きり）
    var isSpin = false

    // 加速度（２章ラスボスで使用）
    var dx = 0
    var dy = 0
    
    // パラメーターを userDefault から読み取り
    func setParameterByUserDefault(){
        // FIXME guard
        if UserDefaults.standard.object(forKey: "lv") == nil {
            return
        }

        lv      = UserDefaults.standard.integer(forKey: "lv")
        maxHp   = UserDefaults.standard.integer(forKey: "hp")
        str     = UserDefaults.standard.integer(forKey: "str")
        agi     = UserDefaults.standard.integer(forKey: "agi")
        int     = UserDefaults.standard.integer(forKey: "int")
        luc     = UserDefaults.standard.integer(forKey: "luc")
        beauty  = UserDefaults.standard.integer(forKey: "beauty")
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
        agi += jobModel.agi
        int += jobModel.int
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
        UserDefaults.standard.set(agi, forKey: "agi")
        UserDefaults.standard.set(int, forKey: "int")
        UserDefaults.standard.set(luc, forKey: "luc")
        UserDefaults.standard.set(beauty, forKey: "beauty")
        UserDefaults.standard.set(exp, forKey: "exp")
    }
    
    func displayStatus() -> String {
        var res = ""
        res += "HP : \(maxHp)\n"
        res += "筋力 : \(str)\n"
        res += "魔力 : \(int)\n"
        res += "敏捷 : \(agi)\n"
        res += "幸運 : \(luc)"
        
        return res
    }

    // 物理属性を適用
    func setPhysic(){
        var kappa_height = Const.kappaSize
        var centerPoint = CGPoint(x: 0, y: Const.kappaSize/2.0)
        if physic_type == "noppo" {
            kappa_height = 2*Const.kappaSize
            centerPoint = CGPoint(x: 0, y: Const.kappaSize)
            size = CGSize(width: Const.kappaSize, height: 2*Const.kappaSize)
        }
        let physic = SKPhysicsBody(rectangleOf: CGSize(width: Const.kappaSize, height: kappa_height), center: centerPoint)
        physic.affectedByGravity = false
        physic.allowsRotation = false
        physic.isDynamic = false
        physic.categoryBitMask = Const.kappaCategory
        physic.contactTestBitMask = Const.fireCategory | Const.enemyCategory | Const.thunderCategory
        physic.collisionBitMask = 0
        physic.linearDamping = 0
        physic.friction = 0
        physicsBody = physic
    }
    
    // 宇宙空間でのカッパの physics
    func spaceMode(){
        physicsBody?.isDynamic = true
        physicsBody?.collisionBitMask = Const.worldCategory | Const.unvisibleWorldCategory
        physicsBody?.contactTestBitMask = Const.fireCategory | Const.thunderCategory | Const.lazerCategory | Const.usagiCategory
        maxHp = 100
        hp = 100
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
    }

    // カッパ波動砲
    func hado(){
        xScale = 1
        texture = SKTexture(imageNamed: "kappa_punch")
    }

    func dead(){
        texture = SKTexture(imageNamed: "kappa_dead")
    }
    
    // 裏技
    // 名前をお兄様にすることで最強のステータスになる
    func oniisama(){
        maxHp = 1000
        str = 999
        int = 999
        agi = 999
        luc = 999
        lv = 100
    }
    
    // 名前をラッキーにすることで幸運なステータスになる
    func lucky(){
        luc = 77
    }
    
    // 名前をお爺様にすることで１章クリア想定のステータスになる
    func ojiisama(){
        maxHp = 200
        str = 130
        int = 130
        agi = 150
        luc = 100
        lv = 120
    }

    
    class func setInitLv(){
        UserDefaults.standard.set(1, forKey: "lv")
    }

    private var kappa_punch_num = 0
    func punchRush(){
        if kappa_punch_num == 0 {
            texture = SKTexture(imageNamed: "kappa_punch_r")
            kappa_punch_num = 1
        } else if kappa_punch_num == 1 {
            texture = SKTexture(imageNamed: "kappa_punch")
            kappa_punch_num = 2
        } else {
            texture = SKTexture(imageNamed: "kappa_upper")
            kappa_punch_num = 0
        }
    }

}
