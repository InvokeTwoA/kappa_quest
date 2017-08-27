// ゲームデータを格納

import Foundation

class GameData {

    var tapCount = 0
    var bgmFlag = true
    
    // パラメーターを userDefault から読み取り
    func setParameterByUserDefault(){
        if UserDefaults.standard.object(forKey: "lv") == nil {
            return
        }
        tapCount = UserDefaults.standard.integer(forKey: "tapCount")
        bgmFlag  = UserDefaults.standard.bool(forKey: "bgm")
        
        print("load bgm= \(bgmFlag)")
    }
    
    func saveParam(){
        UserDefaults.standard.set(tapCount,     forKey: "tapCount")
        UserDefaults.standard.set(bgmFlag,     forKey: "bgm")
    }

    func bgmChange(){
        if bgmFlag {
            bgmFlag = false
        } else {
            bgmFlag = true
        }
        saveParam()
    }
    
}
