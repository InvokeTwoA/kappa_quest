// 手紙（オープニング）画面
import SpriteKit
import GameplayKit

class CutinScene: BaseScene {
    
    var backScene : GameScene!
    private var cutinModel = CutinModel()
    private var page = 0
    var key = ""
    
    override func didMove(to view: SKView) {
        cutinModel.readDataByPlist(key)
        cutinModel.setDataByPage(page)
        
        updateScreen()
    }
    
    func updateScreen(){
        let enemyImage  = childNode(withName: "//enemyImage") as! SKSpriteNode
        let kappa       = childNode(withName: "//kappa") as! SKSpriteNode
        let text1Label  = childNode(withName: "//text1") as! SKLabelNode
        let text2Label  = childNode(withName: "//text2") as! SKLabelNode
        let nameLabel   = childNode(withName: "//name") as! SKLabelNode
        
        cutinModel.setDataByPage(page)
        if cutinModel.image == "kappa" {
            enemyImage.isHidden = true
            kappa.isHidden = false
            nameLabel.text = cutinModel.name
        } else {
            enemyImage.isHidden = false
            enemyImage.texture = SKTexture(imageNamed: cutinModel.image)
            kappa.isHidden = true
            nameLabel.text = cutinModel.name
        }
        text1Label.text = cutinModel.text1
        text2Label.text = cutinModel.text2
    }
    
    func goBack(){
        view!.presentScene(backScene, transition: .fade(with: .red, duration: Const.gameOverInterval))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        page += 1
        if cutinModel.max_page <= page {
            goBack()
        } else {
            updateScreen()
        }
    }
}
