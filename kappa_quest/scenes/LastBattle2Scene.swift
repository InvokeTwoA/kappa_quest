// ラストバトル
import SpriteKit
import GameplayKit
import Social
import CoreMotion

class LastBattle2Scene: GameBaseScene {
    private let motionManager = CMMotionManager()
    private var usagi : UsagiNode!
    private let usagi_first_position : CGPoint = CGPoint(x: 0, y: 224)
    
    // 章に応じて変数を上書き
    override func setBaseVariable(){
        chapter = 2
        world_name = "usagi"
        
        setMotion()
        setWorld()
        setWorldWall()
        
        actionModel.setActionData(sceneWidth: size.width)
        
        createKappa()
        createUsagi()
        kappa.spaceMode()

        gameData.setParameterByUserDefault()
        changeLifeLabel()

    }
    
    override func setMusic() {
        prepareBGM(fileName: Const.bgm_zinna)
//        prepareBGM(fileName: Const.bgm_short_harujion)
        prepareSoundEffect()
        stopBGM()
//        playBGM()
    }
    
    override func didMove(to view: SKView) {
    }
        
    override func tapCountUp(){
        gameData.tapCount += 1
    }
    
    func createUsagi(){
        usagi = UsagiNode.makeUsagi()
        usagi.position = usagi_first_position
        usagi.setPhysic()
        addChild(usagi)
    }

    func setWorldWall(){
        setWorldRightWall()
        setWorldLeftWall()
        setWorldUpWall()
    }
    
    func setWorldRightWall(){
        let point : CGPoint = CGPoint(x:frame.maxX, y: frame.midY)
        let size : CGSize = CGSize(width: 1, height: frame.height)
        let background : SKSpriteNode = SKSpriteNode(color: UIColor.black, size: size)
        background.position = point
        background.zPosition = 100
        background.physicsBody = SKPhysicsBody(rectangleOf: size)
        WorldNode.setUnvisibleWorldPhysic(background.physicsBody!)
        addChild(background)
    }

    func setWorldLeftWall(){
        let point : CGPoint = CGPoint(x:frame.minX, y: frame.midY)
        let size : CGSize = CGSize(width: 1, height: frame.height)
        let background : SKSpriteNode = SKSpriteNode(color: UIColor.black, size: size)
        background.position = point
        background.zPosition = 100
        background.physicsBody = SKPhysicsBody(rectangleOf: size)
        WorldNode.setUnvisibleWorldPhysic(background.physicsBody!)
        addChild(background)
    }

    func setWorldUpWall(){
        let point : CGPoint = CGPoint(x:frame.midX, y: frame.maxY - 100)
        let size : CGSize = CGSize(width: frame.width, height: 1)
        let background : SKSpriteNode = SKSpriteNode(color: UIColor.black, size: size)
        background.position = point
        background.zPosition = 100
        background.physicsBody = SKPhysicsBody(rectangleOf: size)
        WorldNode.setUnvisibleWorldPhysic(background.physicsBody!)
        addChild(background)
    }
    
    // 攻撃をされた
    override func attacked(attack:Int, point: CGPoint){
        let damage = BattleModel.calculateDamage(str: attack, def: 0)
        playSoundEffect(type: 1)
        kappa.hp -= damage
        if kappa.hp <= 0 {
            kappa.hp = 0
        }
        displayDamage(value: damage, point: CGPoint(x:point.x-30, y:point.y+30), color: UIColor.red, direction: "left")
        changeLifeBar()
        changeLifeLabel()
        if kappa.hp == 0 {
            gameOver()
        }
    }
    
    private func changeLifeLabel(){
        let HPLabel   = childNode(withName: "//HPLabel")     as! SKLabelNode
        HPLabel.text  = "\(kappa.hp)"
    }
    
    override func execMessages(){
        if !isShowingBigMessage && bigMessages.count > 0 {
            displayBigMessage()
        }
    }
    
    private var gameClearFlag = false
    private func gameClear(){
        if gameClearFlag {
            return
        }
        gameClearFlag = true
        goEnding()
    }
    
    private func bossHit(){
    }

