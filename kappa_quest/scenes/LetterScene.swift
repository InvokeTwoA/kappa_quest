// 手紙（オープニング）画面
import SpriteKit
import GameplayKit

class LetterScene: SKScene {
    
    override func sceneDidLoad() {
    }
    
    func goGame(){
        let scene = GameScene(fileNamed: "GameScene")
        scene?.size = self.scene!.size
        scene?.scaleMode = SKSceneScaleMode.aspectFill
        self.view!.presentScene(scene!, transition: .fade(withDuration: Const.transitionInterval))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let positionInScene = t.location(in: self)
            let tapNode = self.atPoint(positionInScene)
            if tapNode.name == nil {
                return
            }
            
            switch tapNode.name! {
            case "ButtonNode", "ButtonLabel":
                goGame()
            default:
                break
            }
        }
    }
}
