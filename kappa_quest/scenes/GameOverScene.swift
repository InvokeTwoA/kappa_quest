// ゲームオーバー画面
import SpriteKit
import GameplayKit
class GameOverScene: BaseScene {
    
    var world_name = ""
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
    }

    // コンティニュー
    func goBack(){
        stopBGM()
        gameData.changeNicknameByDeath()
        if chapter == 1 {
            if world_name == "last" {
                goLast()
            } else {
                goGame(world_name)
            }
        } else if chapter == 2 {
            if world_name == "usagi" {
                goLastBoss2()
            } else {
                goGame2(world_name)
            }
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
