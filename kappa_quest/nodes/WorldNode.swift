// メニューバーなどの、世界的な要素
import Foundation
import SpriteKit

class WorldNode: SKSpriteNode {

    class func setWorldPhysic(_ physicBody : SKPhysicsBody) {
        physicBody.categoryBitMask = Const.worldCategory
        physicBody.affectedByGravity = false
        physicBody.isDynamic = false
    }
    
    class func setUnvisibleWorldPhysic(_ physicBody : SKPhysicsBody) {
        physicBody.categoryBitMask = Const.unvisibleWorldCategory
        physicBody.affectedByGravity = false
        physicBody.isDynamic = false
    }


    // 重力を持つ事で要素は沈んでいく
    class func setWorldEnd(_ physicBody : SKPhysicsBody){
        physicBody.categoryBitMask = Const.worldCategory
        physicBody.affectedByGravity = true
        physicBody.isDynamic = true
    }
}
