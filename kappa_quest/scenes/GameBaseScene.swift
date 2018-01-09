// ゲーム画面
import SpriteKit
import GameplayKit
import AVFoundation

class GameBaseScene: BaseScene, SKPhysicsContactDelegate {
    
    // internal要素
    internal var actionModel : ActionModel = ActionModel()
    internal var kappa_first_position_y : CGFloat!
    internal var kappa : KappaNode!   // かっぱ画像
    internal var map : Map = Map()
    internal var enemyModel : EnemyModel = EnemyModel()
    
    var world_name = "tutorial"
    
    // Scene load 時に呼ばれる
    internal var isSceneDidLoaded = false
    override func sceneDidLoad() {
        if isSceneDidLoaded {
            return
        }
        isSceneDidLoaded = true
        lastUpdateTime = 0

        setBaseVariable()  // 章による変数設定
        hideEachNode()
        setMusic()
        setWorld()  // 地面に物理判定を設定
    }
    
    // 各要素を非表示にする
    func hideEachNode(){
        hideLongMessage()
        hideSkillBox()
        hideMagicCircuit()
    }
    
    func setMusic(){
        prepareSoundEffect()
        playBGM()
    }
    
    
    // 章に応じて変数を上書き
    func setBaseVariable(){
    }    
    
    // 画面が読み込まれた時に呼ばれる
    private var isSceneDidMoved = false
    override func didMove(to view: SKView) {
        updateStatus()
        updateName()
        
        updateDistance()
        
        playBGM()
        
        if isSceneDidMoved {
            return
        }
        map.world = world_name
        map.readDataByPlist()
        createMap()
        
        isSceneDidMoved = true
        gameData.setParameterByUserDefault()
        
        showMessage("危険LV \(map.lv)", type: "start")
    }
    
    func setWorld(){
        physicsWorld.contactDelegate = self
        let underground = childNode(withName: "//underground") as! SKSpriteNode
        underground.physicsBody = SKPhysicsBody(rectangleOf: underground.size)
        WorldNode.setWorldPhysic(underground.physicsBody!)
    }
    
    // かっぱ画像にphysic属性を与える
    func createKappa(){
        kappa = childNode(withName: "//kappa") as! KappaNode
        createKappaByChapter()
        kappa.setPhysic()
        kappa_first_position_y = kappa.position.y
        setFirstPosition()
        if map.distance == 0.0 {
            kappa.heal()
        }
    }
    
    // カッパ作成時の章ごとの処理
    func createKappaByChapter(){
        kappa.setParameter(chapter: chapter)
        kappa.setNextExp(jobModel)
        if jobModel.name == "knight" {
            kappa.physic_type = "noppo"
        }
    }
    
    // カッパを初期ポジションに設置
    func setFirstPosition(){
        map.myPosition = 1
        kappa.position.x = getPositionX(1)
        kappa.position.y = kappa_first_position_y
        kappa.walkRight()
        kappa.removeAllActions()
    }
    
    func saveData(){
        kappa.saveParam(chapter: chapter)
        gameData.saveParam()
        jobModel.saveParam(chapter)
    }
    
    // 右へ移動
    func moveRight(){
        if map.isMoving {
            return
        }
        map.isMoving = true
        map.myPosition += 1
        kappa.walkRight()
        let action = getMoveActionRight()
        kappa.run(action, completion: {() -> Void in
            if self.map.myPosition == Const.maxPosition {
                self.goNextMap()
            }
            self.map.isMoving = false
        })
    }
    
    func getMoveActionRight() -> SKAction {
        if jobModel.isHighSpeed() {
            return actionModel.speedMoveRight
        } else if jobModel.name == "assassin" {
            return actionModel.speedMaxMoveRight
        } else {
            return actionModel.moveRight
        }
    }
    
    // 次のマップに移動
    // ボス撃破時はもう次のマップへは進めない
    func goNextMap(){
        clearMap()
        resetMessage()
        setFirstPosition()
        map.goNextMap()
        saveData()
        createMap()
        updateDistance()
        
        goMapByChapter()
    }
    
    // それぞれの章ごとのマップ移動時の処理
    func goMapByChapter(){
    }
    
    func stageClear(){
        map.resetData()
        kappa.heal()
        saveData()
        goCutin("end")
    }
    
