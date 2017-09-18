import Foundation

class WorldModel {
    
    // plist から読み込んだ職業データ
    var dictionary : NSDictionary!
    
    // plist からデータを読み込む
    func readDataByPlist(){
        let dataPath = Bundle.main.path(forResource: "worlds", ofType:"plist" )!
        dictionary = NSDictionary(contentsOfFile: dataPath)!
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
