// ワールドマップ画面
import SpriteKit
import GameplayKit

class WorldScene: BaseScene {

    private let map_nodes = [
        "wizard",
        "knight",
        "priest",
        "thief",
        "archer",
        "dancer",
        "ninja",
        "fighter",
        "necro",
        "gundom",
        "angel",
        "king",
        "maou",
        "miyuki",
        "master",
        "dark_kappa"
    ]
    
    private let menu_node = [
        "WorldNode",
        "ShopNode",
        "BarNode",
        "MenuNode",
        "MenuBox",
    ]
    
    private let worldModel : WorldModel = WorldModel()

    override func sceneDidLoad() {
        worldModel.readDataByPlist()
        gameData.setParameterByUserDefault()
    }
    
    override func didMove(to view: SKView) {
        prepareBGM(fileName: Const.bgm_castle)
        playBGM()

        setNotificationCount()
        
        if !GameData.isClear("wizard") {
            let node = childNode(withName: "//knight")
            node?.removeFromParent()
        }
        if !GameData.isClear("knight") {
            let node1 = childNode(withName: "//thief")
            let node2 = childNode(withName: "//priest")
            let node3 = childNode(withName: "//archer")
            node1?.removeFromParent()
            node2?.removeFromParent()
            node3?.removeFromParent()
        }
        
        if CommonUtil.rnd(6) != 0 {
            let node4 = childNode(withName: "//dancer")
            node4?.removeFromParent()
        }
        
        if !GameData.isClear("priest") {
            hideNode("angel")
        }
        if !GameData.isClear("thief") {
            hideNode("gundom")
        }
        if !GameData.isClear("archer") {
            hideNode("necro")
        }
        
        // 上位を一つでもクリアしていたら行ける
        if !GameData.isClear("necro") && !GameData.isClear("angel") && !GameData.isClear("gundom"){
            let node = childNode(withName: "//fighter")
            node?.removeFromParent()
        }
        if !GameData.isClear("fighter") {
            let node = childNode(withName: "//king")
            node?.removeFromParent()
        }
        if !GameData.isClear("king") {
            let node = childNode(withName: "//maou")
            node?.removeFromParent()
        }
        if !GameData.isClear("maou") {
            let node = childNode(withName: "//miyuki")
            node?.removeFromParent()
        }
        
        if !GameData.isClear("question2") {
            let node = childNode(withName: "//master")
            node?.removeFromParent()
        }
        if !GameData.isClear("master") {
            hideNode("dark_kappa")
        }
        
        if GameData.isClear("dark_kappa") {
            hideNode("dark_kappa")
        } else {
            hideNode("last")
        }
        
        // 裏面
        if !GameData.isClear("last") {
            hideNode("kappa")
        }
        
    }
    
    func hideNode(_ name : String){
        let node = childNode(withName: "//\(name)")
        node?.removeFromParent()
    }
    
    
    func setNotificationCount(){
        let bar_notification_label = childNode(withName: "//BarNotificationLabel") as? SKLabelNode
        let bar_notification_node  = childNode(withName: "//BarNotificationNode") as? SKSpriteNode
        if NotificationModel.getBarCount() == 0 {
            bar_notification_label?.removeFromParent()
            bar_notification_node?.removeFromParent()
        } else {
            bar_notification_label?.text = "\(NotificationModel.getBarCount())"
        }

        let shop_notification_label = childNode(withName: "//ShopNotificationLabel") as? SKLabelNode
        let shop_notification_node  = childNode(withName: "//ShopNotificationNode") as? SKSpriteNode
        if NotificationModel.getShopCount() == 0 {
            shop_notification_label?.removeFromParent()
            shop_notification_node?.removeFromParent()
        } else {
            shop_notification_label?.text = "\(NotificationModel.getShopCount())"
        }

    }
    
    func goDungeon(_ key : String){
        stopBGM()
        
        let map = Map()
        map.initData()
        
        let scene = GameScene(fileNamed: "GameScene")!
        scene.size = self.scene!.size
        scene.scaleMode = SKSceneScaleMode.aspectFit
        scene.world_name = key
        self.view!.presentScene(scene, transition: .doorway(withDuration: Const.doorTransitionInterval))
    }

    // 店へ行く
    func goShop(){
        let scene = ShopScene(fileNamed: "ShopScene")!
        scene.size = self.scene!.size
        scene.scaleMode = SKSceneScaleMode.aspectFit
        self.view!.presentScene(scene, transition: .doorway(withDuration: Const.doorTransitionInterval))
    }
    
    // 酒場へ行く
    func goBar(){
        NotificationModel.resetBarCount()
        setNotificationCount()        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let listViewController = storyboard.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
        listViewController.type = "bar"
        self.view?.window?.rootViewController?.present(listViewController, animated: true, completion: nil)
    }


    // メニュー画面へ遷移
    func goMenu(){
        let nextScene = MenuScene(fileNamed: "MenuScene")!
        nextScene.size = scene!.size
        nextScene.scaleMode = SKSceneScaleMode.aspectFit
        nextScene.back = "world"
        view!.presentScene(nextScene, transition: .fade(withDuration: Const.transitionInterval))
    }
    
    func goLast(){
        let nextScene = LastBattleScene(fileNamed: "LastBattleScene")!
        nextScene.size = scene!.size
        nextScene.scaleMode = SKSceneScaleMode.aspectFit
        nextScene.world_name = "last"
        view!.presentScene(nextScene, transition: .fade(withDuration: Const.transitionInterval))
    }

    func moveObject(_ vector: CGVector){
        enumerateChildNodes(withName: "*") { node, _ in
            if node.name != nil {
                if node.name! == "WorldNode" || self.map_nodes.contains(node.name!) {
                    node.run(SKAction.move(by: vector, duration: 0.0))
                }
            }
        }
    }

    var beganPosition : CGPoint!
    var tap_count = 0
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            beganPosition = t.location(in: self)
            let tapNode = atPoint(beganPosition)
            if tapNode.name == nil {
                return
            }
            
            if GameData.isClear("dark_kappa") {
                if map_nodes.contains(tapNode.name!) || menu_node.contains(tapNode.name!){
                    tap_count += 1
                    deleteSPriteNode(tapNode.name!)
                }
                
                if tap_count > 5 {
                    let label = childNode(withName: "//ExplainLabel") as! SKLabelNode
                    label.text = "最後の決着をつけよう……"
                    label.fontColor = .white
                    if tapNode.name == "last" {
                        goLast()
                    }
                }
                return
            }
            
            if map_nodes.contains(tapNode.name!) {
                goDungeon(tapNode.name!)
            } else if tapNode.name == "kappa" {
                goDungeon(tapNode.name!)
            } else if tapNode.name! == "ShopLabel" || tapNode.name == "ShopNode" {
                if GameData.isClear("wizard") {
                    goShop()
                } else {
                    displayAlert("君にはまだ転職は早い", message: "「魔法使い」のステージクリアで解禁される", okString: "OK")
                }
            } else if tapNode.name! == "BarLabel" || tapNode.name == "BarNode" {
                goBar()
            } else if tapNode.name! == "MenuLabel" || tapNode.name == "MenuNode" {
                goMenu()
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let endPosition =  t.location(in: self)
            let vector = CGVector(
                dx: endPosition.x - beganPosition.x,
                dy: 0
            )
            moveObject(vector)
            beganPosition = endPosition
        }
    }
}
