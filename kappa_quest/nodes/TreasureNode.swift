import Foundation
import SpriteKit

class TreasureNode: SKSpriteNode {
    
    var item_name = "shoes"
    var pos = 0
    
    class func makeTreasure() -> TreasureNode {
        let treasure = TreasureNode(imageNamed: "treasure")
        treasure.size = CGSize(width: Const.enemySize, height: Const.enemySize)
        treasure.anchorPoint = CGPoint(x: 0.5, y: 0)     // 中央下がアンカーポイント
        treasure.zPosition = 2
        treasure.name = "treasure"
        treasure.item_name = getRandomTreasure()
        
        return treasure
    }
    
    class func getRandomTreasure() -> String {
        let array = [
            "shoes",
            "head",
            "exp"
        ]
        return array[CommonUtil.rnd(array.count)]
    }
    
    class func explain0(_ key : String) -> String {
        var explain = ""
        switch key {
        case "shoes":
            explain = "疾風の靴"
        case "head":
            explain = "バンダナ"
        case "exp":
            explain = "経験の書"
        case "":
            explain = "宝箱は空っぽだ"
        default:
            break
        }
        return explain
    }
    
    class func explain1(_ key : String) -> String {
        var explain = ""
        switch key {
        case "shoes":
            explain = "移動がとても早くなる。"
        case "":
            explain = ""
        default:
            break
        }
        return explain
    }
    
    
}
