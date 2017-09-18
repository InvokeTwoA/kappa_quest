// ワールドマップ画面
import SpriteKit
import GameplayKit

class WorldScene: BaseScene {

    let map_nodes = [
        "tutorial",
        "tutorial2",
        "thief",
        "archer",
        "priest",
        "necro",
        "maou"
    ]
    
    private let worldModel : WorldModel = WorldModel()

    override func sceneDidLoad() {
        worldModel.readDataByPlist()
        gameData.setParameterByUserDefault()
    }
    
    override func didMove(to view: SKView) {
        if !GameData.isClear("tutorial") {
            let node = childNode(withName: "//tutorial2")
            node?.removeFromParent()
        }
        if !GameData.isClear("tutorial2") {
            let node1 = childNode(withName: "//thief")
            let node2 = childNode(withName: "//priest")
            let node3 = childNode(withName: "//archer")
            node1?.removeFromParent()
            node2?.removeFromParent()
            node3?.removeFromParent()
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
        let alert = UIAlertController(
            title: worldModel.getName(key),
            message: worldModel.getExplain(key),
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "準備はできている！", style: .default, handler: { action in
            self.goDungeon(key)
        }))
        alert.addAction(UIAlertAction(title: "……今は引き返す", style: .cancel))
        self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
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
        scene.backScene = self.scene as! WorldScene
        scene.size = self.scene!.size
        scene.scaleMode = SKSceneScaleMode.aspectFill
        self.view!.presentScene(scene, transition: .doorway(withDuration: Const.doorTransitionInterval))
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
                dy: endPosition.y - beganPosition.y
            )
            moveObject(vector)
            beganPosition = endPosition
        }
    }
}
