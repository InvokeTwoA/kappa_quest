// タイトル画面
import SpriteKit
import GameplayKit

class TitleScene: BaseScene {
    override func sceneDidLoad() {
        setRandomImage()
        if !GameData.isExistData() {
            let resetNode = childNode(withName: "//ResetNode") as? SKSpriteNode
            let resetLabel = childNode(withName: "//ResetLabel") as? SKLabelNode
            resetNode?.removeFromParent()
            resetLabel?.removeFromParent()
        }
        prepareBGM(fileName: Const.bgm_ahurera)
        playBGM()
    }

    override func willMove(from view: SKView) {
        stopBGM()
    }

    // ランダムなキャラアイコンをTOPに表示
    func setRandomImage(){
        let images = [
            "kappa",
            "hiyoko",
            "usagi",
            "megane",
            "master",
            "buffalo",
            "chibidora",
            "ghost",
            "wizard",
            "arakure",
            "thief",
            "knight",
            "ninja",
            "dancer",
            "fighter",
            "death",
            "cross",
            "miira",
            "skelton",
            "zombi",
            "angel",
            "miyuki",
            "maou",
        ]
        
        let imageNode0 = childNode(withName: "//image0") as? SKSpriteNode
        let imageNode1 = childNode(withName: "//image1") as? SKSpriteNode
        let imageNode2 = childNode(withName: "//image2") as? SKSpriteNode
        let imageNode3 = childNode(withName: "//image3") as? SKSpriteNode
        let imageNode4 = childNode(withName: "//image4") as? SKSpriteNode

        imageNode0?.texture = SKTexture(imageNamed: images[CommonUtil.rnd(images.count)])
        imageNode1?.texture = SKTexture(imageNamed: images[CommonUtil.rnd(images.count)])
        imageNode2?.texture = SKTexture(imageNamed: images[CommonUtil.rnd(images.count)])
        imageNode3?.texture = SKTexture(imageNamed: images[CommonUtil.rnd(images.count)])
        imageNode4?.texture = SKTexture(imageNamed: images[CommonUtil.rnd(images.count)])
    }
    
    func goGame(){
        /*
        let resetNode = childNode(withName: "//ResetNode") as! SKSpriteNode
        resetNode.physicsBody = SKPhysicsBody(rectangleOf: resetNode.size)
        WorldNode.setWorldEnd(resetNode.physicsBody!)
 */        
        if GameData.isClear("tutorial") {
            goWorld()
        } else {
            KappaNode.setInitLv()
            JobModel.setInitLv()
            gameData.saveParam()
            let kappaNode = KappaNode()
            kappaNode.saveParam()
            
            let scene = GameScene(fileNamed: "GameScene")!
            scene.size = self.scene!.size
            scene.scaleMode = SKSceneScaleMode.aspectFill
            scene.world_name = "tutorial"
            self.view!.presentScene(scene, transition: .fade(withDuration: Const.transitionInterval))
            /*
            let scene = LetterScene(fileNamed: "LetterScene")
            scene?.size = self.scene!.size
            scene?.scaleMode = SKSceneScaleMode.aspectFill
            self.view!.presentScene(scene!, transition: .doorway(withDuration: Const.doorTransitionInterval))
 */
        }
    }
    
    func resetAlert(){
        let alert = UIAlertController(
            title: "データをリセットします。",
            message: "冒険の記録は永遠に消えますが、よろしいですか？",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.resetData()
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func resetData(){
        let appDomain:String = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)

        let scene = TitleScene(fileNamed: "TitleScene")
        scene?.size = self.scene!.size
        scene?.scaleMode = SKSceneScaleMode.aspectFill
        self.view!.presentScene(scene!, transition: .fade(with: .white, duration: Const.gameOverInterval))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let positionInScene = t.location(in: self)
            let tapNode = self.atPoint(positionInScene)
            if tapNode.name == nil {
                setRandomImage()
                return
            }
            
            switch tapNode.name! {
            case "StartNode", "StartLabel":
                goGame()
            case "ResetNode", "ResetLabel":
                resetAlert()
            default:
                break
            }
        }
    }
}
