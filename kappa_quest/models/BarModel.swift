import Foundation

class BarModel {
    
    // plist から読み込んだ職業データ
    var dictionary : NSDictionary!
    
    // plist からデータを読み込む
    func readDataByPlist(){
        let dataPath = Bundle.main.path(forResource: "bar", ofType:"plist" )!
        dictionary = NSDictionary(contentsOfFile: dataPath)!
    }
    
    // スキル説明文を取得
    func getList(_ key: String) -> [String] {
        let list = dictionary.object(forKey: key) as! [String]
        return list
    }    
}
