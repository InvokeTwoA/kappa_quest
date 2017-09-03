/* オプション画面 */
import SpriteKit
import GameplayKit

class OptionScene: BaseScene {
    
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
    
    func soundEffectChange(){
        backScene.backScene.gameData.soundEffectChange()
        updateText()
    }
    
    func updateText(){
        let BGMLabel     = childNode(withName: "//BGMLabel") as? SKLabelNode
        let BGMNode      = childNode(withName: "//BGMNode") as? SKSpriteNode
        if backScene.backScene.gameData.bgmFlag {
            BGMLabel?.text = "On"
            BGMNode?.texture = SKTexture(imageNamed: "button_blue")
        } else {
            BGMLabel?.text = "Off"
            BGMNode?.texture = SKTexture(imageNamed: "button_red")
        }
        
        let soundEffectLabel     = childNode(withName: "//SoundEffectLabel") as? SKLabelNode
        let soundEffectNode      = childNode(withName: "//SoundEffectNode") as? SKSpriteNode
        if backScene.backScene.gameData.soundEffectFlag {
            soundEffectLabel?.text = "On"
            soundEffectNode?.texture = SKTexture(imageNamed: "button_blue")
        } else {
            soundEffectLabel?.text = "Off"
            soundEffectNode?.texture = SKTexture(imageNamed: "button_red")
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
            case "SoundEffectNode", "SoundEffectLabel":
                soundEffectChange()
            default:
                break
            }
        }
    }
}
