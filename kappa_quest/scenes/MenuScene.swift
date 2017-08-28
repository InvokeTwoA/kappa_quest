// メニュー画面

import SpriteKit
import GameplayKit

class MenuScene: SKScene {

    var backScene : GameScene!

    override func sceneDidLoad() {
    }

    func goBack(){
        self.view!.presentScene(backScene, transition: .fade(withDuration: Const.transitionInterval))
    }
    
    func goOption(){
        let scene = OptionScene(fileNamed: "OptionScene")
        scene?.size = self.scene!.size
        scene?.scaleMode = SKSceneScaleMode.aspectFill
        scene?.backScene = self.scene as! MenuScene        
        self.view!.presentScene(scene!, transition: .flipVertical(withDuration: Const.transitionInterval))
    }
    
    func goTitle(){
        let scene = TitleScene(fileNamed: "TitleScene")
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
            case "CloseNode", "CloseLabel":
                goBack()
            case "OptionNode", "OptionLabel":
                goOption()
            case "ResetNode", "ResetLabel":
                goTitle()
            default:
                break
            }
        }
    }
}
