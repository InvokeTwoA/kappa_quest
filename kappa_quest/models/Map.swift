import Foundation

class Map {

    var isMoving = false
    var myPosition = 1  // 自分のいる位置   0(左端) 1 2 3 4 5 6 7 8(右画面へ)
    
    // 敵情報
    var positionData = Array(arrayLiteral: "free", "free", "free", "free", "enemy", "enemy", "free", "free")
    var enemies : [String]!
    var treasures = Array(arrayLiteral: "", "", "", "", "", "", "", "")
    var treasureFlag = false
    var treasureExplainFlag = false

    // 距離情報
    var distanceInt = 0
    var distance = 0.0

    // 地図情報
    var lv = 1
    var mapData = NSDictionary()
    var background = "bg_green"
    var isEvent : Bool = false
    var isRandom : Bool = false
    var isBoss : Bool = false
    var text0 = ""
    var text1 = ""
    var boss_text0 = ""
    var boss_text1 = ""
    
    func initData(){
        distance = 0.0
        distanceInt = 0
        saveParam()
    }
    
    func readDataByPlist(_ key : String){
        let map_name = "map_\(key)"
        let mapDataPath = Bundle.main.path(forResource: map_name, ofType:"plist" )!
        mapData = NSDictionary(contentsOfFile: mapDataPath)!
    }
    
    func loadMapDataByDistance(_ key : Double){
        if mapData["\(key)"] == nil {
            loadMapDataByDistance(key-0.1)
            return
        }
        let map_info = mapData["\(key)"] as! NSDictionary
        if map_info["enemies"] != nil {
            enemies = map_info["enemies"] as! [String]
        }
        if map_info["background"] != nil {
            background  = map_info["background"] as! String
        }
        isEvent     = map_info["event"] as! Bool
        isBoss      = map_info["is_boss"] as! Bool
        if map_info["is_random"] != nil {        
            isRandom    = map_info["is_random"] as! Bool
        }
        if isEvent {
            text0 = map_info["event_text0"] as! String
            text1 = map_info["event_text1"] as! String
        }
        
        if map_info["lv"] != nil {
            lv = map_info["lv"] as! Int
        }
        if isBoss {
            boss_text0 = map_info["boss_word0"] as! String
            boss_text1 = map_info["boss_word1"] as! String
        }
    }
    
    func updatePositionData(){
        loadMapDataByDistance(distance)
        for num in 3...(Const.maxPosition-1) {
            if enemies.count == 0 {
                positionData[num] = "free"
            } else {
                positionData[num] = "enemy"
            }
        }
        positionData[0] = "free"
    }
    
    func canMoveRight() -> Bool {
        if positionData.count < myPosition + 1 {
            return false
        }
        return positionData[myPosition+1] == "free" || positionData[myPosition+1] == "treasure"
    }
    
    func canMoveLeft() -> Bool {
        if myPosition <= 1 {
            return false
        }
        return true
    }
    
    func goNextMap(){
        distance += 0.1
        treasureFlag = false
        saveParam()
    }
    
    func isTreasure() -> Bool {
        return positionData[myPosition] == "treasure"
    }
    
    // 近くの敵の数を返す。敵がいなければ0を返す
    func nearEnemyPosition() -> Int {
        for (index, positionData) in positionData.enumerated() {
            if positionData == "enemy" {
                return index
            }
        }
        return Const.maxPosition
    }
    
    // パラメーターを userDefault から読み取り
    func loadParameterByUserDefault(){
        if UserDefaults.standard.object(forKey: "lv") == nil {
            return
        }
        distanceInt     = UserDefaults.standard.integer(forKey: "distance")
        distance        = Double(distanceInt)/10.0
    }
    
    // リセットデータ（主にゲームオーバー時）
    func resetData(){
        distance = 0.0
        distanceInt = 0
        saveParam()
        loadMapDataByDistance(distance)
        updatePositionData()
    }
    
    // データ保存
    func saveParam(){
        distanceInt = Int(distance*10)
        UserDefaults.standard.set(distanceInt,  forKey: "distance")
    }
}
