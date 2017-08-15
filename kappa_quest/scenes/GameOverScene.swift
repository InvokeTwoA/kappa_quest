// ゲームオーバー画面

import SpriteKit
import GameplayKit

class GameOverScene: SKScene {
    
    var backScene : GameScene!
    
    private var hintLabel0 : SKLabelNode?
    private var hintLabel1 : SKLabelNode?
    private var hintLabel2 : SKLabelNode?

    override func sceneDidLoad() {
        hintLabel0     = self.childNode(withName: "//hintLabel0") as? SKLabelNode
        hintLabel1     = self.childNode(withName: "//hintLabel1") as? SKLabelNode
        hintLabel2     = self.childNode(withName: "//hintLabel2") as? SKLabelNode

        let hints = getRandomHint()
        
        hintLabel0?.text = hints[0]
        hintLabel1?.text = hints[1]
        hintLabel2?.text = hints[2]
    }
    
    func getRandomHint() -> [String] {
        var hints = [[String]]()

        hints.append(["冒険日誌1", "敵の攻撃が痛い。",           "体力が足りないのだろうか？"])
        hints.append(["冒険日誌2", "敵の魔法が痛い。",           "精神が足りないのだろうか？"])
        hints.append(["冒険日誌3", "クリティカルヒットが出ない。", "幸運が足りないのだろうか？"])
        hints.append(["冒険日誌4", "レベルが中々上がらない。",    "転職するべきかもしれない……。"])
        hints.append(["冒険日誌5", "KはカッパのK。",            "この言葉が勇気を与えてくれる。"])
        hints.append(["冒険日誌6", "力こそ全て",                "果たして本当にそうなのだろうか？"])
        hints.append(["冒険日誌7", "スキルが足りない。",         "もっと転職するべきか。"])
        let hint = hints[CommonUtil.rnd(hints.count)]
        return hint
    }
    
    func goBack(){
        resetData()
        self.view!.presentScene(backScene, transition: .flipHorizontal(withDuration: 3.5))
    }
    
    
    func resetData(){
        backScene.kappa?.hp = (backScene.kappa?.maxHp)!
        backScene.map.resetData()
        backScene.gameOverFlag = false

        backScene.clearMap()
        backScene.createMap()
        backScene.setFirstPosition()
        backScene.saveData()
        
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
            default:
                break
            }
        }
    }
}
