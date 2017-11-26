// タイトル画面
import SpriteKit
import GameplayKit
import Social

class TitleScene: BaseScene {
    override func sceneDidLoad() {
        setRandomImage()
        prepareBGM(fileName: Const.bgm_ahurera)
        playBGM()
    }

    override func willMove(from view: SKView) {
    }

    // ランダムなキャラアイコンをTOPに表示
    func setRandomImage(){
        let images = [
            "kappa",
            "hiyoko",
            "usagi",
            "megane",
            "master",
            "chibidora",
            "ghost",
            "wizard",
            "knight",
            "priest",
            "buffalo",
            "arakure",
            "thief",
            "archer",
            "ninja",
            "dancer",
            "zombi",
            "miira",
            "skelton",
            "necro",
            "samurai",
            "fighter",
            "death",
            "cross",
            "angel",
            "king",
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
        let nextScene = ChapterScene(fileNamed: "ChapterScene")!
        nextScene.size = nextScene.size
        nextScene.scaleMode = SKSceneScaleMode.aspectFit
        view!.presentScene(nextScene, transition: .doorway(withDuration: Const.doorTransitionInterval))
    }
    
    func goFirstWorld(){
        let nextScene = GameScene(fileNamed: "GameScene")!
        nextScene.size = self.scene!.size
        nextScene.scaleMode = SKSceneScaleMode.aspectFit
        nextScene.world_name = "tutorial"
        self.view!.presentScene(nextScene, transition: .fade(withDuration: Const.transitionInterval))
    }
    
    func goMusic(){
        stopBGM()
        let nextScene = MusicScene(fileNamed: "MusicScene")!
        nextScene.size = self.scene!.size
        nextScene.scaleMode = SKSceneScaleMode.aspectFit
        self.view!.presentScene(nextScene, transition: .fade(withDuration: Const.transitionInterval))
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
        stopBGM()

        let appDomain:String = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)

        let nextScene = TitleScene(fileNamed: "TitleScene")!
        nextScene.size = self.scene!.size
        nextScene.scaleMode = SKSceneScaleMode.aspectFit
        self.view!.presentScene(nextScene, transition: .fade(with: .white, duration: Const.gameOverInterval))
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
            case "UpdateNode", "UpdateLabel":
                goUpdate()
            case "CrossMusic":
                goMusic()
            default:
                break
            }
        }
    }
}
