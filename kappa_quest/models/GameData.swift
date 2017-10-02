// ゲームデータを格納

import Foundation

class GameData {

    var tapCount = 0
    
    var nickname = "駆け出しの"
    var name = "カッパ"
    
    // option
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
        nickname        = UserDefaults.standard.string(forKey: "nickname")!
        name            = UserDefaults.standard.string(forKey: "name")!
    }
    
    func saveParam(){
        UserDefaults.standard.set(tapCount,         forKey: "tapCount")
        UserDefaults.standard.set(bgmFlag,          forKey: "bgm")
        UserDefaults.standard.set(soundEffectFlag,  forKey: "sound_effect")
        UserDefaults.standard.set(nickname,         forKey: "nickname")
        UserDefaults.standard.set(name,          forKey: "name")
    }
    
    func displayName(_ job : String) -> String {
        return "\(nickname)\(job)\(name)"
    }
    
    
    func getSkill(key : String){
        UserDefaults.standard.set(true,  forKey: key)
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
    
    func changeNicknameByLV(lv : Int){
        if lv == 3 {
            let list = ["そこそこ慣れた", "一人前の", "すごい"]
            nickname = list[CommonUtil.rnd(list.count)]
        } else if lv == 5 {
            let list = ["ハイパー", "スーパー", "超", "ベテラン", "一流"]
            nickname = list[CommonUtil.rnd(list.count)]
        } else if lv == 10 {
            let list = ["ザ・", "天才", "至高の", "マスター", "かっこいい", "偉大なる"]
            nickname = list[CommonUtil.rnd(list.count)]
        } else if lv == 20 {
            let list = ["究極の", "さすが", "最後の", "極めし", "伝説の"]
            nickname = list[CommonUtil.rnd(list.count)]
        }
        UserDefaults.standard.set(nickname,  forKey: "nickname")
    }
    
    func changeNicknameByDeath(){
        if CommonUtil.rnd(5) == 0 {
            return
        }
        
        let list = [
            "悲しみの",
            "ゾンビ",
            "死の",
            "ヘタレ",
            "敗北の",
            "復讐の",
        ]
        nickname = list[CommonUtil.rnd(list.count)]
        UserDefaults.standard.set(nickname,  forKey: "nickname")
    }
    

    class func isExistData() -> Bool {
        return UserDefaults.standard.object(forKey: "lv") != nil
    }
    
    class func clearCountUp(_ key : String){
        let clear_count = UserDefaults.standard.integer(forKey: "stage_\(key)_clear")
        UserDefaults.standard.set(clear_count+1,  forKey: "stage_\(key)_clear")
    }
    
    class func isClear(_ key : String) -> Bool {
        return UserDefaults.standard.object(forKey: "stage_\(key)_clear") != nil
    }
    
    class func notChangeJob(){
        UserDefaults.standard.set(false,  forKey: "change_job")
    }
    
    class func jobChangeDone(){
        UserDefaults.standard.set(true,  forKey: "change_job")
    }

    class func isChangeJob() -> Bool {
        return UserDefaults.standard.bool(forKey: "change_job")
    }
    
    
}
