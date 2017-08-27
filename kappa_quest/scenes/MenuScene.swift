// メニュー画面

import SpriteKit
import GameplayKit

class MenuScene: SKScene {

    var backScene : GameScene!

    override func sceneDidLoad() {
    }

    func goBack(){
        self.view!.presentScene(backScene, transition: .fade(withDuration: Const.transitionInterval))
    }
    
    func goOption(){
        let scene = OptionScene(fileNamed: "OptionScene")
        scene?.size = self.scene!.size
        scene?.scaleMode = SKSceneScaleMode.aspectFill
        scene?.backScene = self.scene as! MenuScene        
        self.view!.presentScene(scene!, transition: .flipVertical(withDuration: Const.transitionInterval))
    }
    
    func resetAlert(){
        let alert = UIAlertController(
            title: "データをリセットします。",
            message: "冒険の記録は永遠に消えますが、よろしいですか？",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.resetData()
            self.goTitle()
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func resetData(){
        let appDomain:String = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
    }
    
    func goTitle(){
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let positionInScene = t.location(in: self)
            let tapNode = self.atPoint(positionInScene)
            if tapNode.name == nil {
                return
            }
            
            switch tapNode.name! {
            case "CloseNode", "CloseLabel":
                goBack()
            case "OptionNode", "OptionLabel":
                goOption()
            case "ResetNode", "ResetLabel":
                resetAlert()
//                goTitle()
            default:
                break
            }
        }
    }
}
