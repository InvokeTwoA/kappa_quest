// ゲームオーバー画面
import SpriteKit
import GameplayKit

class GameOverScene: BaseScene {
    
    var backScene : GameScene!
    var back2Scene : Game2Scene!

    var chapter = 1
    
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
        if chapter == 1 {
            if backScene.world_name == "dancer" || backScene.world_name == "last" {
                removeSpriteNode("ContinueNode")
                removeLabelNode("ContinueLabel")
            }
            backScene.gameData.death += 1
            backScene.gameData.saveParam()
        } else if chapter == 2 {
            back2Scene.gameData.death += 1
            back2Scene.gameData.saveParam()
        }
    }
    
    func goBack(){
        stopBGM()
        
        gameData.changeNicknameByDeath()
        resetData()
        if chapter == 1 {
            self.view!.presentScene(backScene, transition: .flipHorizontal(withDuration: 3.5))
        } else if chapter == 2 {
            self.view!.presentScene(back2Scene, transition: .flipHorizontal(withDuration: 3.5))
        }
    }
    
    func resetData(){
        if chapter == 1 {
            backScene.resetData()
            _ = CommonUtil.setTimeout(delay: 3.5, block: { () -> Void in
                self.backScene.playBGM()
            })
        } else if chapter == 2 {
            back2Scene.resetData()
            _ = CommonUtil.setTimeout(delay: 3.5, block: { () -> Void in
                self.back2Scene.playBGM()
            })
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