    // 左へ移動
    func moveLeft(){
        if map.isMoving {
            return
        }
        map.isMoving = true
        map.myPosition -= 1
        kappa.walkLeft()
        let action = getMoveActionLeft()
        kappa.run(action, completion: {() -> Void in
            self.map.isMoving = false
        })
    }
    
    func getMoveActionLeft() -> SKAction {
        if jobModel.isHighSpeed() {
            return actionModel.speedMoveLeft
        } else if jobModel.name == "assassin" {
            return actionModel.speedMaxMoveLeft
        } else {
            return actionModel.moveLeft
        }
    }
    
    // 攻撃
    func attack(){
        kappa.attack()
        kappa.run(actionModel.attack!)
    }
    
    func attackCalculate(str : Int, type : String, enemy : EnemyNode){
        var damage = 0
        var def = 0
        let pos = enemy.pos
        if type == "physic" {
            def = enemy.def
        } else if type == "beauty" {
            def = 0
        } else {
            def = enemy.pie
        }
        
        var luck = kappa.luc
        if jobModel.name == "ninja" {
            luck *= 2
        }
        
        if BattleModel.isCritical(luc: Double(luck)) {
            for _ in 0...2 {
                makeSpark(point: CGPoint(x: enemy.position.x, y: enemyModel.enemies[pos].position.y), isCtirical: true)
            }
            damage = BattleModel.calculateCriticalDamage(str: str, def: def)
            playSoundEffect(type: 2)
        } else {
            for _ in 0...2 {
                makeSpark(point: CGPoint(x: enemy.position.x, y: enemyModel.enemies[pos].position.y))
            }
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
    func attacked(attack:Int, point: CGPoint){
        let damage = BattleModel.calculateDamage(str: attack, def: 0)
        playSoundEffect(type: 1)
        
        kappa.hp -= damage
        kappaKonjo()
        if kappa.hp <= 0 {
            kappa.hp = 0
        }
        
        displayDamage(value: damage, point: CGPoint(x:point.x-30, y:point.y+30), color: UIColor.red, direction: "left")
        updateStatus()
        if kappa.hp == 0 {
            gameOver()
        }
    }
    
    // カッパ根性が発動する場合の処理
    func kappaKonjo(){
    }
    
    func heal(_ heal_val : Int){
        if heal_val <= 0 || kappa.hp == kappa.maxHp {
            return
        }
        kappa.hp += heal_val
        displayDamage(value: heal_val, point: kappa.position, color: .green, direction: "up")
        updateStatus()
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
    
    func displayExp(_ value: Int){
        let ExpUpLabel = childNode(withName: "//ExpUpLabel") as! SKLabelNode
        ExpUpLabel.text = "+\(value)"
        ExpUpLabel.run(actionModel.fadeInOut!)
    }
    
    // モンスター撃破処理
    internal var beat_boss_flag = false
    func beatEnemy(pos: Int){
        let enemy = enemyModel.enemies[pos]
        enemy.hp = 0
        enemy.isDead = true
        let exp = map.lv + CommonUtil.minimumRnd(CommonUtil.minimumRnd(kappa.luc))
        updateExp(exp)
        
        removeEnemyLifeBar(pos)
        map.positionData[pos] = "free"
        
        if enemy.isZombi != "" && jobModel.name != "necro" {
            enemy.run(actionModel.enemyChange!, completion: {() -> Void in
                self.createGhost(position: enemy.position, enemy_name: enemy.isZombi, pos: pos)
                enemy.run(self.actionModel.displayExp!)
                enemy.removeFromParent()
            })
        } else {
            enemy.setBeatPhysic()
        }
        
        if map.isBoss && pos == Const.maxPosition - 1 {
            beatBoss()
        }
        beatByChapter()
    }
    
    // モンスター撃破時、章ごとの処理
    func beatByChapter(){
    }
    
    func beatBoss(){
        if beat_boss_flag {
            return
        }
        beat_boss_flag = true
        _ = CommonUtil.setTimeout(delay: 0.2, block: { () -> Void in
            self.stageClear()
        })
    }
    
    // 経験値更新
    func updateExp(_ getExp : Int){
        if jobModel.name == "arakure" {
            return
        }
        
        kappa.exp += getExp
        if kappa.nextExp <= kappa.exp {
            LvUp()
        }
        displayExp(getExp)
        displayExpLabel()
        changeExpBar()
        updateStatus()
    }
    
    // 経験値を表示
    func displayExpLabel(){
        let ExpLabel       = childNode(withName: "//ExpLabel")    as! SKLabelNode
        let exp = CommonUtil.valueMin1(kappa.nextExp - kappa.exp)
        ExpLabel.text = "次のレベルまで　　\(String(describing: exp))"
    }
    
    func LvUp(){
    }
    
    func isGetSkill() -> Bool {
        return (jobModel.name == "murabito" && jobModel.lv == 5) || (jobModel.name == "archer" && jobModel.lv == 10) || (jobModel.name == "wizard" && jobModel.lv == 10 || (jobModel.name == "fighter" && jobModel.lv == 10) || (jobModel.name == "gundom" && jobModel.lv == 10) )
    }
    
    
    // タップ数アップ
    // 40タップごとに僧侶のアビリティを発動
    func tapCountUp(){
        gameData.tapCount += 1
        let TapCountLabel  = childNode(withName: "//TapCountLabel") as! SKLabelNode
        TapCountLabel.text = "\(gameData.tapCount)"
        
        tapCountUpByChapter()
    }
    
    // 章ごとのタップ時の操作
    func tapCountUpByChapter(){
    }
    
    /***********************************************************************************/
    /******************************* ゲームオーバー ************************************/
    /***********************************************************************************/
    internal var gameOverFlag = false
    func gameOver(){
        if !gameOverFlag || !beat_boss_flag {
            kappa.dead()
            kappa.run(actionModel.dead!)
            
            gameOverFlag = true
            stopBGM()
            _ = CommonUtil.setTimeout(delay: 3.0, block: { () -> Void in
                self.goGameOver()
            })
        }
    }
    
    /***********************************************************************************/
    /******************************** ライフバー  **************************************/
    /***********************************************************************************/
    func changeLifeBar(){
        let life_bar_yellow = childNode(withName: "//LifeBarYellow") as! SKSpriteNode
        let life_percentage = CGFloat(kappa.hp)/CGFloat(kappa.maxHp)
        life_bar_yellow.size.width = Const.lifeBarWidth*life_percentage
    }
    
    func changeExpBar(){
        let ExpBar     = childNode(withName: "//ExpBar") as! SKSpriteNode
        var exp_percentage = CGFloat(kappa.exp)/CGFloat(kappa.nextExp)
        if exp_percentage > 1.0 {
            exp_percentage = 1.0
        }
        ExpBar.size.width = Const.expBarWidth*exp_percentage
    }
    
    /***********************************************************************************/
    /******************************** ターゲットマークを描画  ******************************/
    /***********************************************************************************/
    func createThunder(pos : Int, damage: Int){
        let target = SKSpriteNode(imageNamed: "target")
        target.position.x = getPositionX(pos)
        target.position.y = kappa_first_position_y
        target.anchorPoint = CGPoint(x: 0.5, y: 0)     // 中央下がアンカーポイント
        target.zPosition = 99
        addChild(target)
        
        target.run(SKAction.fadeOut(withDuration: 1.5), completion: {() -> Void in
            let thunder = ThunderEmitterNode.makeThunder()
            thunder.position.x = self.getPositionX(pos)
            thunder.position.y = 1000
            thunder.damage = damage
            self.addChild(thunder)
        })
    }
    
    func createArrow(pos : Int, damage: Int){
        let target = SKSpriteNode(imageNamed: "target")
        target.position.x = getPositionX(pos)
        target.position.y = kappa_first_position_y
        target.anchorPoint = CGPoint(x: 0.5, y: 0)     // 中央下がアンカーポイント
        target.zPosition = 99
        addChild(target)
        
        target.run(SKAction.fadeOut(withDuration: 1.5), completion: {() -> Void in
            let thunder = ThunderEmitterNode.makeArrow()
            thunder.position.x = self.getPositionX(pos)
            thunder.position.y = 1000
            thunder.damage = damage
            self.addChild(thunder)
        })
    }
    
    func createLazer(pos : Int, damage: Int){
        let target = SKSpriteNode(imageNamed: "target")
        target.position.x = getPositionX(pos)
        target.position.y = kappa_first_position_y
        target.anchorPoint = CGPoint(x: 0.5, y: 0)     // 中央下がアンカーポイント
        target.zPosition = 99
        addChild(target)
        
        target.run(SKAction.fadeOut(withDuration: 1.5), completion: {() -> Void in
            let dark = ThunderEmitterNode.makeDark()
            dark.position.x = self.getPositionX(pos)
            dark.position.y = self.kappa_first_position_y
            dark.damage = damage
            self.addChild(dark)
        })
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
                if map.enemies[num] != "" {
                    enemy = enemyModel.getEnemy(enemy_name: map.enemies[num])
                } else {
                    return false
                }
            } else {
                return false
            }
        }
        
        if chapter == 1 && map.isBoss && pos == Const.maxPosition - 1 {
            enemy.bossPowerUp()
        }
        
        enemy.pos = pos
        enemy.position.x = getPositionX(pos)
        if enemy.canFly || enemy.isGhost {
            enemy.position.y = kappa_first_position_y + Const.enemyFlyHeight
        } else {
            enemy.position.y = kappa_first_position_y
        }
        enemy.setPhysic()
        if enemy.isGhost || enemy.isMovingFree {
            map.positionData[pos] = "free"
            enemy.ghostMove()
        }
        addChild(enemy)
        createEnemyLifeBar(pos: pos, x: (enemy.position.x - Const.enemySize/2), y: enemy.position.y - 30)
        enemyModel.enemies[pos] = enemy

        if chapter == 1 {
            enemy.diff_agi = CommonUtil.valueMin1(enemy.agi - kappa.agi)
        } else if chapter == 2 {
            enemy.diff_agi = 10
        }
        
        if world_name == "dancer" {
            enemy.str = 999999999
            enemy.int = 999999999
        }
        return true
    }
    
    
    func createGhost(position : CGPoint, enemy_name : String, pos: Int){
        let enemy = enemyModel.getEnemy(enemy_name: enemy_name)
        enemy.position = position
        enemy.pos = pos
        enemy.setPhysic()
        if enemy.isGhost || enemy.isMovingFree {
            enemy.ghostMove()
        }
        addChild(enemy)
        enemyModel.enemies[pos] = enemy
        enemy.diff_agi = CommonUtil.valueMin1(enemy.agi - kappa.agi)
        setEnemyBirthSpeed(enemy)
        if world_name == "dancer" {
            enemy.str = 999999999
        }
    }
    
    func setEnemyBirthSpeed(_ enemy : EnemyNode){
        enemy.dx += CommonUtil.rnd(300)
        enemy.dy += CommonUtil.rnd(300)
    }
    
    
    func createEnemyLifeBar(pos: Int, x: CGFloat, y: CGFloat){
        let lifeBarBackGround = SKSpriteNode(color: .black, size: CGSize(width: 90, height: 20))
        lifeBarBackGround.position = CGPoint(x: x, y: y)
        lifeBarBackGround.zPosition = 90
        lifeBarBackGround.name = "back_life_bar\(pos)"
        lifeBarBackGround.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        addChild(lifeBarBackGround)
        
        let lifeBar = SKSpriteNode(color: .yellow, size: CGSize(width: 90, height: 20))
        lifeBar.position = CGPoint(x: x, y: y)
        lifeBar.zPosition = 91
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
    
    // 死神召喚
    func makeDeath(position: CGPoint){
        for i in 0...(Const.maxPosition-3) {
            if enemyModel.enemies[i] == EnemyNode() || enemyModel.enemies[i].isDead {
                createGhost(position: position, enemy_name: "death", pos: i)
            }
        }
    }
    
    // レーザー攻撃
    func makeLazer(_ damage: Int){
        for i in 0...6 {
            let delay = 1.2 - 0.2*Double(i)
            _ = CommonUtil.setTimeout(delay: delay, block: { () -> Void in
                self.createLazer(pos: i, damage: damage)
            })
        }
    }
    
    
    /***********************************************************************************/
    /******************************** マップ更新  **************************************/
    /***********************************************************************************/
    
    // マップ作成
    var bossStopFlag = false
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
            bossStopFlag = true
            displayLongMessage("Boss: \(map.boss_name)")
            bossExec()
            showMagicCircuit()
        }
    }
    
