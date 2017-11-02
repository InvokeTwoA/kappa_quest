/* チュートリアル画面 */
import SpriteKit
import GameplayKit

class TutorialScene: BaseScene {

    private var kappa : KappaNode!
    private var actionModel : ActionModel = ActionModel()
    
    override func sceneDidLoad() {
        setKappa()
        actionModel.setActionData(sceneWidth: size.width)
    }
    
    override func didMove(to view: SKView) {
//        prepareBGM(fileName: Const.bgm_castle)
//        playBGM()
    }

    func setKappa(){
        kappa = childNode(withName: "//kappa") as! KappaNode
        kappa.setPhysic()
    }
    
    func goNextMap(){
        let nextScene = Tutorial2Scene(fileNamed: "Tutorial2Scene")!
        nextScene.size = nextScene.size
        nextScene.scaleMode = SKSceneScaleMode.aspectFit
        view?.presentScene(nextScene, transition: .crossFade(withDuration: 0.1))
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let positionInScene = t.location(in: self)
            touchDown(atPoint: positionInScene)
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
