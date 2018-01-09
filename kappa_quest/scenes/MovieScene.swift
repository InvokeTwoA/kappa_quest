// 動画シーン
import SpriteKit
import GameplayKit

class MovieScene: BaseScene {
    
    let fadeInOut = SKAction.sequence([
        SKAction.fadeAlpha(to: 1.0, duration: 1.0),
        SKAction.fadeAlpha(to: 0.01, duration: 1.0)
        ])

    
    // 初めは非表示のノード
    private var hidden_image_node = [
        "message_box",
        "left_image",
        "right_image",
        "cutin"
    ]
    
    private var hidden_label_node = [
        "message1",
        "message2",
        "name",
        "chapter_num",
        "chapter_name"
        
    ]
    
    override func sceneDidLoad() {
        prepareBGM(fileName: Const.bgm_short_harujion)
        hideNodes()
        playBGM()
    }
    
    override func didMove(to view: SKView) {
        if chapter == 2 {
            changeChapterName(chapter_num: "第２章", chapter_name: "かっぱクエスト　ライバルズ")
        }
    }

    func hideNodes(){
        for key in hidden_image_node {
            hideSpriteNode(key)
        }
        for key in hidden_label_node {
            hideLabelNode(key)
        }
    }
    
    func onlyShowText(text1: String, text2: String){
        hideNodes()
        changeChapterName(chapter_num: text1, chapter_name: text2)
    }
    
    func showCutIn(){
        let cutin          = childNode(withName: "//cutin") as! SKSpriteNode
        cutin.isHidden = false
        cutin.texture = SKTexture(imageNamed: "cutin")
    }
    
    func crossFade(){
        let fade = childNode(withName: "//fade") as! SKSpriteNode
        fade.run(fadeInOut)
    }
    
    func changeChapterName(chapter_num : String, chapter_name : String){
        let num = childNode(withName: "//chapter_num") as! SKLabelNode
        let name = childNode(withName: "//chapter_name") as! SKLabelNode
        num.isHidden = false
        num.text = chapter_num
        name.isHidden = false
        name.text = chapter_name
    }
    
    func hideChapter(){
        let num = childNode(withName: "//chapter_num") as! SKLabelNode
        let name = childNode(withName: "//chapter_name") as! SKLabelNode
        num.isHidden = true
        name.isHidden = true
    }
    
    func changeMessage(name: String, text1: String, text2: String){
        let name_label   = childNode(withName: "//name") as! SKLabelNode
        let message1     = childNode(withName: "//message1") as! SKLabelNode
        let message2     = childNode(withName: "//message2") as! SKLabelNode
        let box          = childNode(withName: "//message_box") as! SKSpriteNode
        box.isHidden = false
        name_label.isHidden = false
        name_label.text = name
        message1.text = text1
        message1.isHidden = false
        message2.text = text2
        message2.isHidden = false
    }
    
    func changeImage(left_name: String, right_name : String) {
        let left = childNode(withName: "//left_image") as! SKSpriteNode
        let right = childNode(withName: "//right_image") as! SKSpriteNode

        if left_name == "nil" {
            left.isHidden = true
        } else {
            left.isHidden = false
            left.texture = SKTexture(imageNamed: left_name)
        }
        if right_name == "nil" {
            right.isHidden = true
        } else {
            right.isHidden = false
            right.texture = SKTexture(imageNamed: right_name)
        }
    }
    
    func fadeImage(image : String, point: CGPoint){
        let spriteNode = SKSpriteNode(imageNamed: image)
        spriteNode.position = point
        spriteNode.zPosition = 3
        addChild(spriteNode)
        spriteNode.run(fadeInOut)
    }
    
    func fadeText(text : String, point: CGPoint){
        let node = SKLabelNode(fontNamed: Const.pixelFont)
        node.fontSize = 32
        node.position = point
        node.text = text
        addChild(node)
        node.run(fadeInOut)
    }

    func changeBG(_ image : String){
        let cutin          = childNode(withName: "//cutin") as! SKSpriteNode
        cutin.isHidden = false
        cutin.texture = SKTexture(imageNamed: image)
    }
    
    
    func kappaBuster(){
        let left = childNode(withName: "//left_image") as! SKSpriteNode
        
        let circle = SKShapeNode(circleOfRadius: 40)
        circle.fillColor = UIColor.yellow
        circle.position = left.position
        circle.zPosition = 12
        self.addChild(circle)
        
        let busterAction = SKAction.sequence([
            SKAction.moveBy(x: 600, y: 0, duration: 0.3),
            SKAction.removeFromParent()
            ])
        circle.run(busterAction)
    }
    