    /***********************************************************************************/
    /********************************* 敵の攻撃 *****************************************/
    /***********************************************************************************/
    func rotateLazer(angle: CGFloat,  interval : TimeInterval){
        let lazer = SKShapeNode(rectOf: CGSize(width: frame.height*2, height: 10))
        lazer.position = usagi.position
        lazer.fillColor = UIColor.red
        lazer.zPosition = 2
        
        let physic = SKPhysicsBody(rectangleOf: lazer.frame.size)
        physic.affectedByGravity = false
        physic.categoryBitMask = Const.lazerCategory
        physic.contactTestBitMask = 0
        physic.collisionBitMask = 0
        lazer.physicsBody = physic
        addChild(lazer)
        
        lazer.run(
            SKAction.sequence([
                SKAction.rotate(byAngle: angle, duration: interval),
                SKAction.removeFromParent()
            ])
        )
    }
    
    func usagiFire(){
        let fire = FireEmitterNode.makeFire()
        fire.damage = 13
        fire.position = CGPoint(x: usagi.position.x, y: usagi.position.y + 40 )
        self.addChild(fire)
        fire.fingerFlareBoms()
    }
    
    func arrowRain(){
        if CommonUtil.rnd(2) == 0 {
            createArrow(pos: 1, damage: 7)
            createArrow(pos: 4, damage: 7)
            createArrow(pos: 6, damage: 7)
        } else {
            createArrow(pos: 1, damage: 7)
            createArrow(pos: 3, damage: 7)
            createArrow(pos: 6, damage: 7)
        }
    }
    
    
    /***********************************************************************************/
    /********************************* モーションセンサー *********************************/
    /***********************************************************************************/
    func setMotion(){
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates()
    }
    
    func setVelocity(x : Double, y : Double){
        let dx = CGFloat(Double(1000)*x)
        let dy = CGFloat(Double(1000)*y)
        kappa.physicsBody!.velocity = CGVector(dx: dx, dy: dy)
        
        if dx < 0 {
            kappa.xScale = -1
        } else {
            kappa.xScale = 1
        }
    }
    
    /***********************************************************************************/
    /********************************* 未使用関数 ****************************************/
    /***********************************************************************************/
    override func willMove(from view: SKView) {
    }
    
    override func updateStatus() {
        changeLifeBar()
    }
    
    override func updateDistance(){
    }
    
    override func updateName() {
    }
    
    override func createMap(){
    }
    
    /***********************************************************************************/
    /********************************* 画面遷移 *****************************************/
    /***********************************************************************************/
    // メニュー画面へ遷移
    private func goEnding(){
        let root = self.view?.window?.rootViewController as! GameViewController
        root.hideBannerEternal()
        let bg = SKSpriteNode(imageNamed: "bg_green")
        bg.position.x = 0
        bg.position.y = 1500
        bg.size.width = self.size.width
        bg.size.height = self.size.height
        bg.zPosition = 5
        addChild(bg)
        
        GameData.clearCountUp("last")
        GameData.resetClearCount("dark_kappa")
        
        bg.run(SKAction.move(to: CGPoint(x:0, y: 0), duration: 15.0), completion: {() -> Void in            
            self.showBigMessage(text0: "……こうして", text1: "世界は救われた")   // 6.7
            self.showBigMessage(text0: "広告のなくなった世界で", text1: "")
            self.showBigMessage(text0: "16ドットのキャラクタ達は", text1: "幸せに暮らしていくだろう")
            self.showBigMessage(text0: "人々は偉大なるカッパの冒険を", text1: "")
            self.showBigMessage(text0: "カッパクエストと呼んだ", text1: "")
            self.showBigMessage(text0: "Thank you for playing", text1: "")
            
            let label = SKLabelNode(fontNamed: Const.pixelFont)
            label.text = "タップ回数: \(self.gameData.tapCount)"
            label.position = CGPoint(x:0, y:100)
            label.zPosition = 99
            label.fontSize = 32
            self.addChild(label)
            
            let label2 = SKLabelNode(fontNamed: Const.pixelFont)
            label2.text = "トータルLV: \(self.kappa.lv)"
            label2.position = CGPoint(x:0, y:0)
            label2.zPosition = 99
            label2.fontSize = 32
            self.addChild(label2)
            
            let label3 = SKLabelNode(fontNamed: Const.pixelFont)
            label3.text = self.gameData.displayName(self.jobModel.displayName)
            label3.position = CGPoint(x:0, y: -100)
            label3.zPosition = 99
            label3.fontSize = 32
            self.addChild(label3)
        })
    }
    
