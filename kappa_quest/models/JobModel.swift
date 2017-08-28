import Foundation

class JobModel {
    
    // plist から読み込んだ職業データ
    var dictionary : NSDictionary!
    
    var name = "murabito"
    var displayName = "村人"
    var lv = 0
    
    // その職業の成長率
    var hp = 0
    var str = 0
    var def = 0
    var agi = 0
    var int = 0
    var pie = 0
    var luc = 0
    
    var explain = ""
    var skill_text = ""

    // 転職用のデータ
    var jobNameList0 = ["murabito", "fighter", "knight", "priest", "wizard", "thief"]
    var page = 0
    
    // plist からデータを読み込む
    func readDataByPlist(){
        let dataPath = Bundle.main.path(forResource: "jobs", ofType:"plist" )!
        dictionary = NSDictionary(contentsOfFile: dataPath)!
    }

    // 職業データを設定
    func setData(_ key : String){
        name = key
        lv = JobModel.getLV(name)
        let data = dictionary.object(forKey: name) as! NSDictionary
        displayName     = data.object(forKey: "name") as! String
        hp              = data.object(forKey: "hp") as! Int
        str             = data.object(forKey: "str") as! Int
        def             = data.object(forKey: "def") as! Int
        agi             = data.object(forKey: "agi") as! Int
        int             = data.object(forKey: "int") as! Int
        pie             = data.object(forKey: "pie") as! Int
        luc             = data.object(forKey: "luc") as! Int
        
        explain         = data.object(forKey: "explain") as! String
        skill_text      = data.object(forKey: "skill") as! String
    }
    
    // 職業レベルを保存
    func saveParam(){
        UserDefaults.standard.set(lv,  forKey: "\(name)_lv")
        UserDefaults.standard.set(name,  forKey: "job")
    }
    
    func loadParam(){
        if UserDefaults.standard.object(forKey: "job") == nil {
            name = "murabito"
            lv = 0
        } else {
            name = UserDefaults.standard.string(forKey: "job")!
            lv  = UserDefaults.standard.integer(forKey: "\(name)_lv")
        }
        setData(name)
    }

    class func getLV(_ key: String) -> Int {
        if UserDefaults.standard.object(forKey: "\(key)_lv") == nil {
            return 0
        } else {
            return UserDefaults.standard.integer(forKey: "\(key)_lv")
        }
    }

    
}
