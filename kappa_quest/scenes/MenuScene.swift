// メニュー画面

import SpriteKit
import GameplayKit

class MenuScene: BaseScene {

    var back = ""
    var backScene : GameScene!

    override func sceneDidLoad() {
    }

    override func didMove(to view: SKView) {
        if back == "world" {
            let optionLabel     = childNode(withName: "//OptionLabel") as! SKLabelNode
            let optionNode     = childNode(withName: "//OptionNode") as! SKSpriteNode
            optionLabel.removeFromParent()
            optionNode.removeFromParent()
        }
    }
    
    func showStatus(){
        let skillModel = SkillModel()
        skillModel.readDataByPlist()
        let kappa = KappaNode()
        kappa.setParameterByUserDefault()
        let gameData = GameData()
        gameData.setParameterByUserDefault()
        displayAlert("ステータス", message: JobModel.allSkillExplain(skillModel, kappa: kappa, gameData: gameData), okString: "閉じる")
    }
    
    func goBack(){
        if back == "world" {
            goWorld()
        } else {
            self.view!.presentScene(backScene!, transition: .fade(withDuration: Const.transitionInterval))
        }
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
            case "SkillNode", "SkillLabel":
                showStatus()
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
