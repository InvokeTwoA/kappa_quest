import Foundation

class JobModel {
    
    // plist から読み込んだ職業データ
    var dictionary : NSDictionary!
    
    var name = "murabito"    // 職業名
    var displayName = "村人"
    var lv = 1
    
    // その職業の成長率
    var hp = 0
    var str = 0
    var agi = 0
    var int = 0
    var luc = 0
    
    var explain = ""
    var own_skill = ""
    var general_skill = ""
    
    // plist からデータを読み込む
    func readDataByPlist(_ chapter: Int){
        var dataPath = Bundle.main.path(forResource: "jobs", ofType:"plist" )!
        if chapter == 2 {
            dataPath = Bundle.main.path(forResource: "jobs_chapter2", ofType:"plist" )!
        }
        dictionary = NSDictionary(contentsOfFile: dataPath)!
    }
    
    // 職業レベルを保存
    func saveParam(_ chapter : Int){
        UserDefaults.standard.set(lv,  forKey: "\(name)_lv")
        if chapter == 1 {
            UserDefaults.standard.set(name,  forKey: "job")
        } else {
            UserDefaults.standard.set(name,  forKey: "job2")
        }
    }
    
    func loadParam(_ chapter : Int){
        if chapter == 1 {
            name = UserDefaults.standard.string(forKey: "job")!
            lv  = UserDefaults.standard.integer(forKey: "\(name)_lv")
            setDataByChapter1(name)
        } else if chapter == 2 {
            name = UserDefaults.standard.string(forKey: "job2")!
            lv  = UserDefaults.standard.integer(forKey: "\(name)_lv")
        }
    }
    
    func getDisplayName(key : String) -> String {
        let data = dictionary.object(forKey: key) as! NSDictionary
        return data.object(forKey: "name") as! String
    }

    func getExplain(key : String) -> String {
        let data = dictionary.object(forKey: key) as! NSDictionary
        return data.object(forKey: "explain") as! String
    }
    
    func isHighSpeed() -> Bool {
        return name == "niinja" || name == "thief" || name == "dancer"
    }
    
    
    // １章にて、全てのスキルを表示
    class func allSkillExplain(_ skillModel : SkillModel, kappa : KappaNode, gameData : GameData) -> String {
        var res = ""
        res += "クリティカル発生率：　\(BattleModel.displayCriticalPer(luc: kappa.luc))% \n"
        res += "クリティカルダメージ：　2.0 倍 \n\n"
        
        res += "【発動中のスキル】\n"
        
        if JobModel.getLV("murabito") >= 5 {
            let text = skillModel.getExplain("murabito")
            res += text
        }
        let skill_array = ["wizard", "archer"]
        for key in skill_array {
            if JobModel.getLV(key) >= 10 {
                let text = skillModel.getExplain(key)
                res += text
            }
        }
        
        let knight_lv = getLV("knight")
        if knight_lv >= 1 {
            let text = skillModel.getExplain("knight")
            res += text.replacingOccurrences(of: "(lv)", with: "\(knight_lv)")
        }
        let priest_lv = getLV("priest")
        if priest_lv >= 1 {
            let text = skillModel.getExplain("priest")
            var replaceString = text.replacingOccurrences(of: "(lv)", with: "\(priest_lv)")
            replaceString = replaceString.replacingOccurrences(of: "(tap)", with: "\(Const.tapHealCount)")
            res += replaceString
        }
        let thief_lv = getLV("thief")
        if thief_lv >= 1 {
            let text = skillModel.getExplain("thief")
            res += text.replacingOccurrences(of: "(lv)", with: "\(thief_lv)")
        }
        let necro_lv = getLV("necro")
        if necro_lv >= 1 {
            let text = skillModel.getExplain("necro")
            res += text.replacingOccurrences(of: "(lv)", with: "\(necro_lv)")
        }
        let angel_lv = getLV("angel")
        if angel_lv >= 1 {
            let text = skillModel.getExplain("angel")
            res += text.replacingOccurrences(of: "(lv)", with: "\(angel_lv)")
        }
        let king_lv = getLV("king")
        if king_lv >= 1 {
            let text = skillModel.getExplain("king")
            res += text.replacingOccurrences(of: "(lv)", with: "\(king_lv)")
        }
        let maou_lv = getLV("maou")
        if maou_lv >= 1 {
            let text = skillModel.getExplain("maou")
            res += text.replacingOccurrences(of: "(lv)", with: "\(maou_lv)")
        }
        let assassin_lv = getLV("assassin")
        if assassin_lv >= 1 {
            let text = skillModel.getExplain("assassin")
            res += text.replacingOccurrences(of: "(lv)", with: "\(assassin_lv)")
        }
                
        return res
    }
    
    // 職業レベルを取得
    class func getLV(_ key: String) -> Int {
        if UserDefaults.standard.object(forKey: "\(key)_lv") == nil {
            return 0
        } else {
            return UserDefaults.standard.integer(forKey: "\(key)_lv")
        }
    }
    
    class func setInitLv(_ chapter : Int){
        if chapter == 1 {
            UserDefaults.standard.set(1,  forKey: "murabito_lv")
        } else if chapter == 2 {
            UserDefaults.standard.set(1,  forKey: "prince_lv")
            UserDefaults.standard.set("prince",  forKey: "job2")
        }
    }
    
    /***********************************************************************************/
    /********************************** 1章     ****************************************/
    /***********************************************************************************/
    // 職業データを設定
    func setDataByChapter1(_ key : String){
        name = key
        lv = JobModel.getLV(name)
        let data = dictionary.object(forKey: name) as! NSDictionary
        displayName     = data.object(forKey: "name") as! String
        hp              = data.object(forKey: "hp") as! Int
        str             = data.object(forKey: "str") as! Int
        agi             = data.object(forKey: "agi") as! Int
        int             = data.object(forKey: "int") as! Int
        luc             = data.object(forKey: "luc") as! Int
        
        explain         = data.object(forKey: "explain") as! String
        own_skill       = data.object(forKey: "own_skill") as! String
        general_skill   = data.object(forKey: "general_skill") as! String
    }
    
    /***********************************************************************************/
    /********************************** ２章     ****************************************/
    /***********************************************************************************/
    // 職業データを設定
    var buster_long = 300
    func setDataByChapter2(_ key : String){
        name = key
        lv = JobModel.getLV(name)
        let data = dictionary.object(forKey: name) as! NSDictionary
        
        displayName     = data.object(forKey: "name") as! String
        hp              = data.object(forKey: "hp") as! Int
        buster_long     = data.object(forKey: "buster_long") as! Int
        
        explain         = data.object(forKey: "explain") as! String
        own_skill       = data.object(forKey: "own_skill") as! String
        general_skill   = data.object(forKey: "general_skill") as! String
    }
    
    
    
}
