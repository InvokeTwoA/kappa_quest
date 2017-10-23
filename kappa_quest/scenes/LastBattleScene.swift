// ラストバトル
import SpriteKit
import GameplayKit

class LastBattleScene: GameScene {
    
    var volume : Float = 1.0
    
    // Scene load 時に呼ばれる
    override func sceneDidLoad() {
        // 二重読み込みの防止
        if isSceneDidLoaded {
            return
        }
        isSceneDidLoaded = true
        
        lastUpdateTime = 0
        setWorld()
        
        // データをセット
        actionModel.setActionData(sceneWidth: size.width)
        createKappa()
        updateName()
        updateStatus()
        
        // 音楽関係の処理
        prepareBGM(fileName: Const.bgm_fantasy)
        prepareSoundEffect()
        playBGM()

        gameData.setParameterByUserDefault()
    }
    
    override func willMove(from view: SKView) {
    }
    
    
    
    // 次のマップに移動
    private var map_no = 0
    override func goNextMap(){
        clearMap()
        resetMessage()
        setFirstPosition()
        map.goNextMap()
        createMap()
        updateDistance()

        map_no += 1
        if map_no == 1 {
            destroyWorld(destroy_nodes1)
        } else if map_no == 2 {
            destroyWorld(destroy_nodes2)
        } else if map_no == 3 {
            destroyWorld(destroy_nodes3)
            kappa.run(actionModel.kappaDown!)
        } else if map_no == 4 {
            destroyWorld(destroy_nodes4)
        } else if map_no == 5 {
            destroyWorld(destroy_nodes5)
        } else if map_no == 6 {
            destroyWorld(destroy_nodes6)
        } else if map_no == 7 {
            destroyWorld(destroy_nodes7)
        } else if map_no == 8 {
            destroyWorld(destroy_nodes8)
        } else if map_no == 9 {
            destroyWorld(destroy_nodes9)
        }
    }
    
    func destroyWorld(_ array : [String]){
        for name in array {
            deleteSPriteNode(name)
        }
    }
    
    private let destroy_nodes1 = [
        "IconNotKappaHead",
        "IconKappaHead",
        "StatusLabelNode",
    ]
    private let destroy_nodes2 = [
        "IconNotKappaUpper",
        "IconKappaUpper",
        "ButtonNode",
    ]
    private let destroy_nodes3 = [
        "underground",
        "BackGround",
        ]
    private let destroy_nodes4 = [
        "IconNotKappaTornado",
        "IconKappaTornado",
    ]
    private let destroy_nodes5 = [
        "HPLabel",
        "HP",
        "IconNotKappaHado",
        "IconKappaHado",
    ]
    
    private let destroy_nodes6 = [
        "NameBox",
    ]

    private let destroy_nodes7 = [
        "ExpBox",
        "ExpBar"
    ]

    private let destroy_nodes8 = [
        "JobBox",
    ]

    private let destroy_nodes9 = [
        "BackgroundNode"
    ]

    private let boss_kappa = EnemyNode(imageNamed: "dark_kappa")
    func bossGenerate(){
        boss_kappa.position.x = getPositionX(Const.maxPosition - 1)
        boss_kappa.position.y = kappa.position.y
        boss_kappa.zPosition = 99
        boss_kappa.size = kappa.size
        boss_kappa.name = "boss"
        boss_kappa.anchorPoint = CGPoint(x: 0.5, y: 0)     // 中央下がアンカーポイント
        map.positionData[Const.maxPosition-1] = "enemy"
        addChild(boss_kappa)
    }
    
    override func setFirstPosition(){
        map.myPosition = 1
        kappa.position.x = getPositionX(1)
        kappa.texture = SKTexture(imageNamed: "kappa")
    }
    
