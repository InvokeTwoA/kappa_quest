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
    
    // 各種フラグを立てる
    var jumpPlusFlag = false
    var busterLongFlag = false
    var busterPenetrateFlag = false
    var busterBigFlag = false
    var shukuchiFlag = false
    var shukuchi2Flag = false
    var timeHealFlag = false
    var jumpHealFlag = false
    var busterHealFlag = false

    func setFlag(){
        jumpPlusFlag = AbilityModel.haveSkill("jump_plus")
        busterLongFlag = AbilityModel.haveSkill("buster_long")
        busterPenetrateFlag = AbilityModel.haveSkill("buster_penetrate")
        busterBigFlag = AbilityModel.haveSkill("buster_big")
        shukuchiFlag = AbilityModel.haveSkill("shukuchi")
        shukuchi2Flag = AbilityModel.haveSkill("shukuchi2")
        jumpHealFlag = AbilityModel.haveSkill("jump_heal")
        busterHealFlag = AbilityModel.haveSkill("buster_heal")
    }
    
    class func haveSkill(_ key : String) -> Bool {
        return UserDefaults.standard.bool(forKey: "skill_\(key)")
    }

    func canGetSkill(_ key : String) -> Bool {
        if AbilityModel.haveSkill(key) {
            return false
        }

        let cost = getCost(key)
        if cost > abilityPoint {
            return false
        }
        
        // スキル前提を取得済みか
        
        return true
    }
    
    func getSkill(_ key : String){
        spendCost += getCost(key)
        UserDefaults.standard.set(true, forKey: "skill_\(key)")
        abilityPoint -= spendCost
        UserDefaults.standard.set(spendCost, forKey: "spend_cost")
    }
    
    func forgetSkill(_ key : String){
        spendCost -= getCost(key)
        UserDefaults.standard.set(false, forKey: "skill_\(key)")
        abilityPoint += spendCost
        UserDefaults.standard.set(spendCost, forKey: "spend_cost")
    }
}

