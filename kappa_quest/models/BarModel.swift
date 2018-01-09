import Foundation

class BarModel {
    var chapter = 1
    
    // plist から読み込んだ職業データ
    var dictionary : NSDictionary!
    
    // plist からデータを読み込む
    func readDataByPlist(){
        if chapter == 1 {
            let dataPath = Bundle.main.path(forResource: "bar", ofType:"plist" )!
            dictionary = NSDictionary(contentsOfFile: dataPath)!
        } else {
            let dataPath = Bundle.main.path(forResource: "bar2", ofType:"plist" )!
            dictionary = NSDictionary(contentsOfFile: dataPath)!
        }
    }
    
    func getList(_ key: String) -> [String] {
        print("key=\(key) chapter = \(chapter)")
        let list = dictionary.object(forKey: key) as! [String]
        return list
    }    
}
