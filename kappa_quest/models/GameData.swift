// ゲームデータを格納

import Foundation

class GameData {

    var tapCount = 0
    var bgmFlag = true
    var soundEffectFlag = true
    
    // パラメーターを userDefault から読み取り
    func setParameterByUserDefault(){
        if UserDefaults.standard.object(forKey: "lv") == nil {
            return
        }
        tapCount        = UserDefaults.standard.integer(forKey: "tapCount")
        bgmFlag         = UserDefaults.standard.bool(forKey: "bgm")
        soundEffectFlag = UserDefaults.standard.bool(forKey: "sound_effect")

    }
    
    func saveParam(){
        UserDefaults.standard.set(tapCount,         forKey: "tapCount")
        UserDefaults.standard.set(bgmFlag,          forKey: "bgm")
        UserDefaults.standard.set(soundEffectFlag,  forKey: "sound_effect")
    }

    func bgmChange(){
        if bgmFlag {
            bgmFlag = false
        } else {
            bgmFlag = true
        }
        saveParam()
    }
    
    func soundEffectChange(){
        if soundEffectFlag {
            soundEffectFlag = false
        } else {
            soundEffectFlag = true
        }
        saveParam()
    
    }

    class func isExistData() -> Bool {
        return UserDefaults.standard.object(forKey: "lv") != nil
    }

}
