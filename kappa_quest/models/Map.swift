import Foundation

class Map {

    var isMoving = false
    var myPosition = 1  // 自分のいる位置   0(左端) 1 2 3 4 5 6 7 8(右画面へ)
    
    // 敵情報
    var positionData = Array(arrayLiteral: "free", "free", "free", "free", "enemy", "enemy", "free", "free")
    var enemies : [String]!

    // 距離情報
    var distanceInt = 0
    var maxDistanceInt = 0
    var distance = 0.0
    var maxDistance = 0.0

    // 地図情報
    var mapData = NSDictionary()
    var background = "bg_green"
    var isEvent : Bool = false
    var text0 = ""
    var text1 = ""
    
    func readDataByPlist(){
        let mapDataPath = Bundle.main.path(forResource: "maps", ofType:"plist" )!
        mapData = NSDictionary(contentsOfFile: mapDataPath)!
    }
    
    func loadMapDataByDistance(){
        if mapData["\(distance)"] == nil {
            return
        }
        let map_info = mapData["\(distance)"] as! NSDictionary
        enemies     = map_info["enemies"] as! [String]
        background  = map_info["background"] as! String
        isEvent     = map_info["event"] as! Bool
        
        if isEvent {
            text0 = map_info["event_text0"] as! String
            text1 = map_info["event_text1"] as! String
        }
    }
    
    func updatePositionData(){
        loadMapDataByDistance()
        for num in 3...(Const.maxPosition-1) {
            if enemies.count == 0 {
                positionData[num] = "free"
            } else {
                positionData[num] = "enemy"
            }
        }
        positionData[0] = "free"
        if Int(distance*10) == 3 {
            positionData[4] = "shop"
        }
    }
    
    func canMoveRight() -> Bool {
        if positionData.count < myPosition + 1 {
            return false
        }
        return positionData[myPosition+1] == "free" || positionData[myPosition+1] == "shop"
    }
    
    func canMoveLeft() -> Bool {
        if myPosition <= 1 {
            return false
        }
        return true
    }
    
    func goNextMap(){
        distance += 0.1
        if distance > maxDistance {
            maxDistance = distance
        }
        saveParam()
    }
    
    func isShop() -> Bool {
        return positionData[myPosition] == "shop"
    }
    
    // パラメーターを userDefault から読み取り
    func loadParameterByUserDefault(){
        if UserDefaults.standard.object(forKey: "lv") == nil {
            return
        }
        distanceInt     = UserDefaults.standard.integer(forKey: "distance")
        maxDistanceInt  = UserDefaults.standard.integer(forKey: "maxDistance")
        
        distance        = Double(distanceInt)/10.0
        maxDistance     = Double(maxDistanceInt)/10.0
    }
    
    // リセットデータ（主にゲームオーバー時）
    func resetData(){
        distance = 0.0
        distanceInt = 0
        loadMapDataByDistance()
        updatePositionData()
    }
    
    // データ保存
    func saveParam(){
        distanceInt = Int(distance*10)
        maxDistanceInt = Int(maxDistance*10)
        UserDefaults.standard.set(distanceInt,  forKey: "distance")
        UserDefaults.standard.set(distanceInt,  forKey: "maxDistance")
    }
}
