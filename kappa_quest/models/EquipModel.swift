// 装備品管理モデル
import Foundation
class EquipModel {

    // plist から読み込んだ職業データ
    var dictionary : NSDictionary!

    // plist からデータを読み込む
    func readDataByPlist(){
        let dataPath = Bundle.main.path(forResource: "equips", ofType:"plist" )!
        dictionary = NSDictionary(contentsOfFile: dataPath)!
    }

    // 装備説明文を取得
    func getName(_ key: String) -> String {
        if key == "" {
            return "なし"
        }
        let data = dictionary.object(forKey: key) as! NSDictionary
        let name = data.object(forKey: "name") as! String
        return name
    }

    // 装備説明文を取得
    func getExplain(_ key: String) -> String {
        if key == "" {
            return "何も装備をしていない状態"
        }
        let data = dictionary.object(forKey: key) as! NSDictionary
        let explain = data.object(forKey: "explain") as! String
        return explain
    }

    class func getRandom() -> String {
        let array = [
            "shoes",
            "head",
            "exp",
            "float"
        ]
        return array[CommonUtil.rnd(array.count)]
    }
}
