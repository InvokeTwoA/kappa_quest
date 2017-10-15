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
            let worldLabel    = childNode(withName: "//WorldLabel") as! SKLabelNode
            let worldNode     = childNode(withName: "//WorldNode") as! SKSpriteNode
            worldLabel.removeFromParent()
            worldNode.removeFromParent()
        }
        
        if !GameData.isClear("tutorial0") {
            let optionLabel   = childNode(withName: "//OptionLabel") as! SKLabelNode
            let optionNode    = childNode(withName: "//OptionNode") as! SKSpriteNode
            optionLabel.removeFromParent()
            optionNode.removeFromParent()
            
            let worldLabel    = childNode(withName: "//WorldLabel") as! SKLabelNode
            let worldNode     = childNode(withName: "//WorldNode") as! SKSpriteNode
            worldLabel.removeFromParent()
            worldNode.removeFromParent()
            
            let resetLabel    = childNode(withName: "//ResetLabel") as! SKLabelNode
            let resetNode     = childNode(withName: "//ResetNode") as! SKSpriteNode
            resetLabel.removeFromParent()
            resetNode.removeFromParent()
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
    
    func goBack(){
        if back == "world" {
            goWorld()
        } else if back == "tutorial" {
            let nextScene = Tutorial4Scene(fileNamed: "Tutorial4Scene")!
            nextScene.size = nextScene.size
            nextScene.scaleMode = SKSceneScaleMode.aspectFill
            view!.presentScene(nextScene, transition: .fade(withDuration: Const.transitionInterval))
        } else {
            view!.presentScene(backScene!, transition: .fade(withDuration: Const.transitionInterval))
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
        nextScene.scaleMode = SKSceneScaleMode.aspectFill
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
            default:
                break
            }
        }
    }
}