    // ボスで特別な処理を行う場合
    func bossExec(){
        
    }
    
    func changeBackGround(){
        let background = self.childNode(withName: "//BackgroundNode") as! SKSpriteNode
        if map.background == "nil" {
            background.isHidden = true
        } else {
            background.texture = SKTexture(imageNamed: map.background)
        }
    }
    
    // マップの情報を削除
    func clearMap(){
        let rm_nodes = [
            "enemy",
            "fire",
            "damage_text",
            "bg_damage_text",
            "displayText",
            "thunder",
            "arrow",
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

        hideBigMessage()
    }
    
    func hideBigMessage(){
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
        let AgiLabel       = childNode(withName: "//AgiLabel")    as! SKLabelNode
        let IntLabel       = childNode(withName: "//IntLabel")    as! SKLabelNode
        let LucLabel       = childNode(withName: "//LucLabel")    as! SKLabelNode
        
        MAXHPLabel.text = "HP  \(String(describing: kappa.maxHp))"
        HPLabel.text  = "\(kappa.hp)"
        LVLabel.text  = "LV    \(String(describing: kappa.lv))"
        StrLabel.text = "筋力  \(String(describing: kappa.str))"
        AgiLabel.text = "敏捷  \(String(describing: kappa.agi))"
        IntLabel.text = "知恵  \(String(describing: kappa.int))"
        LucLabel.text = "幸運  \(String(describing: kappa.luc))"
        
        // 職業情報
        let JobLVLabel     = childNode(withName: "//JobLVLabel") as! SKLabelNode
        let JobNameLabel   = childNode(withName: "//JobNameLabel") as! SKLabelNode
        
        JobNameLabel.text = gameData.displayNickJob(jobModel.displayName)
        JobLVLabel.text = "LV  \(jobModel.lv)"
        
        // タップ情報
        let TapCountLabel  = childNode(withName: "//TapCountLabel") as! SKLabelNode
        TapCountLabel.text = "\(gameData.tapCount)"
        
        changeLifeBar()
        updateName()
    }
    
    // 距離情報の更新
    func updateDistance(){
        let distanceLabel    = childNode(withName: "//DistanceLabel") as! SKLabelNode
        distanceLabel.text = "\(map.distance)km"
    }
    
    func updateName(){
        let nameLabel = childNode(withName: "//NameLabel") as! SKLabelNode
        nameLabel.text = gameData.name
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
    internal var bigMessages = [[String]]()
    internal func showBigMessage(text0 : String, text1 : String){
        bigMessages.append([text0, text1])
    }
    
    internal var isShowingBigMessage = false
    internal func displayBigMessage(){
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
    
    func displayLongMessage(_ text : String){
        showLongMessage()
        let longLabel = childNode(withName: "//longMessageLabel") as! SKLabelNode
        longLabel.text = text
        longLabel.run(actionModel.longMessage!, completion: {() -> Void in
            self.hideLongMessage()
            self.bossStopFlag = false
            self.goCutin("pre")
        })
    }
    
    func hideLongMessage(){
        let longLabel = childNode(withName: "//longMessageLabel") as! SKLabelNode
        let longLabel2 = childNode(withName: "//longMessageLabel2") as! SKLabelNode
        let longNode = childNode(withName: "//longMessageNode") as! SKSpriteNode
        longLabel.isHidden = true
        longLabel2.isHidden = true
        longNode.isHidden = true
    }
    
    func showLongMessage(){
        let longLabel = childNode(withName: "//longMessageLabel") as! SKLabelNode
        let longLabel2 = childNode(withName: "//longMessageLabel2") as! SKLabelNode
        let longNode = childNode(withName: "//longMessageNode") as! SKSpriteNode
        longLabel.isHidden = false
        longLabel2.isHidden = false
        longNode.isHidden = false
    }
    
    func hideSkillBox(){
        hideSpriteNode("SkillBox")
        hideLabelNode("SkillLabel")
    }
    
    func hideMagicCircuit(){
        hideSpriteNode("magic_circuit")
        hideSpriteNode("gray_wall")
    }

    func showMagicCircuit(){
        let magicNode = childNode(withName: "//magic_circuit") as! SKSpriteNode
        let grayNode = childNode(withName: "//gray_wall") as! SKSpriteNode
        magicNode.isHidden = false
        grayNode.isHidden = false
        magicNode.run(actionModel.fadeOutEternal2)
        grayNode.run(actionModel.fadeOutEternal2)
    }

    
    
    func showSkillBox(_ skill_name : String){
        let skillBox = childNode(withName: "//SkillBox") as? SKSpriteNode
        let skillLabel = childNode(withName: "//SkillLabel") as? SKLabelNode
        if let box = skillBox?.copy() as! SKSpriteNode? {
            let pre_skillBox = childNode(withName: "//SkillBox2") as? SKSpriteNode
            let pre_skillLabel = childNode(withName: "//SkillLabel2") as? SKLabelNode
            pre_skillBox?.zPosition = 1
            pre_skillLabel?.zPosition = 1

            
            box.isHidden = false
            box.name = "SkillBox2"
            addChild(box)
            box.run(actionModel.leftFadeOutEternal)
            if let label = skillLabel?.copy() as! SKLabelNode? {
                label.isHidden = false
                label.text = skill_name
                label.name = "SkillLabel2"
                box.addChild(label)
            }
        }
    }
    
    /***********************************************************************************/
    /********************************* 画面遷移 ****************************************/
    /***********************************************************************************/
    // メニュー画面へ遷移
    func goMenu(){
        stopBGM()
        let nextScene = MenuScene(fileNamed: "MenuScene")!
        nextScene.size = scene!.size
        nextScene.scaleMode = SKSceneScaleMode.aspectFit
        nextScene.backScene = scene as! GameScene
        nextScene.back = "game"
        view!.presentScene(nextScene, transition: .fade(withDuration: Const.transitionInterval))
    }
    
    // ゲームオーバー画面へ
    var gameover_check_flag = false
    func goGameOver(){
        if beat_boss_flag {
            return
        }
        if gameover_check_flag {
            return
        }
        gameover_check_flag = true

        // 死亡カウントを増やす
        gameData.death += 1
        gameData.saveParam()
        
        stopBGM()
        let nextScene = GameOverScene(fileNamed: "GameOverScene")!
        nextScene.size = scene!.size
        nextScene.scaleMode = SKSceneScaleMode.aspectFit
        nextScene.world_name = world_name
        nextScene.chapter = chapter
        view!.presentScene(nextScene, transition: .fade(with: .white, duration: Const.gameOverInterval))
    }
    
    // カットイン画面へ
    func goCutin(_ key : String){
        let nextScene = CutinScene(fileNamed: "CutinScene")!
        nextScene.size = scene!.size
        nextScene.scaleMode = SKSceneScaleMode.aspectFit
        nextScene.backScene = scene as! GameScene
        nextScene.key = key
        nextScene.world = world_name
        nextScene.bgm = _audioPlayer
        view!.presentScene(nextScene, transition: .fade(with: .black, duration: Const.gameOverInterval))
    }
    
    /***********************************************************************************/
    /********************************** specialAttack **********************************/
    /***********************************************************************************/
    func createHado(){
        let fire = FireEmitterNode.makeKappaFire()
        fire.position = CGPoint(x: kappa.position.x - 60, y: kappa.position.y + 20)
        self.addChild(fire)
        fire.hado()
    }
    
    // 技ラベルを更新
    func updateSpecialView(){
    }
    
    // かっぱバスター
    func kappaBuster(){
    }
    
    /***********************************************************************************/
    /********************************** touch ******************************************/
    /***********************************************************************************/
    func touchDown(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    /***********************************************************************************/
    /********************************** 衝突判定 ****************************************/
    /***********************************************************************************/
    func didBegin(_ contact: SKPhysicsContact) {
    }
    
    func isFirstBodyKappa(_ firstBody : SKPhysicsBody) -> Bool {
        return (firstBody.categoryBitMask & Const.kappaCategory != 0) || (firstBody.categoryBitMask & Const.kappa2Category != 0)
    }
    
    func isMagickNode(_ firstBody : SKPhysicsBody) -> Bool {
        return  (firstBody.categoryBitMask & Const.fireCategory != 0) || (firstBody.categoryBitMask & Const.thunderCategory != 0)
    }
    
    /***********************************************************************************/
    /********************************* update ******************************************/
    /***********************************************************************************/
    private var lastUpdateTime : TimeInterval = 0
    private var doubleTimer = 0.0 // 経過時間（小数点単位で厳密）
    override func update(_ currentTime: TimeInterval) {
        execMessages()
        if gameOverFlag || bossStopFlag {
            return
        }
        
        if (lastUpdateTime == 0) {
            lastUpdateTime = currentTime
        }
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        frameExec()
        doubleTimer += dt
        if doubleTimer > 1.0 {
            doubleTimer = 0.0
        } else {
            return
        }
        secondTimerExec()
    }
 
    // 秒ごとの処理
    override func secondTimerExec(){
        enemyAction()
    }
    
    func enemyAction(){
        
    }
}
