import Foundation

class WorldModel {
    
    // plist から読み込んだ職業データ
    private var dictionary : NSDictionary!
    
    var lv = 1
    var display_name = ""
    var explain = ""
    var clear_item = ""
    var enemies = [""]
    var boss = ""
    
    // plist からデータを読み込む
    func readDataByPlist(){
        let dataPath = Bundle.main.path(forResource: "worlds", ofType:"plist" )!
        dictionary = NSDictionary(contentsOfFile: dataPath)!
    }
    
    func setData(_ key : String){
        let data = dictionary.object(forKey: key) as! NSDictionary
        display_name    = data.object(forKey: "name") as! String
        lv              = data["lv"] as! Int
        clear_item      = data.object(forKey: "clear_item") as! String
        explain         = data.object(forKey: "explain") as! String
        enemies         = data.object(forKey: "enemies") as! Array
        boss            = data.object(forKey: "boss") as! String
    }
    
    // 地名を取得
    func getName(_ key: String) -> String {
        let data = dictionary.object(forKey: key) as! NSDictionary
        let name = data.object(forKey: "name") as! String
        return name
    }
    
    // 説明文を取得
    func getExplain(_ key: String) -> String {
        let data = dictionary.object(forKey: key) as! NSDictionary
        let explain = data.object(forKey: "explain") as! String
        return explain
    }
}
