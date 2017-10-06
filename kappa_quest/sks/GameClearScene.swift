// ゲームクリア画面
import SpriteKit
import GameplayKit

class GameClearScene: BaseScene {

    var world = ""
    var maxDamage = 0
    var totalDamage = 0

    override func sceneDidLoad() {
    }

    override func didMove(to view: SKView) {
        let clearLabel     = childNode(withName: "//clearWord")  as! SKLabelNode
        let getLabel1      = childNode(withName: "//clearText1")  as! SKLabelNode
        let getLabel2      = childNode(withName: "//clearText2")  as! SKLabelNode
        let getLabel3      = childNode(withName: "//clearText3")  as! SKLabelNode

        
        switch world {
        case "tutorial":
            clearLabel.text = "これから伝説が始まる！"
            getLabel1.text = "「酒場」がオープンしました"
            getLabel2.text = "「魔法使い」のステージが出現しました"
        case "wizard":
            clearLabel.text = "そして、次の戦いが始まるのです"
            getLabel1.text = "「魔法使い」のジョブを取得しました"
            getLabel2.text = "「魔法使い」が酒場に来ました"
            getLabel3.text = "「騎士」のステージが出現しました"
        default:
            clearLabel.text = "未設定"
            getLabel1.text = "未設定"
            getLabel2.text = "未設定"
        }
        
        // クリアフラグを立てる
        GameData.clearCountUp(world)
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
