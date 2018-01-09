// ワールドマップ画面
import SpriteKit
import GameplayKit

class World2Scene: WorldScene {
    
    private let map_nodes = [
        "skelton",
        "tokage",
        "miira",
        "death",
        "samurai",
        "zombi",
        "hiyoko",
        "red_dragon",
        "dancer",
        "tanuki",
        "dog"
    ]
    private let worldModel : WorldModel = WorldModel()
    
    override func sceneDidLoad() {
        chapter = 2
        worldModel.readDataByPlist()
        gameData.setParameterByUserDefault()
    }
    
    override func didMove(to view: SKView) {
        prepareBGM(fileName: Const.bgm_castle)
        playBGM()
        
        if !GameData.isClear("skelton") {
            removeSpriteNode("tokage")
        }
        if !GameData.isClear("tokage") {
            removeSpriteNode("miira")
        }

        if !GameData.isClear("miira") {
            removeSpriteNode("death")
            removeSpriteNode("samurai")
            removeSpriteNode("zombi")
            removeSpriteNode("hiyoko")
        }

        if !GameData.isClear("death") && !GameData.isClear("samurai") && !GameData.isClear("zombi") && !GameData.isClear("hiyoko") {
            removeSpriteNode("dancer")
        }
        
        if !GameData.isClear("dancer") {
            removeSpriteNode("tanuki")
        }

        // ラストバトル
//        if !GameData.isClear("tanuki") {
            removeSpriteNode("usagi")
//        }

//        setNotificationCount()
    }
    
    /***********************************************************************************/
    /********************************* 画面遷移 *****************************************/
    /***********************************************************************************/    
    override func goDungeon(_ key : String){
        stopBGM()
        goGame2(key)
    }
    // 店へ行く
    override func goShop(){
        let scene = ShopScene(fileNamed: "ShopScene")!
        scene.size = self.scene!.size
        scene.scaleMode = SKSceneScaleMode.aspectFit
        self.view!.presentScene(scene, transition: .doorway(withDuration: Const.doorTransitionInterval))
    }
    
    // 酒場へ行く
    override func goBar(){
        NotificationModel.resetBarCount()
        setNotificationCount()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let listViewController = storyboard.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
        listViewController.type = "bar"
        listViewController.chapter = chapter
        self.view?.window?.rootViewController?.present(listViewController, animated: true, completion: nil)
    }
    
    // メニュー画面へ遷移
    override func goMenu(){
        let nextScene = MenuScene(fileNamed: "MenuScene")!
        nextScene.size = scene!.size
        nextScene.scaleMode = SKSceneScaleMode.aspectFit
        nextScene.back = "world"
        nextScene.chapter = 2
        view!.presentScene(nextScene, transition: .fade(withDuration: Const.transitionInterval))
    }
    
    func goKaizo(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let listViewController = storyboard.instantiateViewController(withIdentifier: "AbilityViewController") as! AbilityViewController
        self.view?.window?.rootViewController?.present(listViewController, animated: true, completion: nil)
    }
    
    override func moveObject(_ vector: CGVector){
        enumerateChildNodes(withName: "*") { node, _ in
            if node.name != nil {
                if node.name! == "WorldNode" || self.map_nodes.contains(node.name!) {
                    node.run(SKAction.move(by: vector, duration: 0.0))
                }
            }
        }
    }
    
    /***********************************************************************************/
    /********************************** touch ******************************************/
    /***********************************************************************************/
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            beganPosition = t.location(in: self)
            let tapNode = atPoint(beganPosition)
            if tapNode.name == nil {
                return
            }
            
            if map_nodes.contains(tapNode.name!) {
                goDungeon(tapNode.name!)
            } else if tapNode.name! == "usagi" {
                goLastBoss2()
            } else if tapNode.name! == "KaizoLabel" || tapNode.name == "KaizoNode" {
                //displayAlert("君はまだ改造すべきではない", message: "お茶でも飲んで落ち着くんだ！", okString: "OK")
                goKaizo()
            } else if tapNode.name! == "ShopLabel" || tapNode.name == "ShopNode" {
                goShop()
            } else if tapNode.name! == "BarLabel" || tapNode.name == "BarNode" {
                goBar()
            } else if tapNode.name! == "MenuLabel" || tapNode.name == "MenuNode" {
                goMenu()
            }
        }
    }
}
