// カッパの画像クラス
import Foundation
import SpriteKit

class KappaNode: SKSpriteNode {
    // ステータス(1章)
    var lv = 1
    var job_lv = 1
    var maxHp = 15
    var hp = 15
    var nextExp = 10
    var exp = 0
    var physic_type = "normal"
    var mode = ""
    
    // フラグ
    var isSpin = false
    
    func setParameter(chapter: Int) {
        if chapter == 1 {
            setParameterByChapter1()
        } else {
            setParameterByChapter2()
        }
    }
    
    // １章パラメーターを userDefault から読み取り
    func setParameterByChapter1(){
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
    
    func setDefaultParameterByChapter2(){
        
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

    func saveParam(chapter: Int) {
        if chapter == 1 {
            saveParamChapter1()
        } else {
            saveParamChapter2()
        }
    }
    
    func saveParamChapter1(){
        UserDefaults.standard.set(lv,  forKey: "lv")
        UserDefaults.standard.set(maxHp,  forKey: "hp")
        UserDefaults.standard.set(str, forKey: "str")
        UserDefaults.standard.set(agi, forKey: "agi")
        UserDefaults.standard.set(int, forKey: "int")
        UserDefaults.standard.set(luc, forKey: "luc")
        UserDefaults.standard.set(exp, forKey: "exp")
    }
    
    func saveParamChapter2(){
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
        physic.contactTestBitMask = Const.fireCategory | Const.enemyCategory | Const.thunderCategory | Const.busterEnemyCategory
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
        
        if AbilityModel.haveSkill("space_hp_up") {
            maxHp = 120
            hp = 120
        } else {
            maxHp = 100
            hp = 100
        }
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
        if isTanuki {
            texture = SKTexture(imageNamed: "tanuki")
        } else {
            texture = SKTexture(imageNamed: "kappa")
        }
    }

    func walkLeft(){
        xScale = -1
        if isTanuki {
            texture = SKTexture(imageNamed: "tanuki")
        } else {
            texture = SKTexture(imageNamed: "kappa")
        }
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
    
    class func setInitLv(_ chapter : Int){
        if chapter == 1 {
            UserDefaults.standard.set(1, forKey: "lv")
        } else if chapter == 2 {
            UserDefaults.standard.set(1, forKey: "lv2")
        }
    }

    /***********************************************************************************/
    /********************************** 1章     ****************************************/
    /***********************************************************************************/
    var str = 2
    var agi = 2
    var int = 2
    var luc = 2
    var konjoEndFlag = false  // スキル根性が発動したかどうか（１ゲームに１回きり）

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
    
    /***********************************************************************************/
    /********************************** ２章     ****************************************/
    /***********************************************************************************/
    
    // ステータス２章
    var buster_long = 300
    var isTanuki = false
    var dx = 0  // 宇宙ステージの加速度
    var dy = 0  // 宇宙ステージの加速度
    var beauty = 2

    // ２章は職業とアビリティによりパラメーターが決定
    func setParameterByChapter2(){

        
        lv      = 12
        maxHp   = 12
        str     = 5
        agi     = 6
        int     = 7
        luc     = 8
        beauty  = 9
        exp     = 10
        hp  = maxHp
    }

    
    // カッパバスター
    func buster(){
        texture = SKTexture(imageNamed: "kappa_punch")
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
