import Foundation
import SpriteKit

class TreasureNode: SKSpriteNode {

    var item_name = "shoes"
    var pos = 0
    var explainFlag = false

    class func makeTreasure() -> TreasureNode {
        let treasure = TreasureNode(imageNamed: "treasure")
        treasure.size = CGSize(width: Const.enemySize, height: Const.enemySize)
        treasure.anchorPoint = CGPoint(x: 0.5, y: 0)     // 中央下がアンカーポイント
        treasure.zPosition = 2
        treasure.name = "treasure"
        treasure.item_name = EquipModel.getRandom()
        return treasure
    }
}
