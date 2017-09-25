// メニューバーなどの、世界的な要素
import Foundation
import SpriteKit

class WorldNode: SKSpriteNode {

    class func setWorldPhysic(physicBody : SKPhysicsBody) {
        physicBody.categoryBitMask = Const.worldCategory
        physicBody.affectedByGravity = false
        physicBody.isDynamic = false
    }

    // 重力を持つ事で要素は沈んでいく
    class func setWorldEnd(physicBody : SKPhysicsBody){
        physicBody.categoryBitMask = Const.worldCategory
        physicBody.affectedByGravity = true
        physicBody.isDynamic = true
    }
}
