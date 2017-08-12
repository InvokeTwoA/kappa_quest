// 上下移動するコンポーネント

import Foundation

class UpDownMoveComponent: GKComponent {
    let node: SKNode
    
    init(node: SKNode) {
        self.node = node
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        node.position.y += 1
    }
}
