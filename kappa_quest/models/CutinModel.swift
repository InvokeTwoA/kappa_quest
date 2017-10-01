import Foundation

class CutinModel {
    
    // plist から読み込んだ職業データ
    private var dictionary : NSDictionary!
    private var pageData : [NSDictionary]!
    
    
    var image = ""
    var name = ""
    var text1 = ""
    var text2 = ""
    var max_page = 0
    
    // plist からデータを読み込む
    func readDataByPlist(_ key : String) {
        let dataPath = Bundle.main.path(forResource: "cutin", ofType:"plist" )!
        dictionary = NSDictionary(contentsOfFile: dataPath)!
        pageData = dictionary[key] as! [NSDictionary]
        max_page = pageData.count
    }

    func setDataByPage(_ page : Int){
        let data = pageData[page]
        image   = data["image"] as! String
        name    = data["name"] as! String
        text1   = data["text1"] as! String
        text2   = data["text2"] as! String
    }
}
