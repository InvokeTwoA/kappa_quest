// ゲームデータを格納

import Foundation

class GameData {

    var tapCount = 0
    
    // パラメーターを userDefault から読み取り
    func setParameterByUserDefault(){
        if UserDefaults.standard.object(forKey: "lv") == nil {
            return
        }
        tapCount = UserDefaults.standard.integer(forKey: "tapCount")
    }
    
    func saveParam(){
        UserDefaults.standard.set(tapCount,     forKey: "tapCount")
    }
    
    

}
