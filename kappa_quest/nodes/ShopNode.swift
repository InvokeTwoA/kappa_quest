import Foundation
import SpriteKit

class ShopNode: SKSpriteNode {
    
    class func makeShop() -> ShopNode {
        let shop = ShopNode(imageNamed: "shop")
        shop.size = CGSize(width: Const.shopSize, height: Const.shopSize)
        shop.anchorPoint = CGPoint(x: 0.5, y: 0)     // 中央下がアンカーポイント
        shop.zPosition = 0
        shop.alpha = 0.9
        shop.name = "shop"
        return shop
    }
}
