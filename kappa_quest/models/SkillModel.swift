import Foundation

class SkillModel {
    
    // plist から読み込んだ職業データ
    var dictionary : NSDictionary!
    
    // plist からデータを読み込む
    func readDataByPlist(){
        let dataPath = Bundle.main.path(forResource: "skills", ofType:"plist" )!
        dictionary = NSDictionary(contentsOfFile: dataPath)!
    }
    
    // スキル説明文を取得
    func getExplain(_ key: String) -> String {
        let explain = dictionary.object(forKey: key) as! String
        return explain
    }

    // スキルフラグ
    var konjo_flag = false
    var hado_penetrate_flag = false
    var upper_rotate_flag = false
    var tap_dance_flag = false
    var super_head_flag = false
    var super_tornado_flag = false

    // スキル変数
    var heal_val = 0
    var necro_heal = 0
    var angel_heal = 0
    var lv_up_heal = 0
    var map_heal = 0
    var hado_heal = 0
    var upper_heal = 0
    

    func judgeSKill(){
        if JobModel.getLV("murabito") >= 5 {
            konjo_flag = true
        }
        if JobModel.getLV("wizard") >= 10 {
            hado_penetrate_flag = true
        }
        if JobModel.getLV("archer") >= 10 {
            upper_rotate_flag = true
        }
        if JobModel.getLV("dancer") >= 10 {
            tap_dance_flag = true
        }
        if JobModel.getLV("fighter") >= 10 {
            super_head_flag = true
        }
        if JobModel.getLV("gundom") >= 10 {
            super_tornado_flag = true
        }

        heal_val    = JobModel.getLV("priest")
        necro_heal  = JobModel.getLV("necro")
        angel_heal  = JobModel.getLV("angel")
        lv_up_heal  = JobModel.getLV("knight")
        map_heal    = JobModel.getLV("thief")
        hado_heal   = JobModel.getLV("king")
        upper_heal  = JobModel.getLV("maou")
    }

}
