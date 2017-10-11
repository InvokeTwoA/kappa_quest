// ゲームオーバー画面
import SpriteKit
import GameplayKit

class GameOverScene: BaseScene {
    
    var backScene : GameScene!
    
    private var hintLabel0 : SKLabelNode!
    private var hintLabel1 : SKLabelNode!
    private var hintLabel2 : SKLabelNode!

    override func sceneDidLoad() {
        let worldLabel = childNode(withName: "//WorldLabel") as! SKLabelNode
        let worldNode  = childNode(withName: "//WorldNode")  as! SKSpriteNode

        if !GameData.isClear("tutorial") {
            worldLabel.isHidden = true
            worldNode.isHidden = true
        }
    }
    
    override func didMove(to view: SKView) {
        prepareBGM(fileName: Const.bgm_gameover)
        playBGM()
        if backScene.world_name == "dancer" {
            let continueLabel = childNode(withName: "//ContinueLabel") as! SKLabelNode
            let continueNode  = childNode(withName: "//ContinueNode")  as! SKSpriteNode
            continueLabel.removeFromParent()
            continueNode.removeFromParent()
        }
    }
    
    func goBack(){
        stopBGM()
        
        gameData.changeNicknameByDeath()
        resetData()
        self.view!.presentScene(backScene, transition: .flipHorizontal(withDuration: 3.5))
    }
    
    func resetData(){
        backScene.resetData()
        _ = CommonUtil.setTimeout(delay: 3.5, block: { () -> Void in
            self.backScene.playBGM()
        })
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
                goBack()
            case "WorldNode", "WorldLabel":
                gameData.changeNicknameByDeath()
                stopBGM()
                goWorld()
            default:
                break
            }
        }
    }
}
