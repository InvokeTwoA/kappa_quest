// ゲームクリア画面
import SpriteKit
import GameplayKit

class GameClearScene: BaseScene {
    
    var world = ""
    var clearWord = ""
    var maxDamage = 0
    var totalDamage = 0
    
    override func sceneDidLoad() {
    }
    
    override func didMove(to view: SKView) {
        let clearLabel      = childNode(withName: "//clearWord")  as! SKLabelNode
        let clear2Label      = childNode(withName: "//clearWord2")  as! SKLabelNode
        
        clearLabel.text = randomWord()
        clear2Label.text = clearWord

        switch world {
        case "tutorial", "tutorial2", "thief", "priest":
            GameData.clearCountUp(world)
            break
        default:
            break
        }
    }
    
    func randomWord() -> String {
        let array = [
            "もうここに用はない！",
            "悪は滅びる運命！",
            "勝った、勝った、夕飯はドン勝だ！",
            "カッパこそが最強！",
            "余裕のよっちゃん！",
            "そして、次の戦いが始まるのです",
            "敗北が知りたい",
        ]
        return array[CommonUtil.rnd(array.count)]
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
