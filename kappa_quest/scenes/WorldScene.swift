// ワールドマップ画面
import SpriteKit
import GameplayKit

class WorldScene: BaseScene, DungeonDelegate {

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
        "maou"
    ]
    private let worldModel : WorldModel = WorldModel()

    // delegate method
    func didEnteredDungeon(key : String) {
        goDungeon(key)
    }
    
    override func sceneDidLoad() {
        worldModel.readDataByPlist()
        gameData.setParameterByUserDefault()
    }
    
    override func didMove(to view: SKView) {
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
            
            if CommonUtil.rnd(6) != 0 {
                let node4 = childNode(withName: "//dancer")
                node4?.removeFromParent()
            }
        }
        if !GameData.isClear("priest") {
            let node = childNode(withName: "//fighter")
            node?.removeFromParent()
        }
        if !GameData.isClear("priest") && !GameData.isClear("thief") && !GameData.isClear("archer") {
            let node = childNode(withName: "//necro")
            node?.removeFromParent()
        }
        if !GameData.isClear("necro") {
            let node = childNode(withName: "//maou")
            node?.removeFromParent()
        }
    }
    
    func explainDungeon(_ key: String){
        let storyboard = UIStoryboard(name: "Dungeon", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "DungeonViewController") as! DungeonViewController
        nextViewController.world = key
        nextViewController.delegate = self
        self.view?.window?.rootViewController?.present(nextViewController, animated: true, completion: nil)
    }
    
    
    func goDungeon(_ key : String){
        let map = Map()
        map.initData()
        
        let scene = GameScene(fileNamed: "GameScene")!
        scene.size = self.scene!.size
        scene.scaleMode = SKSceneScaleMode.aspectFill
        scene.world_name = key
        self.view!.presentScene(scene, transition: .doorway(withDuration: Const.doorTransitionInterval))
    }

    // 店へ行く
    func goShop(){
        let scene = ShopScene(fileNamed: "ShopScene")!
        scene.size = self.scene!.size
        scene.scaleMode = SKSceneScaleMode.aspectFill
        self.view!.presentScene(scene, transition: .doorway(withDuration: Const.doorTransitionInterval))
    }
    
    // 酒場へ行く
    func goBar(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let listViewController = storyboard.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
        listViewController.type = "bar"
        self.view?.window?.rootViewController?.present(listViewController, animated: true, completion: nil)
    }


    // メニュー画面へ遷移
    func goMenu(){
        let scene = MenuScene(fileNamed: "MenuScene")!
        scene.size = self.scene!.size
        scene.scaleMode = SKSceneScaleMode.aspectFill
        scene.back = "world"
        self.view!.presentScene(scene, transition: .fade(withDuration: Const.transitionInterval))
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            beganPosition = t.location(in: self)
            let tapNode = atPoint(beganPosition)
            if tapNode.name == nil {
                return
            }
            if map_nodes.contains(tapNode.name!) {
                explainDungeon(tapNode.name!)
            } else if tapNode.name! == "ShopLabel" || tapNode.name == "ShopNode" {
                goShop()
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
