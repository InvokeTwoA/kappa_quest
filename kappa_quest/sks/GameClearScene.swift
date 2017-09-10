// ゲームクリア画面
import SpriteKit
import GameplayKit

class GameClearScene: BaseScene {
    
    override func sceneDidLoad() {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let positionInScene = t.location(in: self)
            let tapNode = self.atPoint(positionInScene)
            if tapNode.name == nil {
                return
            }
            switch tapNode.name! {
            case "ContinueNode", "ContinueLabel":
                goWorld()
            default:
                break
            }
        }
    }
}