    // 2章ムービー
    func displayMovie2(){
        switch step {
        case 0:
            fadeImage(image: "kappa_upper", point: CGPoint(x:0,y:0) )
        case 4:
            crossFade()
        case 6:
            showCutIn()
            changeChapterName(chapter_num: "伝説の英雄", chapter_name: "かっぱ")
            changeMessage(name: "かっぱ", text1: "これが新必殺技……", text2: "かっぱバスター！")
            changeImage(left_name: "kappa_punch", right_name: "nil")
        case 6,7,8,9,10:
            kappaBuster()
        case 11:
            crossFade()
        case 12:
            hideNodes()
            fadeText(text: "そして現れる", point: CGPoint(x: 0, y: 350))
            fadeText(text: "新たなる敵", point: CGPoint(x: 0, y: 250))
        case 18:
            showCutIn()
            changeBG("bg_green")
            changeChapterName(chapter_num: "茶色の暴君", chapter_name: "タヌキ")
            changeMessage(name: "たぬき", text1: "タヌキこそが最強の生物！", text2: "")
            changeImage(left_name: "nil", right_name: "tanuki")
        case 23:
            crossFade()
        case 24:
            changeBG("bg_forest")
            changeChapterName(chapter_num: "血塗られた将軍", chapter_name: "権力のイヌ")
            changeMessage(name: "権力のイヌ", text1: "長いものには巻かれる", text2: "それが私の正義")
            changeImage(left_name: "nil", right_name: "dog")
        case 29:
            crossFade()
        case 30:
            hideNodes()
            fadeText(text: "モブキャラの憎しみ", point: CGPoint(x:0,y:0) )
        case 33:
            hideChapter()
            fadeImage(image: "real_death", point: CGPoint(x:0,y:0) )
        case 34:
            fadeText(text: "広告から得た真グラフィック", point: CGPoint(x:0,y:-150) )
        case 35:
            fadeImage(image: "real_zombi", point: CGPoint(x:-200,y:100) )
        case 36:
            fadeText(text: "憧れのナイスバディ", point: CGPoint(x:-50,y: 350) )
        case 37:
            fadeImage(image: "real_dancer", point: CGPoint(x:200,y:-100) )
        case 38:
            fadeText(text: "失われた力", point: CGPoint(x:250,y: -150) )
        case 39:
            fadeImage(image: "red_dragon", point: CGPoint(x:0,y:50) )
        case 40:
            fadeText(text: "サバンナ", point: CGPoint(x:50,y: 50) )
        case 41:
            fadeImage(image: "real_hiyoko", point: CGPoint(x:100,y:200) )
        case 42:
            fadeText(text: "俺はただ、ガチャを回したかっただけだ……", point: CGPoint(x:-100,y: -100) )
        case 43:
            fadeImage(image: "real_tokage", point: CGPoint(x:-300,y:-200) )
        case 48:
            crossFade()
        case 49:
            onlyShowText(text1: "やがて訪れる", text2: "終わりの時")
        case 53:
            hideNodes()
            crossFade()
        case 54:
            showCutIn()
            changeImage(left_name: "nil", right_name: "priest")
            changeMessage(name: "僧侶", text1: "あなたは、本当にカッパなの？", text2: "")
        case 58:
            crossFade()
        case 59:
            changeImage(left_name: "nil", right_name: "fighter")
            changeMessage(name: "勇者", text1: "かっぱ。たとえ君が", text2: "どんな姿になっても……")
        case 63:
            crossFade()
        case 64:
            changeImage(left_name: "nil", right_name: "dancer")
            changeMessage(name: "踊り子", text1: "ごめんなさい。", text2: "かっぱ……")
        case 76:
            crossFade()
        case 77:
            showCutIn()
            changeImage(left_name: "kappa_punch", right_name: "nil")
            changeMessage(name: "かっぱ", text1: "オラオラオラオラ", text2: "オラオラオラオラー！")
        case 85:
            crossFade()
        case 86:
            hideNodes()
            changeMessage(name: "かっぱ", text1: "またね、かっぱ……", text2: "")
        case 90:
            movieEnd()
        default:
            break
        }
    }
    
    func movieEnd(){
        stopBGM()
        goWorld2()
    }
    
    
    /***********************************************************************************/
    /********************************** touch ******************************************/
    /***********************************************************************************/
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let beganPosition : CGPoint!
            beganPosition = t.location(in: self)
            let tapNode = atPoint(beganPosition)
            if tapNode.name == nil {
                return
            }
            
            if tapNode.name! == "SkipLabel" || tapNode.name == "SkipNode" {
                movieEnd()
            }
        }
    }

    /***********************************************************************************/
    /********************************* update ******************************************/
    /***********************************************************************************/
    override func secondTimerExec() {
        if chapter == 2 {
            displayMovie2()
        } else {
            print("chapter=\(chapter))")
        }
    }
}