    /***********************************************************************************/
    /******************************** マップ更新    **************************************/
    /***********************************************************************************/
    // マップ作成
    var bossStartFlag = false
    override func createMap(){
        map.updatePositionData()
        for (index, positionData) in map.positionData.enumerated() {
            switch positionData {
            case "enemy":
                map.positionData[index] = "free"
            default:
                break
            }
        }
        
        changeBackGround()
        if map.isEvent {
            showBigMessage(text0: map.text0, text1: map.text1)
        }
        if map.isBoss {
            stopBGM()
            prepareBGM(fileName: Const.bgm_bit_ahurera)
            playBGM()
            kappa.maxHp = 100
            kappa.hp = 100
            
            let HPLabel        = childNode(withName: "//HPLabel")     as! SKLabelNode
            HPLabel.text  = "\(kappa.hp)"
            HPLabel.fontColor = .white

            bossGenerate()
            bossStartFlag = true
        }
    }
    
    override func tapCountUp(){
        gameData.tapCount += 1
    }

    /***********************************************************************************/
    /********************************** endhing attack *********************************/
    /***********************************************************************************/
    private let ending_array0 = ["ス", "タ", "ッ", "フ", "", ""]
    private let ending_array1 = ["", "", "", "", "", ""]
    private let move_pattern  = ["fast", "slow", "back", "so_quick", "so_slow", "fade"]
    
    func endingAttack(_ page : Int){
        var target_array0 = [String]()
        var target_array1 = [String]()
        switch page {
        case 1:
            target_array0 = ending_array0
        case 5:
            target_array0 = ["キ", "ャ", "ラ", "画", "像", ""]
            target_array1 = ["", "k", "a", "p", "p", "a"]
        case 10:
            target_array0 = ["背", "景", "素", "材", "", ""]
            target_array1 = ["", "ぴ", "ぽ", "や", "倉庫", ""]
        case 15:
            target_array0 = ["ボ", "タ", "ン", "", "画", "像"]
            target_array1 = ["ぴ", "た", "ち", "ー", "素", "材館"]
        case 20:
            target_array0 = ["B", "G", "M", "", "", ""]
            target_array1 = ["", "", "", "魔", "王", "魂"]
        case 25:
            target_array0 = ["カ", "ッ", "ト", "イ", "ン", "素材"]
            target_array1 = ["", "", "ビ", "タ", "犬", ""]
        case 30:
            target_array0 = ["プ", "ロ", "グ", "", "ラ", "マ"]
            target_array1 = ["k", "", "a", "p", "p", "a"]
        case 35:
            target_array0 = ["シ", "ナ", "リ", "オ", "", ""]
            target_array1 = ["k", "a", "p", "", "p", "a"]
        case 40:
            target_array0 = ["グ", "ラ", "フ", "ィ", "ッ", "ク"]
            target_array1 = ["k", "a", "p", "p", "", "a"]
        case 45:
            target_array0 = ["キャ", "ラ", "デ", "ザ", "イ", "ン"]
            target_array1 = ["", "k", "a", "p", "p", "a"]
        case 50:
            target_array0 = ["テ", "ス", "タ", "ー", "", ""]
            target_array1 = ["", "k", "a", "p", "p", "a"]
        case 55:
            target_array0 = ["ディ", "レク", "タ", "ー", "", ""]
            target_array1 = ["", "k", "a", "p", "p", "a"]
        case 60:
            target_array0 = ["宣", "伝", "担", "当", "", ""]
            target_array1 = ["", "k", "a", "p", "p", "a"]
        case 65:
            target_array0 = ["ドッ", "ト絵", "制作", "ツ", "ー", "ル"]
            target_array1 = ["d", "o", "t", "p", "i", "ct"]
    
        case 75:
            target_array0 = ["s", "p", "e", "c", "i", "al"]
            target_array1 = ["t", "h", "a", "n", "k", "s"]
        case 80:
            target_array0 = ["t", "a", "k", "a", "sh", "i"]
            target_array1 = ["h", "a", "g", "u", "r", "a"]
        case 85:
            target_array0 = ["n", "a", "o", "f", "u", "mi"]
            target_array1 = ["h", "a", "t", "t", "o", "ri"]
        case 90:
            target_array0 = ["r", "y", "o", "", "", ""]
            target_array1 = ["m", "u", "r", "a", "ka", "mi"]
        case 95:
            target_array0 = ["(", "k", "i", "n", "g", ")"]
            target_array1 = ["", "", "", "", "", ""]
        case 100:
            target_array0 = ["A", "n", "d", "…", "…", ""]
            target_array1 = ["", "", "", "Y", "o", "u"]

        default:
            target_array0 = ["", "", "", "", "", ""]
            target_array1 = ["", "", "", "", "", ""]
            break
        }
        
        for (index, key) in target_array0.enumerated() {
            if key != "" {
                setStaffRole(pos: index, key: key, height: kappa_first_position_y + 350)
            }
        }
        for (index, key) in target_array1.enumerated() {
            if key != "" {
                setStaffRole(pos: index, key: key, height: kappa_first_position_y + 250)
            }
        }
    }
    
