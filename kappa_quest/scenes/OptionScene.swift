/* オプション画面 */
import SpriteKit
import GameplayKit

class OptionScene: SKScene {
    
    var backScene : MenuScene!
    
    override func didMove(to view: SKView) {
        updateText()
    }
    
    func goBack(){
        self.view!.presentScene(backScene, transition: .flipVertical(withDuration: Const.transitionInterval))
    }
    
    func bgmChange(){
        backScene.backScene.gameData.bgmChange()
        if backScene.backScene.gameData.bgmFlag {
            backScene.backScene.playBGM()
        } else {
            backScene.backScene.stopBGM()
        }
        updateText()
    }
    
    func updateText(){
        let BGMLabel     = childNode(withName: "//BGMLabel") as? SKLabelNode
        
        if backScene.backScene.gameData.bgmFlag {
            BGMLabel?.text = "On"
        } else {
            BGMLabel?.text = "Off"
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
            case "CloseNode", "CloseLabel":
                goBack()
            case "BGMNode", "BGMLabel":
                bgmChange()
            default:
                break
            }
        }
    }
}
