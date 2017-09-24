import Foundation

class SpecialAttackModel {

    var is_attacking = false  // スペシャル攻撃を実行中かどうか
    var mode = ""             // 何の技か

    func finishAttack(){
        mode = ""
        is_attacking = false
    }

    // 必殺技可能な状態か
    func isSpecial() -> Bool {
        return (superHeadCount == 5 || superUpperCount == 5 || superTornadoCount == 5)
    }

    // 必殺技可能な技名を返す
    func specialName() -> String {
        if superHeadCount == 5 {
            return "head"
        } else if superUpperCount == 5 {
            return "upper"
        } else if superTornadoCount == 5 {
            return "tornado"
        } else {
            return ""
        }
    }
    
    
    func countUp(direction : String) {
        countUpHeadAttack(direction: direction)
        countUpUpperAttack(direction: direction)
        countUpTornadoAttack(direction: direction)
    }

    /***********************************************************************************/
    /****************************** head attack ****************************************/
    /***********************************************************************************/
    private var superHeadCount = 0  // スーパー頭突きの管理変数
    func countUpHeadAttack(direction : String) {
        if direction == "right" {
            if superHeadCount == 2 || superHeadCount == 4 {
                superHeadCount += 1
            } else {
                superHeadCount = 0
            }
        } else if direction == "left" {
            if superHeadCount == 0 || superHeadCount == 1 || superHeadCount == 3 {
                superHeadCount += 1
            } else {
                superHeadCount = 1
            }
        }
    }

    func displayHeadCount() -> String {
        switch superHeadCount {
        case 0:
            return "← ← → ← →"
        case 1:
            return "⬅︎ ← → ← →"
        case 2:
            return "⬅︎ ⬅︎ → ← →"
        case 3:
            return "⬅︎ ⬅︎ ➡︎ ← →"
        case 4:
            return "⬅︎ ⬅︎ ➡︎ ⬅︎ →"
        case 5:
            return "⬅︎ ⬅︎ ➡︎ ⬅︎ ➡︎"
        default:
            return ""
        }
    }

    func execHead(){
        superHeadCount = 0
        is_attacking = true
        mode = "head"
    }

    /***********************************************************************************/
    /***************************** upper attack ****************************************/
    /***********************************************************************************/
    private var superUpperCount = 0  // 昇竜拳の管理変数
    func countUpUpperAttack(direction : String) {
        if direction == "right" {
            if superUpperCount == 0 || superUpperCount == 1 || superUpperCount == 3 {
                superUpperCount += 1
            } else {
                superUpperCount = 1
            }
        } else if direction == "left" {
            if superUpperCount == 2 || superUpperCount == 4 {
                superUpperCount += 1
            } else {
                superUpperCount = 0
            }
        }
    }

    func displayUpperCount() -> String {
        switch superUpperCount {
        case 0:
            return "→ → ← → ←"
        case 1:
            return "➡︎ → ← → ←"
        case 2:
            return "➡︎ ➡︎ ← → ←"
        case 3:
            return "➡︎ ➡︎ ⬅︎ → ←"
        case 4:
            return "➡︎ ➡︎ ⬅︎ ➡︎ ←"
        case 5:
            return "➡︎ ➡︎ ⬅︎ ➡︎ ⬅︎"
        default:
            return ""
        }
    }

    func execUpper(){
        superUpperCount = 0
        is_attacking = true
        mode = "upper"
    }

    /***********************************************************************************/
    /***************************** tornado attack **************************************/
    /***********************************************************************************/
    private var superTornadoCount = 0  // 竜巻旋風脚の管理変数
    func countUpTornadoAttack(direction : String) {
        if direction == "right" {
            if superTornadoCount == 1 || superTornadoCount == 2 || superTornadoCount == 3 {
                superTornadoCount += 1
            } else {
                superTornadoCount = 0
            }
        } else if direction == "left" {
            if superTornadoCount == 0 || superTornadoCount == 4 {
                superTornadoCount += 1
            } else {
                superTornadoCount = 1
            }
        }
    }

    func displayTornadoCount() -> String {
        switch superTornadoCount {
        case 0:
            return "← → → → ←"
        case 1:
            return "⬅︎ → → → ←"
        case 2:
            return "⬅︎ ➡︎ → → ←"
        case 3:
            return "⬅︎ ➡︎ ➡︎ → ←"
        case 4:
            return "⬅︎ ➡︎ ➡︎ ➡︎ ←"
        case 5:
            return "⬅︎ ➡︎ ➡︎ ➡︎ ⬅︎"
        default:
            return ""
        }
    }

    func execTornado(){
        superTornadoCount = 0
        is_attacking = true
        mode = "tornado"
    }
}
