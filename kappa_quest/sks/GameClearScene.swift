// ゲームクリア画面
import SpriteKit
import GameplayKit

class GameClearScene: BaseScene {
    
    var world = ""
    
    override func sceneDidLoad() {
    }

    override func didMove(to view: SKView) {
        switch world {
        case "tutorial", "thief", "priest":
            GameData.clearFlag(world)
            break
        default:
            break
        }
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
