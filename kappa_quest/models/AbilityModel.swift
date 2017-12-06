import Foundation

class AbilityModel {
    public var spendCost = 0       // 使用ポイント
    public var abilityPoint = 0    // 残りポイント
    
    let ABILITY_SHUKUCHI = "shukuchi"
    let ABILITY_SHUKUCHI2 = "shukuchi2"
    let ABILITY_TIME_HEAL = "time_heal"
    
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
    
    
    // パラメーターを userDefault から読み取り
    func setParameterByUserDefault(){
        if UserDefaults.standard.object(forKey: "lv") == nil {
            return
        }
        spendCost = UserDefaults.standard.integer(forKey: "spend_cost")
        abilityPoint = UserDefaults.standard.integer(forKey: "lv") - spendCost
    }
    
    func haveSkill(_ key : String) -> Bool {
        return UserDefaults.standard.bool(forKey: "skill_\(key)")
    }

    func canGetSkill(_ key : String) -> Bool {
        if haveSkill(key) {
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

