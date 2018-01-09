// チャプター画面
import SpriteKit
import GameplayKit

class ChapterScene: BaseScene {
    override func sceneDidLoad() {
        prepareBGM(fileName: Const.bgm_ahurera)
    }
    
    override func willMove(from view: SKView) {
    }
    
    // １章へ
    func startGame1(){
        if GameData.isClear("tutorial") {
            stopBGM()
            goWorld()
        } else if GameData.isClear("tutorial0") {
            stopBGM()
            goFirstWorld()
        } else {
            let nextScene = TutorialScene(fileNamed: "TutorialScene")!
            nextScene.size = nextScene.size
            nextScene.scaleMode = SKSceneScaleMode.aspectFit
            view!.presentScene(nextScene, transition: .doorway(withDuration: Const.doorTransitionInterval))
        }
    }
        
    func goFirstWorld(){
        let nextScene = GameScene(fileNamed: "GameScene")!
        nextScene.size = self.scene!.size
        nextScene.scaleMode = SKSceneScaleMode.aspectFit
        nextScene.world_name = "tutorial"
        self.view!.presentScene(nextScene, transition: .fade(withDuration: Const.transitionInterval))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let positionInScene = t.location(in: self)
            let tapNode = self.atPoint(positionInScene)
            if tapNode.name == nil {
                return
            }            
            switch tapNode.name! {
            case "Chapter1Node", "Chapter1Label":
                startGame1()
            case "Chapter2Node", "Chapter2Label":
                if GameData.isClear("opening2") {
                    goWorld2()
                } else {
                    goOpening2()
                }
            case "Chapter3Node", "Chapter3Label":
                displayAlert("まだ3章は公開されてません", message: "お茶でも飲んで落ち着くんだ！", okString: "OK")
            case "odoriko":
                displayAlert("今日もがんばるぞい！", message: "", okString: "OK")
            default:
                break
            }
        }
    }
}
