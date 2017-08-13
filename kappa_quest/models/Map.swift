import Foundation

class Map {

    var isMoving = false
    
    var positionData = Array(arrayLiteral: "free", "free", "free", "free", "enemy", "enemy", "free", "free")

    var myPosition = 1  // 自分のいる位置   0(左端) 1 2 3 4 5 6 7 8(右画面へ)
    
    var distanceInt = 0
    var maxDistanceInt = 0
    
    var distance = 0.0  // 移動距離
    var maxDistance = 0.0 // 最高移動距離

    func updatePositionData(){
//        let rndArray = ["free", "enemy"]
        for num in 3...(Const.maxPosition-2) {
//            positionData[num] = rndArray[CommonUtil.rnd(rndArray.count)]
            positionData[num] = "enemy"
        }
        positionData[0] = "free"
        positionData[Const.maxPosition-1] = "free"
        
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
    
    func isShop() -> Bool {
        return positionData[myPosition] == "shop"
    }
    
    // パラメーターを userDefault から読み取り
    func setParameterByUserDefault(){
        if UserDefaults.standard.object(forKey: "lv") == nil {
            return
        }
        distanceInt     = UserDefaults.standard.integer(forKey: "distance")
        maxDistanceInt  = UserDefaults.standard.integer(forKey: "maxDistance")
        distance        = Double(distance)/10.0
        maxDistance     = Double(maxDistanceInt)/10.0
    }
    
    func saveParam(){
        distanceInt = Int(distance*10)
        maxDistanceInt = Int(maxDistance*10)
        UserDefaults.standard.set(distanceInt,  forKey: "distance")
        UserDefaults.standard.set(distanceInt,  forKey: "maxDistance")
    }



}
