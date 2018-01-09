import Foundation

class AbilityModel {
    public var spendCost = 0       // 使用ポイント
    public var abilityPoint = 0    // 残りポイント
    
    // plist から読み込んだ職業データ
    var dictionary : NSDictionary!
    
    // plist からデータを読み込む
    func readDataByPlist(){
        let dataPath = Bundle.main.path(forResource: "ability", ofType:"plist" )!
        dictionary = NSDictionary(contentsOfFile: dataPath)!
    }
    
    func getCost(_ key : String) -> Int {
        let data = dictionary[key] as! NSDictionary
        return data["cost"] as! Int
    }

    func getName(_ key : String) -> String {
        let data = dictionary[key] as! NSDictionary
        return data["name"] as! String
    }
    
    func getExplain(_ key : String) -> String {
        let data = dictionary[key] as! NSDictionary
        return data["explain"] as! String
    }
    
    func getInfo(_ key : String) -> String {
        let data = dictionary[key] as! NSDictionary
        return data["info"] as! String
    }

    // パラメーターを userDefault から読み取り
    func setParameterByUserDefault(){
        if UserDefaults.standard.object(forKey: "lv") == nil {
            return
        }
        spendCost = UserDefaults.standard.integer(forKey: "spend_cost")
        abilityPoint = UserDefaults.standard.integer(forKey: "lv") - spendCost
    }
    
    // スキルリスト
    let skill_list = [
        "jump_plus",
        "shukuchi",
        "shukuchi2",
        "jump_heal",
        "time_heal",
        "jump_high",
        "buster_heal",
        "rush_heal",
        "buster_long",
        "buster_penetrate",
        "buster_big",
        "buster_right",
        "buster_up",
        "buster_gravity",
        "buster_slow",
        "buster_back",
        "rush_muteki",
        "rush_move",
        "rush_hado",
        "tanuki_body",
    ]
    var have_skill_list : [String] = [String]()

    /*
    // 各種フラグを立てる
    var shukuchiFlag = false
    var shukuchi2Flag = false
    var jumpPlusFlag = false
    var jumpHighFlag = false
    var timeHealFlag = false
    var jumpHealFlag = false
    var busterHealFlag = false
    var rushHealFlag = false
    var busterLongFlag = false
    var busterPenetrateFlag = false
    var busterBigFlag = false
    var busterRightFlag = false
    var busterUpFlag = false
    var busterGravityFlag = false
    var busterSlowFlag = false
    var busterBackFlag = false
    var rushMutekiFlag = false
    var rushMoveFlag = false
    var rushHadoFlag = false
    var tanukiBodyFlag = false
 */
 
    func setFlag(){
        /*
        jumpPlusFlag = AbilityModel.haveSkill("jump_plus")
        shukuchiFlag = AbilityModel.haveSkill("shukuchi")
        shukuchi2Flag = AbilityModel.haveSkill("shukuchi2")
        jumpHealFlag = AbilityModel.haveSkill("jump_heal")
        jumpHighFlag = AbilityModel.haveSkill("jump_high")
        busterHealFlag = AbilityModel.haveSkill("buster_heal")
        rushHealFlag = AbilityModel.haveSkill("rush_heal")
        busterLongFlag = AbilityModel.haveSkill("buster_long")
        busterPenetrateFlag = AbilityModel.haveSkill("buster_penetrate")
        busterBigFlag = AbilityModel.haveSkill("buster_big")
        busterRightFlag = AbilityModel.haveSkill("buster_right")
        busterUpFlag = AbilityModel.haveSkill("buster_up")
        busterGravityFlag = AbilityModel.haveSkill("buster_gravity")
        busterSlowFlag = AbilityModel.haveSkill("buster_slow")
        busterBackFlag = AbilityModel.haveSkill("buster_back")
        rushMutekiFlag = AbilityModel.haveSkill("rush_muteki")
        rushMutekiFlag = AbilityModel.haveSkill("rush_move")
        rushHadoFlag = AbilityModel.haveSkill("rush_hado")
        tanukiBodyFlag = AbilityModel.haveSkill("tanuki_body")
 */
        for key in skill_list  {
            if UserDefaults.standard.bool(forKey: "skill_\(key)") {
               have_skill_list.append(key)
            }
        }
        
        print("have_skill_list = \(have_skill_list)")
    }
    
    func canUse(_ key : String) -> Bool {
        return have_skill_list.contains(where: { $0 == key })
    }
    
    
    class func haveSkill(_ key : String) -> Bool {
        return UserDefaults.standard.bool(forKey: "skill_\(key)")
    }

    func canGetSkill(_ key : String) -> Bool {
        if AbilityModel.haveSkill(key) {
            print("already have skill. so false")
            return false
        }

        let cost = getCost(key)
        if cost > abilityPoint {
            print("cost = \(cost), ability point = \(abilityPoint)")
            print("so false")
            return false
        }
        return true
    }
    
    func getSkill(_ key : String){
        spendCost += getCost(key)
        abilityPoint -= getCost(key)
        UserDefaults.standard.set(true, forKey: "skill_\(key)")
        UserDefaults.standard.set(spendCost, forKey: "spend_cost")
        have_skill_list.append(key)
    }
    
    func forgetSkill(_ key : String){
        spendCost -= getCost(key)
        abilityPoint += getCost(key)
        UserDefaults.standard.set(false, forKey: "skill_\(key)")
        UserDefaults.standard.set(spendCost, forKey: "spend_cost")
        have_skill_list = have_skill_list.filter { $0 != key }
    }
    
    func resetAllSkill(){
        let defaylt = UserDefaults.standard        
        for key in skill_list  {
            defaylt.removeObject(forKey: "skill_\(key)")
        }
        spendCost = 0
        UserDefaults.standard.set(spendCost, forKey: "spend_cost")
        abilityPoint = UserDefaults.standard.integer(forKey: "lv") - spendCost
    }
    
}