    func setStaffRole(pos: Int, key: String, height: CGFloat){
        if key == "" {
            return
        }
        
        let pattern = move_pattern[CommonUtil.rnd(move_pattern.count)]
        var action = actionModel.downSlow
        var color = UIColor.white
        var textColor = UIColor.black
        switch pattern {
        case "fast":
            action = actionModel.downQuick
            color  = .white
        case "slow":
            action = actionModel.downSlow
            color = .cyan
        case "back":
            action = actionModel.downBack
            color = .orange
        case "so_quick":
            action = actionModel.downMaxQuick
            color = .red
            textColor = .white
        case "so_slow":
            action = actionModel.downMaxSlow
            color = .blue
            textColor = .white
        case "fade":
            action = actionModel.downFade
            color = .green
            textColor = .black
        default:
            break
        }
        
        let box = SKSpriteNode(color: color, size: CGSize(width: 100, height: 100))
        box.zPosition = 49
        box.position.x = getPositionX(pos) + 60.0
        box.position.y = height
        box.anchorPoint = CGPoint(x: 0.0, y: 0.5)     // 右がアンカーポイント
        box.physicsBody = setEnemyPhysic(box.size)
        addChild(box)
        
        let item = SKLabelNode(text: key)
        item.fontName = Const.pixelFont
        item.fontSize = 32
        item.fontColor = textColor
        item.position.x = 50
        item.position.y = 0
        item.zPosition = 50
        item.name = "text"
        box.addChild(item)
        
        box.run(action!)
    }
    
