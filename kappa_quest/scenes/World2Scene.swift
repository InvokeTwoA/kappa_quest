// ワールドマップ画面
import SpriteKit
import GameplayKit

class World2Scene: BaseScene {
    
    private let map_nodes = [
        "skelton",
        "miira"
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
        
//        setNotificationCount()
        

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
        
        let scene = Game2Scene(fileNamed: "Game2Scene.sks")!
        
        
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
        nextScene.back = "world2"
        nextScene.chapter = 2
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
            
            if map_nodes.contains(tapNode.name!) {
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
            beganPosition = endPosition
        }
    }
}

