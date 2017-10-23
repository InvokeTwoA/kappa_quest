// 手紙（オープニング）画面
import SpriteKit
import GameplayKit
import AVFoundation

class CutinScene: BaseScene {
    
    var backScene : GameScene!
    private var cutinModel = CutinModel()
    private var page = 0
    var key = ""
    var world = ""
    var bgm:AVAudioPlayer!
    
    override func didMove(to view: SKView) {
        let read_key = "\(world)_\(key)"
        cutinModel.readDataByPlist(read_key)
        cutinModel.setDataByPage(page)
        
        gameData.setParameterByUserDefault()
        jobModel.readDataByPlist()
        jobModel.loadParam()
        
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
            nameLabel.text = cutinModel.name.replacingOccurrences(of: "(kappa)", with: gameData.name)
        } else {
            enemyImage.isHidden = false
            enemyImage.texture = SKTexture(imageNamed: cutinModel.image)
            kappa.isHidden = true
            nameLabel.text = cutinModel.name
        }
        let str = cutinModel.text1.replacingOccurrences(of: "(name)",  with: gameData.displayName(jobModel.displayName))
        text1Label.text = str.replacingOccurrences(of: "(death)", with: "\(gameData.death)")
        text2Label.text = cutinModel.text2.replacingOccurrences(of: "(name)",  with: gameData.displayName(jobModel.displayName))
    }
    
    func goBack(){
        view!.presentScene(backScene, transition: .fade(with: .red, duration: Const.gameOverInterval))
    }
    
    func goClear(){
        if bgm.isPlaying {
            bgm.stop()
        }
        let nextScene = GameClearScene(fileNamed: "GameClearScene")!
        nextScene.size = nextScene.size
        nextScene.scaleMode = SKSceneScaleMode.aspectFill
        nextScene.world = world
        view!.presentScene(nextScene, transition: .doorsCloseHorizontal(withDuration: Const.gameOverInterval))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        page += 1
        for t in touches {
            let positionInScene = t.location(in: self)
            let tapNode = self.atPoint(positionInScene)
            if tapNode.name != nil {
                switch tapNode.name! {
                case "SkipNode", "SkipLabel":
                    if key == "pre" {
                        goBack()
                    } else if key == "end" {
                        goClear()
                    }
                default:
                    break
                }
            }
        }

        if cutinModel.max_page <= page {
            if key == "pre" {
                goBack()
            } else if key == "end" {
                goClear()
            }
        } else {
            updateScreen()
        }
    }
}
