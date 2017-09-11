// ワールドマップ画面
import SpriteKit
import GameplayKit

class WorldScene: BaseScene {

    let map_nodes = [
        "thief",
        "tutorial",
        "archer",
        "priest",
        "necro",
        "maou"
    ]

    override func sceneDidLoad() {
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
                goDungeon(tapNode.name!)
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
