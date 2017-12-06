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
    var chapter = 1
    var sizeFreeFlag = false
    
    // plist からデータを読み込む
    func readDataByPlist(_ key : String, chapter : Int = 1) {
        var dataPath = Bundle.main.path(forResource: "cutin", ofType:"plist" )!

        if chapter == 2 {
            dataPath = Bundle.main.path(forResource: "cutin2", ofType:"plist" )!
        }
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
        
        if data["sizeFree"] != nil {
            sizeFreeFlag = true
        } else {
            sizeFreeFlag = false
        }
    }
}
