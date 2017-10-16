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
        "IconNotKappaUpper",
        "IconKappaUpper",
        "IconNotKappaHado",
        "IconKappaHado",
        "IconNotKappaTornado",
        "IconKappaTornado",
    ]
    private let destroy_nodes2 = [
        "StatusLabelNode",
        "ButtonNode",
    ]
    private let destroy_nodes3 = [
        "underground",
        "BackGround",
        ]
    private let destroy_nodes4 = [
        "JobBox",
        "HP",
        "HPLabel",
        "NameBox",
    ]
    private let destroy_nodes5 = [
        "BackgroundNode"
    ]

    private let boss_kappa = EnemyNode(imageNamed: "dark_kappa")
    func bossGenerate(){
        boss_kappa.position.x = getPositionX(Const.maxPosition - 1)
        boss_kappa.position.y = kappa.position.y
        boss_kappa.zPosition = 99
        boss_kappa.size = kappa.size
        boss_kappa.anchorPoint = CGPoint(x: 0.5, y: 0)     // 中央下がアンカーポイント
        addChild(boss_kappa)
    }
    
    override func setFirstPosition(){
        map.myPosition = 1
        kappa.position.x = getPositionX(1)
        kappa.texture = SKTexture(imageNamed: "kappa")
    }
    
    /***********************************************************************************/
    /******************************** マップ更新  **************************************/
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
    private let move_pattern  = ["fast", "slow", "back", "so_quick", "so_slow"]
    
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
            target_array0 = ["ドッ", "ト絵", "制作", "ツ", "ー", "ル"]
            target_array1 = ["d", "o", "t", "p", "i", "ct"]
        case 50:
            target_array0 = ["テ", "ス", "タ", "ー", "", ""]
            target_array1 = ["", "k", "a", "p", "p", "a"]
        case 55:
            target_array0 = ["s", "p", "e", "c", "i", "al"]
            target_array1 = ["t", "h", "a", "n", "k", "s"]
        case 60:
            target_array0 = ["t", "a", "k", "a", "sh", "i"]
            target_array1 = ["h", "a", "g", "u", "r", "a"]
        case 65:
            target_array0 = ["n", "a", "o", "f", "u", "mi"]
            target_array1 = ["h", "a", "t", "t", "o", "ri"]
        case 70:
            target_array0 = ["r", "y", "o", "", "", ""]
            target_array1 = ["m", "u", "r", "a", "ka", "mi"]
        case 75:
            target_array0 = ["(", "k", "i", "n", "g", ")"]
            target_array1 = ["", "", "", "", "", ""]
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
    override func touchDown(atPoint pos : CGPoint) {
        if pos.x >= 0 {
            if map.canMoveRight() {
                moveRight()
            } else if map.isRightEnemy() {
                attack(pos: map.myPosition+1)
            } else {
                kappa.run(actionModel.moveBack2)
            }
        } else {
            if map.canMoveLeft() {
                moveLeft()
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
        case 1,5,10,15,20,25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 270:
            endingAttack(stage)
        default:
            break
        }
    }
    

    
}
