// 戦闘用クラス
import Foundation

class BattleModel {
    
    // クリティカル発生率
    class func criticalPer(luc : Double) -> Int {
        let per = Double(luc/(1000.0+luc)*1000.0)
        return Int(per)
    }
    
    class func displayCriticalPer(luc : Int) -> Double {
        let per = Double(BattleModel.criticalPer(luc: Double(luc)))
        return per/10.0
    }
    
    // クリティカルだったかどうかを返す
    class func isCritical(luc : Double) -> Bool {
        let per = criticalPer(luc: luc)
        return (CommonUtil.rnd(1000) <= per)
    }
    
    class func calculateDamage(str: Int, def: Int) -> Int {
        if def < 0 {
            return 9999999
        }
        let damage = CommonUtil.valueMin1(str - CommonUtil.rnd(def))
        return damage
    }

    class func calculateCriticalDamage(str: Int, def: Int) -> Int {
        var damage = CommonUtil.valueMin1(str - CommonUtil.minimumRnd(def))
        damage *= 2
        return damage
    }
    
    
}
