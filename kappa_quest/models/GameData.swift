// ゲームデータを格納

import Foundation

class GameData {

    var tapCount = 0
    
    // option
    var bgmFlag = true
    var soundEffectFlag = true
    
    // flag
    var konjoFlag = false
    
    // other
    var equip = ""
    
    
    // パラメーターを userDefault から読み取り
    func setParameterByUserDefault(){
        if UserDefaults.standard.object(forKey: "lv") == nil {
            return
        }
        tapCount        = UserDefaults.standard.integer(forKey: "tapCount")
        bgmFlag         = UserDefaults.standard.bool(forKey: "bgm")
        soundEffectFlag = UserDefaults.standard.bool(forKey: "sound_effect")
        konjoFlag       = UserDefaults.standard.bool(forKey: "konjo")
        
        if UserDefaults.standard.string(forKey: "equip") != nil {
            equip           = UserDefaults.standard.string(forKey: "equip")!
        }
    }
    
    func saveParam(){
        UserDefaults.standard.set(tapCount,         forKey: "tapCount")
        UserDefaults.standard.set(bgmFlag,          forKey: "bgm")
        UserDefaults.standard.set(soundEffectFlag,  forKey: "sound_effect")
    }
    
    func getSkill(key : String){
        UserDefaults.standard.set(true,  forKey: key)
    }
    
    // 装備品を手にいれた
    func setEquip(key : String){
        equip = key
        UserDefaults.standard.set(key,  forKey: "equip")
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
    
    class func clearFlag(_ key : String){
        UserDefaults.standard.set(true,  forKey: "stage_\(key)_clear")
    }
    
    class func isClear(_ key : String) -> Bool {
        return UserDefaults.standard.object(forKey: "stage_\(key)_clear") != nil
    }
    


}
