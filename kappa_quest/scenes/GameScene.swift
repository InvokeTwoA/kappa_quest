// ゲーム画面
import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: BaseScene, SKPhysicsContactDelegate {

    // 各種モデル
    private var enemyModel : EnemyModel = EnemyModel()
    private var actionModel : ActionModel = ActionModel()
    private var specialAttackModel : SpecialAttackModel = SpecialAttackModel()
    private var skillModel : SkillModel = SkillModel()
    var map : Map = Map()
    var equipModel : EquipModel = EquipModel()
    var jobModel : JobModel = JobModel()

    // Node
    var kappa : KappaNode!   // かっぱ画像
    private var kappa_first_position_y : CGFloat!

    // その他変数
    var world_name = "defo"
    var gameOverFlag = false

    // Scene load 時に呼ばれる
    private var isSceneDidLoaded = false
    override func sceneDidLoad() {
        // 二重読み込みの防止
        if isSceneDidLoaded {
            return
        } else {
            isSceneDidLoaded = true
        }

        self.lastUpdateTime = 0
        self.physicsWorld.contactDelegate = self

        // データをセット
        enemyModel.readDataByPlist()
        jobModel.readDataByPlist()
        jobModel.loadParam()
        skillModel.readDataByPlist()
        equipModel.readDataByPlist()
        actionModel.setActionData(sceneWidth: self.size.width)
        createKappa()
        setHealVal()

        // 音楽関係の処理
        prepareBGM(fileName: Const.bgm_fantasy)
        prepareSoundEffect()
        playBGM()

        showMessage("冒険の始まりだ！", type: "start")
    }

    // 画面が読み込まれた時に呼ばれる
    override func didMove(to view: SKView) {
        map.readDataByPlist(world_name)
        map.loadParameterByUserDefault()
        createMap()
        gameData.setParameterByUserDefault()
        updateStatus()
        updateDistance()
    }

    // かっぱ画像にphysic属性を与える
    func createKappa(){
        kappa = childNode(withName: "//kappa") as! KappaNode
        kappa.setParameterByUserDefault()
        kappa.setPhysic()
        kappa_first_position_y = kappa.position.y
        setFirstPosition()
    }

    // 左からpos番目のx座標を返す
    func getPositionX(_ pos : Int) -> CGFloat {
        let position = CGFloat(pos)/7.0-1.0/2.0
        return self.size.width*position
    }

    // カッパを初期ポジションに設置
    func setFirstPosition(){
        map.myPosition = 1
        kappa?.position.x = getPositionX(1)
        kappa?.position.y = kappa_first_position_y
        kappa?.texture = SKTexture(imageNamed: "kappa")
    }

    func saveData(){
        kappa?.saveParam()
        gameData.saveParam()
        jobModel.saveParam()
        map.saveParam()
    }

    // 右へ移動
    func moveRight(){
        if map.isMoving {
            return
        }
        map.isMoving = true
        map.myPosition += 1
        kappa.walkRight()

        var action : SKAction!
        if gameData.equip == "shoes" {
            action = actionModel.speedMoveRight
        } else {
            action = actionModel.moveRight
        }
        kappa.run(action, completion: {() -> Void in
            if self.map.myPosition == Const.maxPosition {
                self.goNextMap()
            } else {
                self.updateButtonByPos()
            }
            self.map.isMoving = false
        })
    }

    // 次のマップに移動
    // ボス撃破時はもう次のマップへは進めない
    func goNextMap(){
        if map.isBoss {
            map.myPosition -= 1
            kappa.run(actionModel.moveBack2)
        } else {
            clearMap()
            resetMessage()
            setFirstPosition()
            map.goNextMap()
            saveData()
            createMap()
            updateDistance()
        }
    }

    func stageClear(){
        stopBGM()
        map.resetData()
        goClear()
    }

    // 左へ移動
    func moveLeft(){
        if map.isMoving {
            return
        }
        map.isMoving = true
        map.myPosition -= 1
        kappa.walkLeft()

        var action : SKAction!
        if gameData.equip == "shoes" {
            action = actionModel.speedMoveLeft
        } else {
            action = actionModel.moveLeft
        }
        kappa.run(action, completion: {() -> Void in
            self.map.isMoving = false
            self.updateButtonByPos()
        })
    }

    // 現在位置によってボタン文言を変更
    func updateButtonByPos(){
        let ButtonNode  = childNode(withName: "//ButtonNode") as! SKSpriteNode
        let ButtonLabel = childNode(withName: "//ButtonLabel") as! SKLabelNode

        if map.isTreasure() {
            ButtonNode.texture = SKTexture(imageNamed: "button_red")
            ButtonLabel.text = "装備する"

            let treasure_key = map.treasures[map.myPosition]
            let point = CGPoint(x: getPositionX(map.myPosition), y: kappa_first_position_y + 100.0)
            showBigMessage(text0: equipModel.getName(treasure_key), text1: equipModel.getExplain(treasure_key))
            
            if !ButtonNode.hasActions() {
                ButtonNode.run(actionModel.moveButton)
            }
        } else {
            ButtonNode.texture = SKTexture(imageNamed: "button_blue")
            ButtonLabel.text = "メニューを開く"
        }
    }

    // 攻撃
    func attack(pos: Int){
        kappa.attack()
        kappa.run(actionModel.attack!)
    }

    func attackCalculate(str : Int, type : String, enemy : EnemyNode){
        var damage = 0
        var def = 0
        let pos = enemy.pos
        if type == "physic" {
            def = enemyModel.enemies[pos].def
        } else {
            def = enemyModel.enemies[pos].pie
        }

        if BattleModel.isCritical(luc: Double(kappa.pie)) {
            //makeSpark(point: CGPoint(x: enemyModel.enemies[pos].position.x, y: enemyModel.enemies[pos].position.y), isCtirical: true)
            makeSpark(point: CGPoint(x: enemy.position.x, y: enemyModel.enemies[pos].position.y), isCtirical: true)
            damage = BattleModel.calculateCriticalDamage(str: str, def: def)
            playSoundEffect(type: 2)
        } else {
            makeSpark(point: CGPoint(x: enemy.position.x, y: enemyModel.enemies[pos].position.y))
            damage = BattleModel.calculateDamage(str: str, def: def)
            playSoundEffect(type: 3)
        }

        let point = CGPoint(x: enemy.position.x, y: enemy.position.y + 30)
        displayDamage(value: damage, point: point, color: UIColor.white)

        enemy.hp -= damage
        changeEnemyLifeBar(pos, per: enemy.hp_per())
        if enemy.hp <= 0 {
            beatEnemy(pos: pos)
        }
    }

    // 攻撃をされた
    func attacked(attack:Int, type: String, point: CGPoint){
        var damage = 1
        if type == "magic" {
            damage = BattleModel.calculateDamage(str: attack, def: kappa.pie)
        } else {
            damage = BattleModel.calculateDamage(str: attack, def: kappa.def)
        }
        playSoundEffect(type: 1)

        let pre_hp = kappa.hp
        kappa.hp -= damage

        if isKonjo(pre_hp) {
            kappa.hp = 1
            showMessage("カッパのど根性！", type: "skill")
        }
        if kappa.hp <= 0 {
            kappa.hp = 0
        }

        displayDamage(value: damage, point: CGPoint(x:point.x-30, y:point.y+30), color: UIColor.red, direction: "left")
        updateStatus()
        if kappa.hp == 0 {
            gameOver()
        }
    }

    func makeSpark(point : CGPoint, isCtirical : Bool = false){
        var particle = SparkEmitterNode.makeSpark()
        if isCtirical {
            particle = SparkEmitterNode.makeBlueSpark()
        }
        particle.position = point
        particle.run(actionModel.sparkFadeOut!)
        self.addChild(particle)
    }

    // ダメージを数字で表示
    func displayDamage(value: Int, point: CGPoint, color: UIColor, direction : String = "right"){
        let location = CGPoint(x: point.x, y: point.y + 30.0)
        let label = SKLabelNode(fontNamed: Const.damageFont)
        label.name = "damage_text"
        label.text = "\(value)"
        label.fontSize = Const.damageFontSize - 5
        label.position = location
        label.fontColor = color
        label.zPosition = 90
        label.alpha = 0.9
        self.addChild(label)

        let bg_label = SKLabelNode(fontNamed: Const.damageFont)
        bg_label.name = "bg_damage_text"
        bg_label.position = location
        bg_label.fontColor = .black
        bg_label.text = "\(value)"
        bg_label.fontSize = Const.damageFontSize
        bg_label.zPosition = 89
        self.addChild(bg_label)

        if direction == "left" {
            label.run(actionModel.displayDamaged!)
            bg_label.run(actionModel.displayDamaged!)
        } else if direction == "right" {
            label.run(actionModel.displayDamage!)
            bg_label.run(actionModel.displayDamage!)
        } else if direction == "up" {
            label.run(actionModel.displayHeal!)
            bg_label.run(actionModel.displayHeal!)
        }
    }

    func displayExp(value: Int, point: CGPoint){
        let label = SKLabelNode(fontNamed: Const.damageFont)
        label.name = "damage_text"
        label.text = "\(value) exp"
        label.fontSize = 24
        label.fontName = Const.pixelFont
        label.position = CGPoint(x: point.x, y: point.y + 30.0)
        label.fontColor = .black
        label.zPosition = 90
        label.alpha = 0.9
        self.addChild(label)
        label.run(actionModel.displayExp!)
    }

    // モンスター撃破処理
    func beatEnemy(pos: Int){
        let enemy = enemyModel.enemies[pos]
        enemy.hp = 0
        enemy.isDead = true
        getExp(enemyModel.enemies[pos].exp, point: enemy.position)

        removeEnemyLifeBar(pos)
        enemy.setBeatPhysic()
        map.positionData[pos] = "free"
        enemy.run(actionModel.displayExp!)

        if !map.treasureFlag && BattleModel.isTreasure(luc: Double(kappa.luc)) {
            map.treasureFlag = true
            createTreasure(pos: pos)
            map.positionData[pos] = "treasure"
        }

        if map.isBoss && pos == Const.maxPosition - 1 {
            showBigMessage(text0 : map.boss_text0, text1: map.boss_text1)
            _ = CommonUtil.setTimeout(delay: 6.0, block: { () -> Void in
                self.stageClear()
            })
        }
    }

    func getExp(_ get_exp: Int, point: CGPoint){
        var exp = get_exp
        if gameData.equip == "exp" {
            exp *= 2
        }
        displayExp(value: get_exp, point: CGPoint(x: point.x, y: point.y + Const.enemySize))
        updateExp(exp)
    }

    // 経験値更新
    func updateExp(_ getExp : Int){
        kappa.nextExp -= getExp
        if kappa.nextExp <= 0 {
            LvUp()
        }
        updateStatus()
    }

    func LvUp(){
        kappa.LvUp(jobModel)
        showMessage("LVがあがった", type: "lv")

        let HPUpLabel      = childNode(withName: "//HPUpLabel")  as! SKLabelNode
        let StrUpLabel     = childNode(withName: "//StrUpLabel") as! SKLabelNode
        let DefUpLabel     = childNode(withName: "//DefUpLabel") as! SKLabelNode
        let AgiUpLabel     = childNode(withName: "//AgiUpLabel") as! SKLabelNode
        let IntUpLabel     = childNode(withName: "//IntUpLabel") as! SKLabelNode
        let PieUpLabel     = childNode(withName: "//PieUpLabel") as! SKLabelNode
        let LucUpLabel     = childNode(withName: "//LucUpLabel") as! SKLabelNode

        if jobModel.hp != 0 {
            HPUpLabel.text = "+\(jobModel.hp)"
            HPUpLabel.run(actionModel.fadeInOut!)
        }
        if jobModel.str != 0 {
            StrUpLabel.text = "+\(jobModel.str)"
            StrUpLabel.run(actionModel.fadeInOut!)
        }
        if jobModel.def != 0 {
            DefUpLabel.text = "+\(jobModel.def)"
            DefUpLabel.run(actionModel.fadeInOut!)
        }
        if jobModel.str != 0 {
            AgiUpLabel.text = "+\(jobModel.agi)"
            AgiUpLabel.run(actionModel.fadeInOut!)
        }
        if jobModel.int != 0 {
            IntUpLabel.text = "+\(jobModel.int)"
            IntUpLabel.run(actionModel.fadeInOut!)
        }
        if jobModel.pie != 0 {
            PieUpLabel.text = "+\(jobModel.pie)"
            PieUpLabel.run(actionModel.fadeInOut!)
        }
        if jobModel.luc != 0 {
            LucUpLabel.text = "+\(jobModel.luc)"
            LucUpLabel.run(actionModel.fadeInOut!)
        }

        // スキル判定
        if jobModel.name == "priest" {
            heal_val = jobModel.lv
        }
        getSkill()
    }

    func getSkill(){
        if jobModel.name == "murabito" && jobModel.lv == 5 {
            gameData.getSkill(key: "konjo")
            showMessage("スキル習得", type: "skill")
        }
    }

    // タップ数アップ
    // 40タップごとに僧侶のアビリティを発動
    func tapCountUp(){
        let TapCountLabel  = childNode(withName: "//TapCountLabel") as! SKLabelNode

        gameData.tapCount += 1
        TapCountLabel.text = "\(gameData.tapCount)"
        if gameData.tapCount%Const.tapHealCount == 0 {
            healAbility()
        }
    }

    var heal_val = 0 // 回復量。毎回UserDefaultから読み込まないように変数で保持
    func healAbility(){
        if heal_val == 0 {
            return
        } else {
            kappa.hp += heal_val
            displayDamage(value: heal_val, point: kappa.position, color: .green, direction: "up")
            updateStatus()
        }
    }

    func setHealVal(){
        heal_val = JobModel.getLV("priest")
    }

    /***********************************************************************************/
    /******************************* スキル判定     ************************************/
    /***********************************************************************************/
    func isKonjo(_ pre_hp: Int) -> Bool {
        return gameData.konjoFlag && pre_hp >= 2 && kappa.hp <= 0 && CommonUtil.rnd(100) < kappa.luc
      }

    /***********************************************************************************/
    /******************************* ゲームオーバー ************************************/
    /***********************************************************************************/
    func gameOver(){
        if gameOverFlag == false {
            kappa.dead()
            kappa.run(actionModel.dead!)

            gameOverFlag = true
            stopBGM()
            _ = CommonUtil.setTimeout(delay: 3.0, block: { () -> Void in
                self.goGameOver()
            })
        }
    }

    func resetData(){
        kappa.hp = kappa.maxHp
        map.resetData()
        gameOverFlag = false

        clearMap()
        createMap()
        setFirstPosition()
        saveData()

        resetMessage()
        updateStatus()
        updateDistance()
    }

    /***********************************************************************************/
    /******************************** ライフバー  **************************************/
    /***********************************************************************************/
    func changeLifeBar(){
        let life_bar_yellow = childNode(withName: "//LifeBarYellow") as! SKSpriteNode
        let life_percentage = CGFloat(kappa.hp)/CGFloat(kappa.maxHp)
        life_bar_yellow.size.width = Const.lifeBarWidth*life_percentage
    }

    /***********************************************************************************/
    /******************************** 宝を描画  ****************************************/
    /***********************************************************************************/
    func createTreasure(pos : Int){
        let treasure = TreasureNode.makeTreasure()
        treasure.position.x = getPositionX(pos)
        treasure.position.y = kappa_first_position_y
        treasure.pos = pos
        map.treasures[pos] = treasure.item_name
        addChild(treasure)
        treasure.run(actionModel.highJump!)
    }

    func getTreasure(pos : Int){
        gameData.setEquip(key: map.treasures[pos])
        updateStatus()
        removeTreasure(pos: pos)
    }

    func removeTreasure(pos : Int){
        map.positionData[pos] = "free"
        map.treasures[pos] = ""

        let treasure = childNode(withName: "//treasure") as! TreasureNode
        if treasure.pos == pos {
            treasure.removeFromParent()
        }
    }

    /***********************************************************************************/
    /********************************** 敵を描画  ****************************************/
    /***********************************************************************************/
    func createEnemy(pos: Int) -> Bool {
        if map.enemies.count == 0 {
            return false
        }

        var enemy : EnemyNode!
        if map.isRandom {
            enemy = enemyModel.getRnadomEnemy(map.enemies, lv : map.lv)
        } else {
            let num = pos-3
            if map.enemies.count > num {
                enemy = enemyModel.getEnemy(enemy_name: map.enemies[num], lv: map.lv)
            } else {
                return false
            }
        }

        if map.isBoss && pos == Const.maxPosition - 1 {
            enemy.bossPowerUp()
        }

        enemy.pos = pos
        enemy.position.x = getPositionX(pos)
        enemy.position.y = kappa_first_position_y
        addChild(enemy)

        createEnemyLv(enemy.lv, position: CGPoint(x: enemy.position.x, y: enemy.position.y + Const.enemySize + 20))
        createEnemyLifeBar(pos: pos, x: (enemy.position.x - Const.enemySize/2), y: enemy.position.y - 30)
        enemyModel.enemies[pos] = enemy
        return true
    }

    func createEnemyLv(_ val : Int, position: CGPoint){
        let lv = SKLabelNode(text: "LV\(val)")
        lv.fontName = Const.pixelFont
        lv.fontSize = 24
        lv.fontColor = .black
        lv.position = position
        addChild(lv)
        lv.run(actionModel.fadeOutQuickly!)
    }

    func createEnemyLifeBar(pos: Int, x: CGFloat, y: CGFloat){
        let lifeBarBackGround = SKSpriteNode(color: .black, size: CGSize(width: 90, height: 20))
        lifeBarBackGround.position = CGPoint(x: x, y: y)
        lifeBarBackGround.zPosition = 98
        lifeBarBackGround.name = "back_life_bar\(pos)"
        lifeBarBackGround.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        addChild(lifeBarBackGround)

        let lifeBar = SKSpriteNode(color: .yellow, size: CGSize(width: 90, height: 20))
        lifeBar.position = CGPoint(x: x, y: y)
        lifeBar.zPosition = 99
        lifeBar.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        lifeBar.name = "life_bar\(pos)"
        addChild(lifeBar)
    }

    func changeEnemyLifeBar(_ pos : Int, per : Double){
        let bar = childNode(withName: "//life_bar\(pos)") as? SKSpriteNode
        bar?.size.width = CGFloat(per)
    }

    func removeEnemyLifeBar(_ pos : Int){
        let bar = self.childNode(withName: "//life_bar\(pos)") as? SKSpriteNode
        bar?.removeFromParent()

        let barBackground = self.childNode(withName: "//back_life_bar\(pos)") as? SKSpriteNode
        barBackground?.removeFromParent()
    }

    /***********************************************************************************/
    /******************************** マップ更新  **************************************/
    /***********************************************************************************/

    // マップ作成
    func createMap(){
        map.updatePositionData()

        for (index, positionData) in map.positionData.enumerated() {
            switch positionData {
            case "enemy":
                if !createEnemy(pos: index) {
                    map.positionData[index] = "free"
                }
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
            prepareBGM(fileName: Const.bgm_last_battle)
            playBGM()
        }
    }

    func changeBackGround(){
        let background = self.childNode(withName: "//BackgroundNode") as! SKSpriteNode
        background.texture = SKTexture(imageNamed: map.background)
    }

    // マップの情報を削除
    func clearMap(){
        let rm_nodes = [
            "enemy",
            "fire",
            "damage_text",
            "bg_damage_text",
            "treasure",
            "displayText"
        ]
        enumerateChildNodes(withName: "*") { node, _ in
            if node.name != nil {
                if rm_nodes.contains(node.name!) {
                    node.removeFromParent()
                }
            }
        }
        enemyModel.resetEnemies()

        for i in 0 ..< Const.maxPosition {
            removeEnemyLifeBar(i)
        }

        let bigMessageNode = childNode(withName: "//BigMessageNode") as! SKSpriteNode
        bigMessageNode.isHidden = true
        bigMessageNode.removeAllActions()
    }

    /***********************************************************************************/
    /********************************** 表示更新 *****************************************/
    /***********************************************************************************/

    // ステータス更新
    func updateStatus(){
        // ステータス表示
        if kappa!.hp >= kappa!.maxHp {
            kappa!.hp = kappa!.maxHp
        }

        let MAXHPLabel     = childNode(withName: "//MAXHPLabel")  as! SKLabelNode
        let HPLabel        = childNode(withName: "//HPLabel")     as! SKLabelNode
        let LVLabel        = childNode(withName: "//LVLabel")     as! SKLabelNode
        let StrLabel       = childNode(withName: "//StrLabel")    as! SKLabelNode
        let DefLabel       = childNode(withName: "//DefLabel")    as! SKLabelNode
        let AgiLabel       = childNode(withName: "//AgiLabel")    as! SKLabelNode
        let IntLabel       = childNode(withName: "//IntLabel")    as! SKLabelNode
        let PieLabel       = childNode(withName: "//PieLabel")    as! SKLabelNode
        let LucLabel       = childNode(withName: "//LucLabel")    as! SKLabelNode
        let ExpLabel       = childNode(withName: "//ExpLabel")    as! SKLabelNode

        MAXHPLabel.text = "HP  \(String(describing: kappa.maxHp))"
        HPLabel.text  = "\(String(describing: kappa.hp))"
        LVLabel.text  = "LV    \(String(describing: kappa.lv))"
        StrLabel.text = "筋力  \(String(describing: kappa.str))"
        DefLabel.text = "体力  \(String(describing: kappa.def))"
        AgiLabel.text = "敏捷  \(String(describing: kappa.agi))"
        IntLabel.text = "知恵  \(String(describing: kappa.int))"
        PieLabel.text = "精神  \(String(describing: kappa.pie))"
        LucLabel.text = "幸運  \(String(describing: kappa.luc))"
        ExpLabel.text = "次のレベルまで　　\(String(describing: kappa.nextExp))"

        // 職業情報
        let JobLVLabel     = childNode(withName: "//JobLVLabel") as! SKLabelNode
        let JobNameLabel   = childNode(withName: "//JobNameLabel") as! SKLabelNode

        JobNameLabel.text = jobModel.displayName
        JobLVLabel.text = "LV  \(jobModel.lv)"

        // 装備情報
        let equipLabel  = childNode(withName: "//EquipLabel") as! SKLabelNode
        equipLabel.text = equipModel.getName(gameData.equip)

        // タップ情報
        let TapCountLabel  = childNode(withName: "//TapCountLabel") as! SKLabelNode
        TapCountLabel.text = "\(gameData.tapCount)"

        changeLifeBar()
    }

    // 距離情報の更新
    func updateDistance(){
        let distanceLabel    = childNode(withName: "//DistanceLabel") as! SKLabelNode
        let maxDistanceLabel = childNode(withName: "//MaxDistanceCountLabel") as! SKLabelNode

        distanceLabel.text = "\(map.distance)km"
        maxDistanceLabel.text = "\(map.maxDistance)"
    }

    /***********************************************************************************/
    /******************************* メッセージ処理 ************************************/
    /***********************************************************************************/
    // メッセージ表示
    var messages = [[String]]()
    var isShowingMessage = false

    func showMessage(_ text : String, type : String){
        messages.append([text, type])
    }

    func displayMessage(){
        isShowingMessage = true
        let MessageLabel   = childNode(withName: "//MessageLabel") as! SKLabelNode
        let MessageNode    = childNode(withName: "//MessageNode") as! SKShapeNode

        MessageLabel.text = messages[0][0]
        MessageNode.position.x += 100

        switch messages[0][1] {
        case "start":
            MessageLabel.fontColor = UIColor.black
            MessageNode.fillColor = UIColor.yellow
        case "lv":
            MessageLabel.fontColor = UIColor.white
            MessageNode.fillColor = UIColor.black
        case "dead":
            MessageLabel.fontColor = UIColor.black
            MessageNode.fillColor = UIColor.red
        case "skill":
            MessageLabel.fontColor = UIColor.white
            MessageNode.fillColor = UIColor.blue
        default:
            print("unknown message type")
        }

        messages.remove(at: 0)
        MessageNode.run(actionModel.displayMessage!, completion: {() -> Void in
            self.isShowingMessage = false
        })
    }

    // 巨大メッセージ表示
    var bigMessages = [[String]]()
    func showBigMessage(text0 : String, text1 : String){
        bigMessages.append([text0, text1])
    }

    var isShowingBigMessage = false
    func displayBigMessage(){
        isShowingBigMessage = true
        let bigMessageNode     = childNode(withName: "//BigMessageNode") as! SKSpriteNode
        let bigMessageLabel0   = childNode(withName: "//BigMessageLabel0") as! SKLabelNode
        let bigMessageLabel1   = childNode(withName: "//BigMessageLabel1") as! SKLabelNode

        bigMessageNode.isHidden = false
        bigMessageLabel0.text = bigMessages[0][0]
        bigMessageLabel1.text = bigMessages[0][1]

        bigMessages.remove(at: 0)
        bigMessageNode.run(actionModel.displayBigMessage!, completion: {() -> Void in
            self.isShowingBigMessage = false
        })
    }

    func displayText(_ text : String, position: CGPoint){
        let item = SKLabelNode(text: text)
        item.fontName = Const.pixelFont
        item.fontSize = 24
        item.fontColor = .black
        item.position = position
        item.zPosition = 50
        item.name = "displayText"
        addChild(item)

        item.run(actionModel.fadeOutEternal!)
    }

    func execMessages(){
        if !isShowingMessage && messages.count > 0 {
            displayMessage()
        }
        if !isShowingBigMessage && bigMessages.count > 0 {
            displayBigMessage()
        }
    }

    func resetMessage(){
        bigMessages = []
        messages = []
        isShowingMessage = false
        isShowingBigMessage = false
    }

    /***********************************************************************************/
    /********************************* 画面遷移 ****************************************/
    /***********************************************************************************/
    // メニュー画面へ遷移
    func goMenu(){
        let scene = MenuScene(fileNamed: "MenuScene")!
        scene.size = self.scene!.size
        scene.scaleMode = SKSceneScaleMode.aspectFill
        scene.backScene = self.scene as! GameScene
        self.view!.presentScene(scene, transition: .fade(withDuration: Const.transitionInterval))
    }

    // ゲームオーバー画面へ
    func goGameOver(){
        let scene = GameOverScene(fileNamed: "GameOverScene")!
        scene.size = self.scene!.size
        scene.scaleMode = SKSceneScaleMode.aspectFill
        scene.backScene = self.scene as! GameScene
        self.view!.presentScene(scene, transition: .fade(with: .white, duration: Const.gameOverInterval))
    }

    func goClear(){
        if gameOverFlag == true {
            return
        }
        let scene = GameClearScene(fileNamed: "GameClearScene")!
        scene.size = self.scene!.size
        scene.scaleMode = SKSceneScaleMode.aspectFill
        self.view!.presentScene(scene, transition: .doorsCloseHorizontal(withDuration: Const.gameOverInterval))
    }

    /***********************************************************************************/
    /********************************** specialAttack **********************************/
    /***********************************************************************************/
    // スーパー頭突き
    func specialAttackHead(){
        specialAttackModel.execHead()

        kappa.xScale = 1
        kappa.zRotation = CGFloat(-90.0  / 180.0 * .pi)

        let pos = map.nearEnemyPosition()
        let normalAttack = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 50, duration: 0),
            SKAction.moveTo(x: getPositionX(pos), duration: Const.headAttackSpeed),
            SKAction.moveTo(x: getPositionX(pos - 1), duration: Const.headAttackSpeed),
            SKAction.moveBy(x: 0, y: -50, duration: 0),
        ])
        kappa.run(normalAttack, completion: {() -> Void in
            self.kappa.zRotation = 0
            self.specialAttackModel.finishAttack()
        })
        map.myPosition = pos - 1
    }

    // 昇竜拳
    func specialAttackUpper(){
        specialAttackModel.execUpper()

        kappa.xScale = 1
        kappa.texture = SKTexture(imageNamed: "kappa_upper")
        let upper = SKAction.sequence([
            SKAction.moveBy(x: 60, y: 250, duration: Const.headAttackSpeed/2),
            SKAction.moveBy(x: 0, y: -250, duration: Const.headAttackSpeed/2),
            SKAction.moveBy(x: -60, y: 0,  duration: Const.headAttackSpeed/2),
        ])

        kappa.run(upper, completion: {() -> Void in
            self.specialAttackModel.finishAttack()
        })
    }

    func updateSpecialLabel(){
        let headLabel   = childNode(withName: "//SpecialHeadLabel") as! SKLabelNode
        let upperLabel  = childNode(withName: "//SpecialUpperLabel") as! SKLabelNode

        headLabel.text      = specialAttackModel.displayHeadCount()
        upperLabel.text     = specialAttackModel.displayUpperCount()
    }

    func execSpecialAttack(){
        switch specialAttackModel.specialName() {
        case "head":
            specialAttackHead()
        case "upper":
            specialAttackUpper()
        default:
            break
        }
    }

    /***********************************************************************************/
    /********************************** touch ******************************************/
    /***********************************************************************************/
    func touchDown(atPoint pos : CGPoint) {
        if gameOverFlag || specialAttackModel.is_attacking {
            return
        }
        if pos.x >= 0 {
            specialAttackModel.countUpHeadAttack(direction: "right")
            specialAttackModel.countUpUpperAttack(direction: "right")
            if specialAttackModel.isSpecial() {
                updateSpecialLabel()
                execSpecialAttack()
                return
            }

            if map.canMoveRight() {
                moveRight()
            } else {
                if gameData.equip == "head" {
                    specialAttackHead()
                } else {
                    attack(pos: map.myPosition+1)
                }
            }
        } else {
            specialAttackModel.countUpHeadAttack(direction: "left")
            specialAttackModel.countUpUpperAttack(direction: "left")
            if specialAttackModel.isSpecial() {
                updateSpecialLabel()
                execSpecialAttack()
                return
            }

            if map.canMoveLeft() {
                moveLeft()
            } else {
                kappa!.run(actionModel.moveBack!)
            }
        }
        updateSpecialLabel()
    }

    // 押し続け地得る時の処理
    func touchMoved(toPoint pos : CGPoint) {
    }

    func touchUp(atPoint pos : CGPoint) {
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tapCountUp()

        if gameOverFlag || specialAttackModel.is_attacking {
            return
        }
        if map.myPosition+1 > Const.maxPosition {
            return
        }
        for t in touches {
            let positionInScene = t.location(in: self)
            let tapNode = self.atPoint(positionInScene)
            if tapNode.name == "ButtonNode" || tapNode.name == "ButtonLabel" {
                if map.isTreasure() {
                    getTreasure(pos : map.myPosition)
                } else {
                    goMenu()
                }
            } else if tapNode.name == "KappaInfoLabel" || tapNode.name == "KappaInfoNode" {
                displayAlert("ステータス", message: JobModel.allSkillExplain(skillModel, kappa: kappa!, gameData: gameData), okString: "閉じる")
            } else {
                self.touchDown(atPoint: positionInScene)
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }

    /***********************************************************************************/
    /********************************** 衝突判定 ****************************************/
    /***********************************************************************************/
    func didBegin(_ contact: SKPhysicsContact) {
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

        // 敵との衝突判定
        if (firstBody.categoryBitMask & Const.kappaCategory != 0 ) {
            if secondBody.categoryBitMask & Const.fireCategory != 0 {
                let fire = secondBody.node as! FireEmitterNode
                attacked(attack: fire.damage, type: "magick", point: (firstBody.node?.position)!)
                makeSpark(point: (secondBody.node?.position)!)
                secondBody.node?.removeFromParent()
            } else if secondBody.categoryBitMask & Const.enemyCategory != 0 {
                let enemy = secondBody.node as! EnemyNode
                if enemy.isDead {
                    return
                }
                // 敵の攻撃
                if enemy.isAttacking {
                    attacked(attack: enemy.str, type: "physic", point: (firstBody.node?.position)!)
                    makeSpark(point: (firstBody.node?.position)!)
                }
                // カッパの攻撃
                if specialAttackModel.is_attacking {
                    if specialAttackModel.mode == "head" {
                        attackCalculate(str: (kappa?.str)! + (kappa?.int)!, type: "magick", enemy: enemy)
                    } else if specialAttackModel.mode == "upper" {
                        attackCalculate(str: (kappa?.str)! + (kappa?.int)!, type: "magick", enemy: enemy)
                    }
                } else if kappa.hasActions() {
                    attackCalculate(str: kappa.str, type: "physic", enemy: enemy)
                }
            }
        }
    }

    /***********************************************************************************/
    /********************************* update ******************************************/
    /***********************************************************************************/
    private var lastUpdateTime : TimeInterval = 0
    private var doubleTimer = 0.0 // 経過時間（小数点単位で厳密）

    override func update(_ currentTime: TimeInterval) {
        execMessages()
        if gameOverFlag {
            return
        }

        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }

        let dt = currentTime - self.lastUpdateTime
        self.lastUpdateTime = currentTime

        doubleTimer += dt
        if doubleTimer > 1.0 {
            doubleTimer = 0.0
        } else {
            return
        }

        for enemy in enemyModel.enemies {
            if enemy.isDead {
                continue
            }
            enemy.timerUp()
            if enemy.isAttack() {
                enemy.isAttacking = true
                enemy.run(actionModel.enemyAttack(range: CGFloat(enemy.range)))
                enemy.attackTimerReset()
                _ = CommonUtil.setTimeout(delay: 2*Const.enemyJump, block: { () -> Void in
                    enemy.isAttacking = false
                })
            } else if enemy.isFire() {
                enemy.run(actionModel.enemyJump!)
                enemy.makeFire()
                enemy.fire.position = CGPoint(x: enemy.position.x, y: enemy.position.y + 40 )
                self.addChild(enemy.fire)
                enemy.fire.shot()
                enemy.fireTimerReset()
            } else if enemy.jumpTimer%4 == 0 {
                enemy.run(actionModel.enemyMiniJump!)
                enemy.jumpTimerReset()
            }
        }
    }
}
