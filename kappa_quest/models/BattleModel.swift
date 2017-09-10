// 戦闘用クラス
import Foundation

class BattleModel {
    
    // クリティカル発生率
    class func criticalPer(luc : Double) -> Int {
        var per = Double(luc/(1000.0+luc)*1000.0)
        return Int(per)
    }
    
    class func displayCriticalPer(luc : Int) -> Double {
        let per = Double(BattleModel.criticalPer(luc: Double(luc)))
        return per/10.0
    }

    // アイテム取得確率
    class func treasurePer(luc : Double) -> Int {
        var per = Double(luc/(3000.0+luc)*1000.0)
        return Int(per)
    }

    class func displayTreasurePer(luc : Int) -> Double {
        let per = Double(BattleModel.treasurePer(luc: Double(luc)))
        
        return per/10.0
    }
    
    // クリティカルだったかどうかを返す
    class func isCritical(luc : Double) -> Bool {
        let per = criticalPer(luc: luc)
        return (CommonUtil.rnd(1000) <= per)
    }
    
    // アイテム取得できたかどうかの判定
    class func isTreasure(luc : Double) -> Bool {
        let per = treasurePer(luc: luc)
        return (CommonUtil.rnd(10) <= per)
//        return (CommonUtil.rnd(1000) <= per)
    }
    
    
    class func calculateDamage(str: Int, def: Int) -> Int {
        var damage = str - CommonUtil.rnd(def)
        if damage <= 0 {
            damage = 1
        }
        return damage
    }

    class func calculateCriticalDamage(str: Int, def: Int) -> Int {
        var damage = str - CommonUtil.minimumRnd(def)
        if damage <= 0 {
            damage = 1
        }
        damage *= 2
        return damage
    }
    
    
}
