import Foundation

class SkillModel {
    
    // plist から読み込んだ職業データ
    var dictionary : NSDictionary!
    
    // plist からデータを読み込む
    func readDataByPlist(){
        let dataPath = Bundle.main.path(forResource: "skills", ofType:"plist" )!
        dictionary = NSDictionary(contentsOfFile: dataPath)!
    }
    
    // スキル説明文を取得
    func getExplain(_ key: String) -> String {
        let explain = dictionary.object(forKey: key) as! String
        return explain
    }
    
    
    var konjoFlag = false
}
