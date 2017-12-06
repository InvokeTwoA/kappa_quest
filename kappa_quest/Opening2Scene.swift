/* ２章オープニング */
import SpriteKit
import GameplayKit

class Opening2Scene: BaseScene {
    private let actionModel = ActionModel()
    
    private let nodes = [
        "text1", "text2", "text3", "text4", "text5", "text6", "text7", "text8", "text9", "text10", "text11", "text12", "text13", "text14",
        "kappa2",
        "king", "fighter", "knight",
    ]
    internal var kappa : KappaNode!   // かっぱ画像
    
    override func sceneDidLoad() {
    }
    
    override func didMove(to view: SKView) {
        actionModel.setActionData(sceneWidth: size.width)
        kappa = childNode(withName: "//kappa") as! KappaNode
        if !openingFlag {
            openingStart()
        }
    }
    
    private var openingFlag = false
    func openingStart(){
        prepareBGM(fileName: Const.bgm_opening)
        playBGM()
        openingFlag = true
        
        textUpper()
        _ = CommonUtil.setTimeout(delay: 27.0, block: { () -> Void in
            self.openingEnd()
        })
    }
    
    func textUpper(){
        for key in nodes {
            let node = childNode(withName: "//\(key)")
            node?.run(actionModel.openingUpper)
        }
        kappa.run(actionModel.openingUpper)
    }
    
    func openingEnd(){
        GameData.clearCountUp("opening2")
        _ = CommonUtil.setTimeout(delay: 7.0, block: { () -> Void in
            self.stopBGM()
            self.goWorld2()
        })
    }
    
    override func update(_ currentTime: TimeInterval) {
        if CommonUtil.rnd(3) == 0 {
            kappa.punchRush()
        }
    }
    
    
}
