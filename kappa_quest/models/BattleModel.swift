// 戦闘用クラス
import Foundation

class BattleModel {
    
    class func criticalPer(luc : Double) -> Int {
        var per = Double(luc/(1000.0+luc)*1000.0)
        print("per=\(per)")
        return Int(per)
    }

    // クリティカルだったかどうかを返す
    class func isCritical(luc : Double) -> Bool {
        let per = criticalPer(luc: luc)
        return (CommonUtil.rnd(1000) <= per)
    }
    
    class func calculateDamage(str: Int, def: Int) -> Int {
        var damage = str - CommonUtil.rnd(def)
        if damage <= 0 {
            damage = 1
        }
        return damage
    }

    
    
}