    func setEnemyPhysic(_ target_size : CGSize) -> SKPhysicsBody {
        let physic = SKPhysicsBody(rectangleOf: target_size, center: CGPoint(x:size.width/14, y: 0))
        
        physic.affectedByGravity = false
        physic.categoryBitMask = Const.fireCategory
        physic.contactTestBitMask = 0
        physic.collisionBitMask = 0
        return physic
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
    
    
    func changeLifeLabel(){
        let HPLabel        = childNode(withName: "//HPLabel")     as! SKLabelNode
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
    
    private var boss_position = 6
    func bossMoveLeft(){
        let boss = childNode(withName: "//boss") as! SKSpriteNode
        boss.run(actionModel.moveLeft)
        map.positionData[boss_position] = "free"
        map.positionData[boss_position-1] = "enemy"
        boss_position -= 1
    }
    
    func bossHit(){
        attack_num += 1
        let boss = childNode(withName: "//boss") as! SKSpriteNode
        makeSpark(point: boss.position, isCtirical: false)
        
        if attack_num == 5 {
            if boss_position != Const.maxPosition {
                boss.run(actionModel.moveRight)
                map.positionData[boss_position] = "free"
                map.positionData[boss_position+1] = "enemy"
                boss_position += 1
            }
            attack_num = 0
        }
    }
    
    var vsAdFlag = false
    func vsAd(){
        vsAdFlag = true
        kappa.position.x = getPositionX(2)
        kappa.xScale = 1
     
        let boss = childNode(withName: "//boss") as! SKSpriteNode
        boss.position.x = getPositionX(5)
        
    }
    
    var ad_num = 0
    func adAttack(){
        ad_num += 1
        
        kappaFire()

        if ad_num == 3 {
            showBigMessage(text0: "カッパ", text1: "まさか君は……")
        }
        
        if ad_num == 10 || ad_num == 20 || ad_num == 30 || ad_num == 40 || ad_num == 39 {
            kappa.run(actionModel.upper!)
        } else {
            kappa.attack()
        }
        
        if ad_num == 50 {
            showBigMessage(text0: "広告が", text1: "消えていく……")
            showBigMessage(text0: "おおお……", text1: "この眩しさ")
            showBigMessage(text0: "これが", text1: "太陽……！")
            showBigMessage(text0: "俺の", text1: "完敗だ")
            showBigMessage(text0: "君こそが", text1: "真のカッパだ！")
            gameClear()
            changeBGM()
        }
    }
    
    func kappaFire(){
        let fire = FireEmitterNode.makeKappaUpperFire()
        fire.position = kappa.position
        addChild(fire)

        let pos_x = 150 + CommonUtil.rnd(150)
        let move = SKAction.sequence([
            SKAction.moveBy(x: CGFloat(pos_x), y:    720, duration: 1.0),
            SKAction.removeFromParent(),
            ])
        fire.run(move, completion: {() -> Void in
            self.makeSpark(point: fire.position)
        })
    }
    
    func changeBGM(){
        stopBGM()
        prepareBGM(fileName: Const.bgm_bit_millky)
        playBGM()
    }
    
    /***********************************************************************************/
    /********************************* 画面遷移 ****************************************/
    /***********************************************************************************/
    // メニュー画面へ遷移
    func goEnding(){
        let root = self.view?.window?.rootViewController as! GameViewController
        root.hideBanner()
        
        let bg = SKSpriteNode(imageNamed: "bg_green")
        bg.position.x = 0
        bg.position.y = 1500
        bg.size.width = self.size.width
        bg.size.height = self.size.height
        bg.zPosition = 5
        addChild(bg)

        bg.run(SKAction.move(to: CGPoint(x:0, y: 0), duration: 15.0), completion: {() -> Void in
            self.appearNode(name: "dancer",  position: CGPoint(x: -100, y: -400 ))
            self.appearNode(name: "miyuki",  position: CGPoint(x: -200, y: -400 ))
            self.appearNode(name: "fighter", position: CGPoint(x: -300, y: -400 ))
            self.appearNode(name: "wizard",  position: CGPoint(x: 0,    y: -400 ))
            self.appearNode(name: "knight",  position: CGPoint(x: 100, y: -400 ))
            self.appearNode(name: "angel",   position: CGPoint(x: 200, y: -400 ))
            self.appearNode(name: "priest",   position: CGPoint(x: 300, y: -400 ))

            self.appearNode(name: "archer",  position: CGPoint(x: -100, y: -300 ))
            self.appearNode(name: "necro",   position: CGPoint(x: -200, y: -300 ))
            self.appearNode(name: "thief",   position: CGPoint(x: -300, y: -300 ))
            self.appearNode(name: "king",    position: CGPoint(x:   0, y: -300 ))
            self.appearNode(name: "gundom",  position: CGPoint(x: 100, y: -300 ))
            self.appearNode(name: "ninja",   position: CGPoint(x: 200, y: -300 ))
            self.appearNode(name: "samurai", position: CGPoint(x: 300, y: -300 ))
            
            self.showBigMessage(text0: "……こうして", text1: "世界は救われた")
            self.showBigMessage(text0: "広告のなくなった世界で", text1: "")
            self.showBigMessage(text0: "16ドットのキャラクタ達は", text1: "幸せに暮らしていくだろう")
            self.showBigMessage(text0: "人々は偉大なるカッパの冒険を", text1: "")
            self.showBigMessage(text0: "カッパクエストと呼んだ", text1: "")
            self.showBigMessage(text0: "Thank you for playing", text1: "")
            
            let label = SKLabelNode(fontNamed: Const.pixelFont)
            label.text = "タップ回数: \(self.gameData.tapCount)"
            label.position = CGPoint(x:0, y:300)
            label.zPosition = 99
            label.fontSize = 32
            self.addChild(label)
            
            let label2 = SKLabelNode(fontNamed: Const.pixelFont)
            label2.text = "トータルLV: \(self.gameData.tapCount)"
            label2.position = CGPoint(x:0, y:200)
            label2.zPosition = 99
            label2.fontSize = 32
            self.addChild(label2)
        })
    }

    func appearNode(name : String, position : CGPoint){
        var from_position = CGPoint(x: 0, y: -100)
        switch CommonUtil.rnd(3) {
        case 0:
            from_position = CGPoint(x:-self.size.width, y: -400)
        case 1:
            from_position = CGPoint(x:self.size.width, y: -400)
        case 2:
            from_position = CGPoint(x:self.size.width, y: -400)
        default:
            from_position = CGPoint(x:-self.size.width, y: -400)
        }
        
        
        let bg = SKSpriteNode(imageNamed: name)
        bg.position = from_position
        bg.size.width = Const.enemySize
        bg.size.height = Const.enemySize
        bg.zPosition = 6
        addChild(bg)
        
        bg.run(SKAction.move(to: position, duration: 12.0))
    }
    
    func appearText(_ text : String, from: CGFloat){
        let label = SKLabelNode(fontNamed: Const.pixelFont)
        label.text = text
        label.position = CGPoint(x:0, y: from)
        label.fontSize = 24
        addChild(label)

        let upper = SKAction.sequence([
            SKAction.moveTo(y: -600, duration: 10),
            SKAction.removeFromParent()
            ])

        label.run(upper)
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
                makeSpark(point: (secondBody.node?.position)!)
                secondBody.node?.removeFromParent()
                attacked(attack: 5, point: (firstBody.node?.position)!)
            }
        }
    }
    