    /***********************************************************************************/
    /********************************** 衝突判定 ****************************************/
    /***********************************************************************************/
    override func didBegin(_ contact: SKPhysicsContact) {
        var firstBody, secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        if firstBody.node == nil || secondBody.node == nil {
            return
        }
        
        if isFirstBodyKappa(firstBody) {
            if secondBody.categoryBitMask & Const.fireCategory != 0 {
                let fire = secondBody.node as! FireEmitterNode
                attacked(attack: fire.damage, point: (firstBody.node?.position)!)
                makeSpark(point: (secondBody.node?.position)!)
                secondBody.node?.removeFromParent()
            } else if secondBody.categoryBitMask & Const.thunderCategory != 0 {
                let thunder = secondBody.node as! ThunderEmitterNode
                attacked(attack: thunder.damage, point: (firstBody.node?.position)!)
                makeSpark(point: (secondBody.node?.position)!)
                secondBody.node?.removeFromParent()
            } else if secondBody.categoryBitMask & Const.lazerCategory != 0 {
                attacked(attack: 18, point: (firstBody.node?.position)!)
                makeSpark(point: (secondBody.node?.position)!)
            } else if secondBody.categoryBitMask & Const.usagiCategory != 0 {
                attacked(attack: 22, point: (firstBody.node?.position)!)
                makeSpark(point: (secondBody.node?.position)!)
            }
        } else if isMagickNode(firstBody) {
            if secondBody.categoryBitMask & Const.worldCategory != 0 {
                makeSpark(point: (firstBody.node?.position)!)
                firstBody.node?.removeFromParent()
            }
        }
    }
    
