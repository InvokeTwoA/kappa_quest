// アップデート履歴を管理するモデル
import Foundation

class UpdateModel {
    
    // plist から読み込んだ職業データ
    var dictionary : NSDictionary!
    
    // plist からデータを読み込む
    func readDataByPlist(){
        let dataPath = Bundle.main.path(forResource: "update_history", ofType:"plist" )!
        dictionary = NSDictionary(contentsOfFile: dataPath)!
    }
    
    // 説明文を取得
    func getHistory(_ key: String) -> String {
        let res = dictionary.object(forKey: key) as! String
        return res
    }
}