    /***********************************************************************************/
    /********************************** touch ******************************************/
    /***********************************************************************************/
    var attack_num = 0
    override func touchDown(atPoint pos : CGPoint) {
        if gameClearFlag {
            return
        }
        if vsAdFlag {
            adAttack()
            return
        }
        
        if pos.x >= 0 {
            if map.canMoveRight() {
                moveRight()
            } else if map.isRightEnemy() {
                attack()
                bossHit()
            } else {
                kappa.run(actionModel.moveBack2)
            }
        } else {
            if map.canMoveLeft() {
                moveLeft()
                if bossStartFlag {
                    if map.myPosition == 1 || map.myPosition == 3 || map.myPosition == 5 {
                        bossMoveLeft()
                    }
                }
            } else {
                kappa!.run(actionModel.moveBack!)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tapCountUp()
        if map.myPosition+1 > Const.maxPosition {
            return
        }
        for t in touches {
            let positionInScene = t.location(in: self)
//            let tapNode = self.atPoint(positionInScene)
            touchDown(atPoint: positionInScene)
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
        
        if !bossStartFlag {
            return
        }
        
        stage += 1
        switch stage {
        case 1,5,10,15,20,25, 30, 35, 40, 45, 50, 55, 60, 65, 75, 80, 85, 90, 95, 100:
            endingAttack(stage)
        case 70:
            showBigMessage(text0: "しぶとい奴め……", text1: "")
        case 76:
            showBigMessage(text0: "special thanks で", text1: "とどめだ！")
        case 105:
            showBigMessage(text0: "エンディングが終わる……", text1: "")
        case 110:
            showBigMessage(text0: "お前の", text1: "勝ちだ……")
        case 115:
            showBigMessage(text0: "とどめを刺せ", text1: "")
        case 120:
            vsAd()
        default:
            break
        }

        switch stage {
        case 15:
            showBigMessage(text0: "まだまだスタッフはいるぞ……", text1: "")
        default:
            break
        }
        
    }
    

    
}
