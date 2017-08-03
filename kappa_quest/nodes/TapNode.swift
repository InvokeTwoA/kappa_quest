import Foundation
import SpriteKit

class TapNode: SKShapeNode {
    
    func makeNode(size: CGFloat) -> TapNode {
        let tapNode = SKShapeNode(circleOfRadius: size) as! TapNode
        
        tapNode.lineWidth = 2.5
        tapNode.run(SKAction.scale(by: 5, duration: 1.0))
        tapNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                    SKAction.fadeOut(withDuration: 0.5),
                                    SKAction.removeFromParent()]))
        return tapNode
    }
    
}
