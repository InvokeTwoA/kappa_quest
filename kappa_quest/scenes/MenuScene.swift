// 音楽画面
import SpriteKit
import GameplayKit

class MenuScene: BaseScene {

    var back = ""
    var backScene : GameScene!
    var back2Scene: Game2Scene!
    var chapter = 1
    
    override func sceneDidLoad() {
    }
    
    override func didMove(to view: SKView) {
        
        if !GameData.isClear("question") {
            removeSpriteNode("NazoNode")
            removeLabelNode("NazoLabel")
        }
        
        if back == "world" {
            removeSpriteNode("WorldNode")
            removeLabelNode("WorldLabel")

            removeSpriteNode("OptionNode")
            removeLabelNode("OptionLabel")
        } else if back == "game" {
            removeSpriteNode("NameNode")
            removeLabelNode("NameLabel")
        }
        
        if !GameData.isClear("tutorial0") {
            removeSpriteNode("OptionNode")
            removeLabelNode("OptionLabel")

            removeSpriteNode("WorldNode")
            removeLabelNode("WorldLabel") 
        }
    }
    
    func changeName(){
        let alert = UIAlertController(title: "カッパの名は？(4文字以内)", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "入力完了", style: .default, handler: {
            (action:UIAlertAction!) -> Void in
            if let textFields = alert.textFields {
                if textFields.first?.text != "" {
                    let str = textFields.first!.text!
                    let name = CommonUtil.cutString(str: str, maxLength: 4)
                    GameData.setName(value: name)
                    if name == "お兄様" {
                        self.displayAlert("さすがお兄様！", message: "お兄様は不可能を可能にされました", okString: "こらこら、よさないか")
                    } else if name == "お爺様" {
                        self.displayAlert("あらお爺様", message: "あまり無理をしないでね", okString: "OK")
                    }
                }
            }
        })
        alert.addAction(okAction)
        alert.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
            textField.text = GameData.getName()
        })
        alert.view.setNeedsLayout()
        self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    /***********************************************************************************/
    /********************************** 遷移   ******************************************/
    /***********************************************************************************/
    func goBack(){
        if back == "world" {
            if chapter == 1 {
                goWorld()
            } else {
                goWorld2()
            }
        } else if back == "tutorial" {
            let nextScene = Tutorial4Scene(fileNamed: "Tutorial4Scene")!
            nextScene.size = nextScene.size
            nextScene.scaleMode = SKSceneScaleMode.aspectFit
            view!.presentScene(nextScene, transition: .fade(withDuration: Const.transitionInterval))
        } else {
            if chapter == 1 {
                view!.presentScene(backScene!, transition: .fade(withDuration: Const.transitionInterval))
            } else {
                view!.presentScene(back2Scene!, transition: .fade(withDuration: Const.transitionInterval))
            }
        }
    }
    
    func goJob(){
        let storyboard = UIStoryboard(name: "Job", bundle: nil)
        let jobViewController = storyboard.instantiateViewController(withIdentifier: "JobViewController") as! JobViewController
        view?.window?.rootViewController?.present(jobViewController, animated: true, completion: nil)
    }
    
    func goOption(){
        let nextScene = OptionScene(fileNamed: "OptionScene")!
        nextScene.size = scene!.size
        nextScene.scaleMode = SKSceneScaleMode.aspectFit
        nextScene.backScene = scene as! MenuScene
        view!.presentScene(nextScene, transition: .flipVertical(withDuration: Const.transitionInterval))
    }
    
    func goLibrary(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let listViewController = storyboard.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
        listViewController.type = "enemies"
        view?.window?.rootViewController?.present(listViewController, animated: true, completion: nil)
    }
    
    func goStatus(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let listViewController = storyboard.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
        listViewController.type = "status"
        view?.window?.rootViewController?.present(listViewController, animated: true, completion: nil)
    }
    
    /***********************************************************************************/
    /********************************** touch ******************************************/
    /***********************************************************************************/
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let positionInScene = t.location(in: self)
            let tapNode = self.atPoint(positionInScene)
            if tapNode.name == nil {
                return
            }
            switch tapNode.name! {
            case "SkillNode", "SkillLabel":
                goStatus()
            case "LibraryNode", "LibraryLabel":
                goLibrary()
            case "CloseNode", "CloseLabel":
                goBack()
            case "OptionNode", "OptionLabel":
                goOption()
            case "ResetNode", "ResetLabel":
                goTitle()
            case "WorldNode", "WorldLabel":
                goWorld()
            case "NameNode", "NameLabel":
                changeName()
            case "UpdateNode", "UpdateLabel":
                goUpdate()
            case "LegendNode", "LegendLabel":
                displayAlert("この機能はまだ公開されていない", message: "作者の頑張りを待つんだ！", okString: "OK")
            case "NazoNode", "NazoLabel":
                displayAlert("ポチッとな", message: "何か変化が起こった気がする", okString: "OK")
                GameData.clearCountUp("question2")
            default:
                break
            }
        }
    }
}
