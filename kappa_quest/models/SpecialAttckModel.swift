// １章専用
// 必殺技の管理モデル
import Foundation
class SpecialAttackModel {
    
    private let BAR_LENGTH : Double = 131.0

    var is_attacking = false  // スペシャル攻撃を実行中かどうか
    var mode = ""             // 何の技か

    func finishAttack(){
        mode = ""
        is_attacking = false
        is_upper = false
        is_tornado = false
        is_head = false
    }

    func countUp() {
        superHeadCount += 1
        if superHeadCount >= SPECIAL_HEAD_NEED_COUNT {
            superHeadCount = SPECIAL_HEAD_NEED_COUNT
        }
        superHadoCount += 1
        if superHadoCount >= SPECIAL_HADO_NEED_COUNT {
            superHadoCount = SPECIAL_HADO_NEED_COUNT
        }
        superUpperCount += 1
        if superUpperCount >= SPECIAL_UPPER_NEED_COUNT {
            superUpperCount = SPECIAL_UPPER_NEED_COUNT
        }
        superTornadoCount += 1
        if superTornadoCount >= SPECIAL_TORNADO_NEED_COUNT {
            superTornadoCount = SPECIAL_TORNADO_NEED_COUNT
        }
    }

    /***********************************************************************************/
    /****************************** head attack ****************************************/
    /***********************************************************************************/
    private var superHeadCount = 10  // スーパー頭突きの管理変数
    private let SPECIAL_HEAD_NEED_COUNT = 10
    var is_head = false
    func execHead(){
        superHeadCount = 0
        is_attacking = true
        is_head = true
        mode = "head"
    }
    
    func canSpecialHead() -> Bool {
        return superHeadCount >= SPECIAL_HEAD_NEED_COUNT
    }
    
    func barSpecialHead() -> Double {
        return Double(superHeadCount)/Double(SPECIAL_HEAD_NEED_COUNT)*BAR_LENGTH
    }
    
    /***********************************************************************************/
    /***************************** upper attack ****************************************/
    /***********************************************************************************/
    private var superUpperCount = 18  // 昇竜拳の管理変数
    private let SPECIAL_UPPER_NEED_COUNT = 18
    var is_upper = false

    func execUpper(){
        superUpperCount = 0
        is_attacking = true
        is_upper = true
        mode = "upper"
    }
    
    func canSpecialUpper() -> Bool {
        return superUpperCount >= SPECIAL_UPPER_NEED_COUNT
    }

    func barSpecialUpper() -> Double {
        return Double(superUpperCount)/Double(SPECIAL_UPPER_NEED_COUNT)*BAR_LENGTH
    }

    /***********************************************************************************/
    /***************************** tornado attack **************************************/
    /***********************************************************************************/
    private var superTornadoCount = 12  // 竜巻旋風脚の管理変数
    private let SPECIAL_TORNADO_NEED_COUNT = 12
    var is_tornado = false

    func execTornado(){
        superTornadoCount = 0
        is_attacking = true
        is_tornado = true
        mode = "tornado"
    }
    
    func canSpecialTornado() -> Bool {
        return superTornadoCount >= SPECIAL_TORNADO_NEED_COUNT
    }
    
    func barSpecialTornado() -> Double {
        return Double(superTornadoCount)/Double(SPECIAL_TORNADO_NEED_COUNT)*BAR_LENGTH
    }

    /***********************************************************************************/
    /***************************** kappa_hado     **************************************/
    /***********************************************************************************/
    private var superHadoCount = 15  // 波動の管理変数
    private let SPECIAL_HADO_NEED_COUNT = 15

    func execHado(){
        superHadoCount = 0
        is_attacking = true
        mode = "hado"
    }

    func canSpecialHado() -> Bool {
        return superHadoCount >= SPECIAL_HADO_NEED_COUNT
    }

    func barSpecialHado() -> Double {
        return Double(superHadoCount)/Double(SPECIAL_HADO_NEED_COUNT)*BAR_LENGTH
    }
}