    /***********************************************************************************/
    /********************************** touch ******************************************/
    /***********************************************************************************/
    private var attack_num = 0
    override func touchDown(atPoint pos : CGPoint) {
        if gameClearFlag {
            return
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tapCountUp()
        if map.myPosition+1 > Const.maxPosition {
            return
        }
        for t in touches {
            let positionInScene = t.location(in: self)
            touchDown(atPoint: positionInScene)
            let tapNode = atPoint(positionInScene)
            if tapNode.name == "TitleNode" || tapNode.name == "TitleLabel" {
                goTitle()
            } else if tapNode.name == "tweet" {
                let name = gameData.displayName(jobModel.displayName)
                tweet("【朗報】\(name)は世界を救った！【この時を待ってたぜ】  #かっぱクエスト")
            }
        }
    }
    
    /***********************************************************************************/
    /********************************* update ******************************************/
    /***********************************************************************************/
    private var lastUpdateTime : TimeInterval = 0
    private var doubleTimer = 0.0 // 経過時間（小数点単位で厳密）
    private var stage = 0
    override func update(_ currentTime: TimeInterval) {
        execMessages()
        if gameover_check_flag || kappa.hp <= 0 {
            return
        }

        // 加速度の処理
        if let accelerometerData = motionManager.accelerometerData {
            setVelocity(x: accelerometerData.acceleration.x, y: accelerometerData.acceleration.y)
        }
        
        if (lastUpdateTime == 0) {
            lastUpdateTime = currentTime
        }
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        doubleTimer += dt
        if doubleTimer > 1.0 {
            doubleTimer = 0.0
        } else {
            return
        }
        
        stage += 1
        switch stage {
        case 1:
            showBigMessage(text0: "カッパ……宇宙まで追ってくるとは……", text1: "")
        case 9:
            showBigMessage(text0: "今こそ決着をつけよう！", text1: "")
            playBGM()
        case 11:
            showSkillBox("黒き雷")
            createThunder(pos: 1, damage: 5)
            createThunder(pos: 2, damage: 5)
            createThunder(pos: 3, damage: 5)
            createThunder(pos: 4, damage: 5)
        case 14:
            showSkillBox("黒き雷")
            createThunder(pos: 3, damage: 5)
            createThunder(pos: 4, damage: 5)
            createThunder(pos: 5, damage: 5)
            createThunder(pos: 6, damage: 5)
        case 16:
            showSkillBox("黒き雷")
            createThunder(pos: 1, damage: 5)
            createThunder(pos: 2, damage: 5)
            createThunder(pos: 3, damage: 5)
            createThunder(pos: 4, damage: 5)
        case 18:
            usagi.attack(from: usagi_first_position, to: kappa.position)
        case 20, 22, 24:
            showSkillBox("アローレイン")
            arrowRain()
        case 23:
            showBigMessage(text0: "なかなか", text1: "やるな")
        case 24:
            showSkillBox("回天剣舞七連")
            rotateLazer(angle: CGFloat(Double.pi),interval: 6.0)
        case 29:
            showSkillBox("アローレイン")
            arrowRain()
        case 31,32,33,34,35,36,37:
            showSkillBox("フィンガーフレアボム")
            usagiFire()
            usagiFire()
            usagiFire()
            usagiFire()
            usagiFire()
        case 38:
            showSkillBox("回天剣舞八連")
            rotateLazer(angle: -1 * CGFloat(Double.pi*2), interval: 6.0)
        case 43:
            showBigMessage(text0: "まだ", text1: "諦めないというのか")
        case 49,50,51,52,53,54,55:
            showSkillBox("ブルートフォースアタック")
            createArrow(pos: CommonUtil.rnd(6) + 1, damage: 6)
            createArrow(pos: CommonUtil.rnd(6) + 1, damage: 6)
            createArrow(pos: CommonUtil.rnd(6) + 1, damage: 6)
            createArrow(pos: CommonUtil.rnd(6) + 1, damage: 6)
        case 56:
            usagi.attack(from: usagi_first_position, to: kappa.position)
        case 57:
            showBigMessage(text0: "僕は広告を通して様々なゲームを見てきた。", text1: "")
        case 59:
            showSkillBox("初剣殺し")
            rotateLazer(angle: CGFloat(Double.pi*2),interval: 8.0)
        case 61:
            showSkillBox("初剣殺し2")
            rotateLazer(angle: CGFloat(Double.pi*2),interval: 8.0)
        case 67:
            usagi.attack(from: usagi_first_position, to: kappa.position)
        case 69:
            showBigMessage(text0: "必殺技を", text1: "くらえ")
        case 70,72,74,76,78:
            showSkillBox("黒き雷")
            createThunder(pos: 1, damage: 5)
            createThunder(pos: 2, damage: 5)
            createThunder(pos: 3, damage: 5)
            createThunder(pos: 4, damage: 5)
        case 71,73,75,77,79:
            showSkillBox("黒き雷")
            createThunder(pos: 3, damage: 5)
            createThunder(pos: 4, damage: 5)
            createThunder(pos: 5, damage: 5)
            createThunder(pos: 6, damage: 5)
        case 81:
            usagi.attack(from: usagi_first_position, to: kappa.position)
        case 90:
            showBigMessage(text0: "お前の", text1: "勝ちだ……")
        case 115:
            showBigMessage(text0: "とどめを刺せ", text1: "")
        case 310,311,312,323,323,324,325,326,327,328,329:
            showSkillBox("必殺の一撃")
            createArrow(pos: CommonUtil.rnd(6) + 1, damage: 6)
            createArrow(pos: CommonUtil.rnd(6) + 1, damage: 6)
            createArrow(pos: CommonUtil.rnd(6) + 1, damage: 6)
            usagiFire()
            usagiFire()
            usagiFire()
        case 330:
            showBigMessage(text0: "これで、終わりだ", text1: "")
        case 331:
            stopBGM()
            prepareBGM(fileName: Const.bgm_piano_millky)
            playBGM()
        default:
            break
        }
    }
}

