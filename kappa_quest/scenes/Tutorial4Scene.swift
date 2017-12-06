/* チュートリアル2画面 */
import SpriteKit
import GameplayKit

class Tutorial4Scene: BaseScene {
    
    private var kappa : KappaNode!
    private var actionModel : ActionModel = ActionModel()
    
    override func sceneDidLoad() {
        setKappa()
        actionModel.setActionData(sceneWidth: size.width)
        prepareBGM(fileName: Const.bgm_ahurera)
    }
    
    func setKappa(){
        kappa = childNode(withName: "//kappa") as! KappaNode
        kappa.setPhysic()
    }
    
    private var kappa_position = 1
    private var isMoving = false
    func moveRight(){
        if isMoving {
            return
        }
        isMoving = true
        kappa_position += 1
        
        kappa.walkRight()
        kappa.run(actionModel.moveRight!, completion: {() -> Void in
            if self.kappa_position == Const.maxPosition {
                self.goNextMap()
            }
            self.isMoving = false
        })
    }
    
    func moveLeft(){
        if isMoving {
            return
        }
        isMoving = true
        kappa_position -= 1
        
        kappa.walkLeft()
        kappa.run(actionModel.moveLeft!, completion: {() -> Void in
            self.isMoving = false
        })
    }

    /***********************************************************************************/
    /********************************** 画面遷移  ****************************************/
    /***********************************************************************************/
    func goMenu(){
        let nextScene = MenuScene(fileNamed: "MenuScene")!
        nextScene.size = self.scene!.size
        nextScene.scaleMode = SKSceneScaleMode.aspectFit
        nextScene.back = "tutorial"
        self.view!.presentScene(nextScene, transition: .fade(withDuration: Const.transitionInterval))
    }

    // 初めてのゲーム画面へ
    // 初期値登録
    func goNextMap(){
        stopBGM()
        
        KappaNode.setInitLv()
        JobModel.setInitLv()
        gameData.saveParam()
        let kappaNode = KappaNode()
        kappaNode.saveParam()

        GameData.clearCountUp("tutorial0")
        
        let nextScene = GameScene(fileNamed: "GameScene")!
        nextScene.size = self.scene!.size
        nextScene.scaleMode = SKSceneScaleMode.aspectFit
        nextScene.world_name = "tutorial"
        view!.presentScene(nextScene, transition: .doorway(withDuration: Const.doorTransitionInterval))
    }

    /***********************************************************************************/
    /********************************** touch   ****************************************/
    /***********************************************************************************/
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let positionInScene = t.location(in: self)
            let tapNode = self.atPoint(positionInScene)
            if tapNode.name == nil {
                self.touchDown(atPoint: positionInScene)
                return
            }
            
            switch tapNode.name! {
            case "ButtonNode", "ButtonLabel":
                goMenu()
            default:
                self.touchDown(atPoint: positionInScene)
            }
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if pos.x >= 0 {
            moveRight()
        } else {
            if kappa_position != 1 {
                moveLeft()
            } else {
                kappa!.run(actionModel.moveBack!)
            }
        }
    }
}
