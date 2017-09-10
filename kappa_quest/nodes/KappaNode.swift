import Foundation
import SpriteKit

class KappaNode: SKSpriteNode {
    
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
    
    var mode = ""
    
    // 根性フラグ
    let konjoFlag = false
    
    // パラメーターを userDefault から読み取り
    func setParameterByUserDefault(){
        if UserDefaults.standard.object(forKey: "lv") == nil {
            return
        }
        
        lv  = UserDefaults.standard.integer(forKey: "lv")
        hp  = UserDefaults.standard.integer(forKey: "hp")
        str = UserDefaults.standard.integer(forKey: "str")
        def = UserDefaults.standard.integer(forKey: "def")
        agi = UserDefaults.standard.integer(forKey: "agi")
        int = UserDefaults.standard.integer(forKey: "int")
        pie = UserDefaults.standard.integer(forKey: "pie")
        luc = UserDefaults.standard.integer(forKey: "luc")
        nextExp = UserDefaults.standard.integer(forKey: "nextExp")
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
        setNextExp(jobModel)
        
    }
    
    func setNextExp(_ jobModel : JobModel){
        nextExp = lv + jobModel.lv*10
    }
    
    func saveParam(){
        UserDefaults.standard.set(lv,  forKey: "lv")
        UserDefaults.standard.set(hp,  forKey: "hp")
        UserDefaults.standard.set(str, forKey: "str")
        UserDefaults.standard.set(def, forKey: "def")
        UserDefaults.standard.set(agi, forKey: "agi")
        UserDefaults.standard.set(int, forKey: "int")
        UserDefaults.standard.set(pie, forKey: "pie")
        UserDefaults.standard.set(luc, forKey: "luc")
        UserDefaults.standard.set(nextExp, forKey: "nextExp")
    }
    
    
    // 物理属性を適用
    func setPhysic(){
        let physic = SKPhysicsBody(rectangleOf: CGSize(width: Const.kappaSize, height: Const.kappaSize))
        physic.affectedByGravity = false
        physic.allowsRotation = false
        physic.isDynamic = false
        physic.categoryBitMask = Const.kappaCategory
        physic.contactTestBitMask = Const.fireCategory | Const.enemyCategory
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
    }
    
    func walk(){
        texture = SKTexture(imageNamed: "kappa")
    }
    
    func dead(){
        texture = SKTexture(imageNamed: "kappa_dead")
    }
    
}
