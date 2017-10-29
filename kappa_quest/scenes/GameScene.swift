// ゲーム画面
import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: BaseScene, SKPhysicsContactDelegate {

    // internal要素
    internal var actionModel : ActionModel = ActionModel()
    internal var kappa_first_position_y : CGFloat!
    internal var kappa : KappaNode!   // かっぱ画像
    internal var map : Map = Map()
    
    // private要素
    private var enemyModel : EnemyModel = EnemyModel()
    private var specialAttackModel : SpecialAttackModel = SpecialAttackModel()
    private var skillModel : SkillModel = SkillModel()
    var world_name = "tutorial"

    // Scene load 時に呼ばれる
    internal var isSceneDidLoaded = false
    override func sceneDidLoad() {
        
        // 二重読み込みの防止
        if isSceneDidLoaded {
            return
        }
        isSceneDidLoaded = true

        lastUpdateTime = 0
        setWorld()

        // データをセット
        enemyModel.readDataByPlist()
        jobModel.readDataByPlist()
        jobModel.loadParam()
        skillModel.readDataByPlist()
        actionModel.setActionData(sceneWidth: size.width)
        createKappa()
        skillModel.judgeSKill()
        displayExpLabel()
        changeExpBar()
        updateName()
        updateSpecialView()
        hideLongMessage()
        
        // 音楽関係の処理
        prepareBGM(fileName: Const.bgm_fantasy)
        prepareSoundEffect()
        playBGM()
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
        kappa.setParameterByUserDefault()
        kappa.setNextExp(jobModel)
        if jobModel.name == "knight" {
            kappa.physic_type = "noppo"
        }
        kappa.setPhysic()
        kappa_first_position_y = kappa.position.y
        setFirstPosition()
        if map.distance == 0.0 {
            kappa.heal()
        }
    }

    // カッパを初期ポジションに設置
    func setFirstPosition(){
        map.myPosition = 1
        kappa.position.x = getPositionX(1)
        kappa.position.y = kappa_first_position_y
        kappa.texture = SKTexture(imageNamed: "kappa")
    }

    func saveData(){
        kappa?.saveParam()
        gameData.saveParam()
        jobModel.saveParam()
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
        if jobModel.isHighSpeed() {
            action = actionModel.speedMoveRight
        } else if jobModel.name == "assassin" {
            action = actionModel.speedMaxMoveRight
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
        clearMap()
        resetMessage()
        setFirstPosition()
        map.goNextMap()
        saveData()
        createMap()
        updateDistance()
        
        heal(skillModel.map_heal)
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

        var action : SKAction!
        
        if jobModel.isHighSpeed() {
            action = actionModel.speedMoveLeft
        } else if jobModel.name == "assassin" {
            action = actionModel.speedMaxMoveLeft
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
        /*
        if map.isTreasure() {
            ButtonNode.texture = SKTexture(imageNamed: "button_red")
            ButtonLabel.text = "装備する"
            let treasure_key = map.treasures[map.myPosition]
            let point = CGPoint(x: getPositionX(map.myPosition), y: kappa_first_position_y + 100.0)
            displayText(equipModel.getName(treasure_key), position: point)
            if !map.treasureExplainFlag {
                map.treasureExplainFlag = true
                showBigMessage(text0: equipModel.getName(treasure_key), text1: equipModel.getExplain(treasure_key))
                if !ButtonNode.hasActions() {
                    ButtonNode.run(actionModel.moveButton)
                }
            }
        } else {
        }
         */
        ButtonNode.texture = SKTexture(imageNamed: "button_blue")
        ButtonLabel.text = "メニューを開く"
    }

    // 攻撃
    func attack(){
        kappa.attack()
        kappa.run(actionModel.attack!)
    }

    private var maxDamage = 0 // 最高ダメージ
    func attackCalculate(str : Int, type : String, enemy : EnemyNode){
        var damage = 0
        var def = 0
        let pos = enemy.pos
        if type == "physic" {
            def = enemy.def
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

        if damage > maxDamage {
            maxDamage = damage
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
        if kappa.hp <= 0 && skillModel.konjo_flag && !kappa.konjoEndFlag {
            kappa.hp = kappa.luc
            if kappa.hp > kappa.maxHp {
                kappa.hp = kappa.maxHp
            }
            showMessage("カッパのど根性！", type: "skill")
            kappa.konjoEndFlag = true
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
    
    func heal(_ heal_val : Int){
        if heal_val <= 0 {
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
    private var beat_boss_flag = false
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
        heal(skillModel.necro_heal)
    }
    
    func beatBoss(){
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
        kappa.LvUp(jobModel)
        showMessage("LVがあがった", type: "lv")

        let HPUpLabel      = childNode(withName: "//HPUpLabel")  as! SKLabelNode
        let StrUpLabel     = childNode(withName: "//StrUpLabel") as! SKLabelNode
        let AgiUpLabel     = childNode(withName: "//AgiUpLabel") as! SKLabelNode
        let IntUpLabel     = childNode(withName: "//IntUpLabel") as! SKLabelNode
        let LucUpLabel     = childNode(withName: "//LucUpLabel") as! SKLabelNode

        if jobModel.hp != 0 {
            HPUpLabel.text = "+\(jobModel.hp)"
            HPUpLabel.run(actionModel.fadeInOut!)
        }
        if jobModel.str != 0 {
            StrUpLabel.text = "+\(jobModel.str)"
            StrUpLabel.run(actionModel.fadeInOut!)
        }
        if jobModel.str != 0 {
            AgiUpLabel.text = "+\(jobModel.agi)"
            AgiUpLabel.run(actionModel.fadeInOut!)
        }
        if jobModel.int != 0 {
            IntUpLabel.text = "+\(jobModel.int)"
            IntUpLabel.run(actionModel.fadeInOut!)
        }
        if jobModel.luc != 0 {
            LucUpLabel.text = "+\(jobModel.luc)"
            LucUpLabel.run(actionModel.fadeInOut!)
        }

        if isGetSkill() {
            showMessage("スキル習得", type: "skill")
        }
        saveData()

        // スキル判定
        skillModel.judgeSKill()
        
        heal(skillModel.lv_up_heal)
        
        gameData.changeNicknameByLV(lv: jobModel.lv)
        updateName()
    }

    func isGetSkill() -> Bool {
        return (jobModel.name == "murabito" && jobModel.lv == 5) || (jobModel.name == "archer" && jobModel.lv == 10) || (jobModel.name == "wizard" && jobModel.lv == 10 || (jobModel.name == "fighter" && jobModel.lv == 10) || (jobModel.name == "gundom" && jobModel.lv == 10) )
    }
    

    // タップ数アップ
    // 40タップごとに僧侶のアビリティを発動
    func tapCountUp(){
        gameData.tapCount += 1
        specialAttackModel.countUp()
        if jobModel.name == "maou" {
            specialAttackModel.countUp()
        }
        if jobModel.name == "dark_kappa" {
            specialAttackModel.countUp()
            specialAttackModel.countUp()
        }

        let TapCountLabel  = childNode(withName: "//TapCountLabel") as! SKLabelNode
        TapCountLabel.text = "\(gameData.tapCount)"
        
        if gameData.tapCount%Const.tapHealCount == 0 {
            heal(skillModel.heal_val)
        }
        if skillModel.tap_dance_flag {
            updateExp(1)
        }
    }

    /***********************************************************************************/
    /******************************* ゲームオーバー ************************************/
    /***********************************************************************************/
    private var gameOverFlag = false
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

    func resetData(){
        kappa.hp = kappa.maxHp
        kappa.konjoEndFlag = false
        map.resetData()
        gameOverFlag = false

        clearMap()
        createMap()
        setFirstPosition()
        saveData()

        prepareBGM(fileName: Const.bgm_fantasy)
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

        if map.isBoss && pos == Const.maxPosition - 1 {
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
        enemy.diff_agi = CommonUtil.valueMin1(enemy.agi - kappa.agi)
        
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
        enemy.dx += CommonUtil.rnd(300)
        enemy.dy += CommonUtil.rnd(300)
        if world_name == "dancer" {
            enemy.str = 999999999
        }
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
            stopBGM()
            if world_name == "dark_kappa" {
                prepareBGM(fileName: Const.bgm_bit_cry)
            } else {
                prepareBGM(fileName: Const.bgm_last_battle)
            }
            playBGM()
            bossStopFlag = true
            displayLongMessage("Boss: \(map.boss_name)")
        }
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
    
    /***********************************************************************************/
    /********************************* 画面遷移 ****************************************/
    /***********************************************************************************/
    // メニュー画面へ遷移
    func goMenu(){
        stopBGM()
        let scene = MenuScene(fileNamed: "MenuScene")!
        scene.size = self.scene!.size
        scene.scaleMode = SKSceneScaleMode.aspectFill
        scene.backScene = self.scene as! GameScene
        self.view!.presentScene(scene, transition: .fade(withDuration: Const.transitionInterval))
    }

    // ゲームオーバー画面へ
    func goGameOver(){
        if beat_boss_flag {
            return
        }
        stopBGM()
        let nextScene = GameOverScene(fileNamed: "GameOverScene")!
        nextScene.size = nextScene.size
        nextScene.scaleMode = SKSceneScaleMode.aspectFill
        nextScene.backScene = self.scene as! GameScene
        view!.presentScene(nextScene, transition: .fade(with: .white, duration: Const.gameOverInterval))
    }

    // カットイン画面へ
    func goCutin(_ key : String){
        let nextScene = CutinScene(fileNamed: "CutinScene")!
        nextScene.size = scene!.size
        nextScene.scaleMode = SKSceneScaleMode.aspectFill
        nextScene.backScene = scene as! GameScene
        nextScene.key = key
        nextScene.world = world_name
        nextScene.bgm = _audioPlayer
        view!.presentScene(nextScene, transition: .fade(with: .black, duration: Const.gameOverInterval))
    }
    
    /***********************************************************************************/
    /********************************** specialAttack **********************************/
    /***********************************************************************************/
    // スーパー頭突き
    func specialAttackHead(){
        kappa.head()
        heal(skillModel.angel_heal)
        specialAttackModel.execHead()

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
        if skillModel.super_head_flag {
            createHado()
        }
        map.myPosition = pos - 1
    }

    // 昇竜拳
    func specialAttackUpper(){
        kappa.upper()
        heal(skillModel.upper_heal)
        specialAttackModel.execUpper()
        if skillModel.upper_rotate_flag {
            kappa.isSpin = true
        }
        if skillModel.super_upper_flag {
            upHado()
        }
        kappa.run(actionModel.upper!, completion: {() -> Void in
            self.kappa.isSpin = false
            self.specialAttackModel.finishAttack()
        })
    }

    // 竜巻旋風脚
    func specialAttackTornado(){
        kappa.tornado()
        heal(skillModel.tornado_heal)
        if skillModel.super_tornado_flag {
            upHado()
        }
        specialAttackModel.execTornado()

        let upper = SKAction.sequence([
            SKAction.moveBy(x: 0, y:  45, duration: Const.headAttackSpeed/2),
            SKAction.wait(forDuration: 1.5),
            SKAction.moveBy(x: 0, y: -45, duration: Const.headAttackSpeed/2),
        ])
        kappa.run(upper, completion: {() -> Void in
            self.specialAttackModel.finishAttack()
        })
    }

    // 波動砲
    func specialAttackHado(){
        kappa.hado()
        heal(skillModel.hado_heal)
        specialAttackModel.execHado()
        createHado()
        specialAttackModel.finishAttack()
    }
    
    func createHado(){
        let fire = FireEmitterNode.makeKappaFire()
        fire.position = CGPoint(x: kappa.position.x - 60, y: kappa.position.y + 20)
        self.addChild(fire)
        fire.hado()
    }
    
    func updateSpecialView(){
        let upperNode   = childNode(withName: "//IconNotKappaUpper") as! SKSpriteNode
        let headNode    = childNode(withName: "//IconNotKappaHead") as! SKSpriteNode
        let tornadoNode = childNode(withName: "//IconNotKappaTornado") as! SKSpriteNode
        let hadoNode    = childNode(withName: "//IconNotKappaHado") as! SKSpriteNode

        upperNode.isHidden      = specialAttackModel.canSpecialUpper()
        headNode.isHidden       = specialAttackModel.canSpecialHead()
        tornadoNode.isHidden    = specialAttackModel.canSpecialTornado()
        hadoNode.isHidden       = specialAttackModel.canSpecialHado()
        
        let upperBar    = childNode(withName: "//UpperBar") as! SKSpriteNode
        let headBar     = childNode(withName: "//HeadBar") as! SKSpriteNode
        let tornadoBar  = childNode(withName: "//TornadoBar") as! SKSpriteNode
        let hadoBar     = childNode(withName: "//HadoBar") as! SKSpriteNode
        
        upperBar.size.width     = CGFloat(specialAttackModel.barSpecialUpper())
        headBar.size.width      = CGFloat(specialAttackModel.barSpecialHead())
        tornadoBar.size.width   = CGFloat(specialAttackModel.barSpecialTornado())
        hadoBar.size.width      = CGFloat(specialAttackModel.barSpecialHado())
    }
    
    // 上方向に波動を放つ
    func upHado(){
        let hado = FireEmitterNode.makeKappaUpperFire()
        hado.position = kappa.position
        hado.upShot()
        addChild(hado)
    }

    /***********************************************************************************/
    /********************************** touch ******************************************/
    /***********************************************************************************/
    func touchDown(atPoint pos : CGPoint) {
        if specialAttackModel.is_attacking {
            if specialAttackModel.mode != "tornado" {
                return
            } else {
                specialAttackModel.finishAttack()
                kappa.removeAllActions()
                kappa.position.y = kappa_first_position_y
            }
        }
        if gameOverFlag || bossStopFlag {
            return
        }

        if pos.x >= 0 {
            if map.canMoveRight() {
                moveRight()
            } else if map.isRightEnemy() {
                attack()
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
        if specialAttackModel.is_attacking {
            if specialAttackModel.mode != "tornado" {
                return
            } else {
                specialAttackModel.finishAttack()
                kappa.removeAllActions()
                kappa.position.y = kappa_first_position_y
            }
        }
        if gameOverFlag || bossStopFlag {
            return
        }
        if map.myPosition+1 > Const.maxPosition {
            return
        }
        for t in touches {
            let positionInScene = t.location(in: self)
            let tapNode = atPoint(positionInScene)
            if tapNode.name == nil {
                touchDown(atPoint: positionInScene)
                return
            }
            switch tapNode.name! {
            case "ButtonNode", "ButtonLabel":
                goMenu()
            case "IconKappaHado":
                if specialAttackModel.canSpecialHado() {
                    specialAttackHado()
                } else {
                    self.touchDown(atPoint: positionInScene)
                }
            case "IconKappaHead":
                if specialAttackModel.canSpecialHead() {
                    specialAttackHead()
                } else {
                    self.touchDown(atPoint: positionInScene)
                }
            case "IconKappaTornado":
                if specialAttackModel.canSpecialTornado() {
                    specialAttackTornado()
                } else {
                    self.touchDown(atPoint: positionInScene)
                }
            case "IconKappaUpper":
                if specialAttackModel.canSpecialUpper() {
                    specialAttackUpper()
                } else {
                    self.touchDown(atPoint: positionInScene)
                }
            default:
                self.touchDown(atPoint: positionInScene)
            }
            updateSpecialView()
        }
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
                if jobModel.name != "gundom" {
                    let fire = secondBody.node as! FireEmitterNode
                    attacked(attack: fire.damage, point: (firstBody.node?.position)!)
                    makeSpark(point: (secondBody.node?.position)!)
                    secondBody.node?.removeFromParent()
                }
            } else if secondBody.categoryBitMask & Const.thunderCategory != 0 {
                if !specialAttackModel.is_head {
                    let thunder = secondBody.node as! ThunderEmitterNode
                    attacked(attack: thunder.damage, point: (firstBody.node?.position)!)
                    makeSpark(point: (secondBody.node?.position)!)
                    secondBody.node?.removeFromParent()
                }
            } else if secondBody.categoryBitMask & Const.enemyCategory != 0 {
                let enemy = secondBody.node as! EnemyNode
                if enemy.isDead {
                    return
                }
                // 敵の攻撃
                if enemy.isAttacking && !specialAttackModel.is_tornado && !specialAttackModel.is_upper {
                    attacked(attack: enemy.str, point: (firstBody.node?.position)!)
                    makeSpark(point: (firstBody.node?.position)!)
                }
                
                // カッパの攻撃
                if specialAttackModel.is_attacking {
                    switch specialAttackModel.mode {
                    case "head":
                        let damage = 1 + CommonUtil.rnd(kappa.str + kappa.int)
                        attackCalculate(str: damage, type: "magick", enemy: enemy)
                    case "upper":
                        if skillModel.upper_rotate_flag {
                            let damage = 1 + CommonUtil.rnd(kappa.str + kappa.int + kappa.agi)
                            attackCalculate(str: damage, type: "magick", enemy: enemy)
                        } else {
                            let damage = 1 + CommonUtil.rnd(kappa.str + kappa.int)
                            attackCalculate(str: damage, type: "magick", enemy: enemy)
                        }
                    case "tornado":
                        let damage = enemy.str + CommonUtil.rnd(kappa.agi + kappa.int)
                        attackCalculate(str: damage, type: "magick", enemy: enemy)
                    default:
                        break
                    }
                } else if kappa.hasActions() && !enemy.isMovingFree {
                    let damage = 1 + CommonUtil.rnd(kappa.str)
                    attackCalculate(str: damage, type: "physic", enemy: enemy)
                }
            }
        } else if isMagickNode(firstBody) {
            if secondBody.categoryBitMask & Const.worldCategory != 0 {
                makeSpark(point: (firstBody.node?.position)!)
                firstBody.node?.removeFromParent()
            }
        } else if firstBody.categoryBitMask & Const.kappaFireCategory != 0 {
            if secondBody.categoryBitMask & Const.enemyCategory != 0 {
                let enemy = secondBody.node as! EnemyNode
                if enemy.isDead {
                    return
                }
                makeSpark(point: (secondBody.node?.position)!)
                attackCalculate(str: kappa.int, type: "magick", enemy: enemy)
                // 貫通スキルがなければ波動拳は消滅
                if !skillModel.hado_penetrate_flag {
                    firstBody.node?.removeFromParent()
                }
            }
        }
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

        // カッパの回転処理
        if specialAttackModel.is_tornado || kappa.isSpin {
            if CommonUtil.rnd(4) == 0 {
                kappa.xScale *= -1
            }
        }
        
        doubleTimer += dt
        if doubleTimer > 1.0 {
            doubleTimer = 0.0
        } else {
            return
        }
        enemyAction()
    }

    // モンスターが1秒おきに実行する処理
    func enemyAction(){
        for enemy in enemyModel.enemies {
            if enemy.isDead {
                continue
            }
            enemy.timerUp()
            if enemy.isAttack() {
                enemy.normalAttack(actionModel)
            } else if enemy.isFire() {
                if !enemy.isMovingFree {
                    enemy.run(actionModel.enemyJump!)
                }
                enemy.makeFire()
                enemy.fire.position = CGPoint(x: enemy.position.x, y: enemy.position.y + 40 )
                self.addChild(enemy.fire)
                enemy.fire.shot()
                enemy.fireTimerReset()
            } else if enemy.isThunder() {
                createThunder(pos: enemy.pos - 1, damage: enemy.int)
                createThunder(pos: enemy.pos - 2, damage: enemy.int)
                createThunder(pos: enemy.pos - 3, damage: enemy.int)
                enemy.thunderTimerReset()
            } else if enemy.isArrow() {
                if CommonUtil.rnd(2) == 0 {
                    createArrow(pos: 2, damage: enemy.int)
                    createArrow(pos: 4, damage: enemy.int)
                } else {
                    createArrow(pos: 1, damage: enemy.int)
                    createArrow(pos: 3, damage: enemy.int)
                    createArrow(pos: 5, damage: enemy.int)
                }
                enemy.arrowTimerReset()
            } else if enemy.isDeath() {
                makeDeath(position: enemy.position)
                enemy.deathTimerReset()
            } else if enemy.isLazer() {
                makeLazer(enemy.int)
                enemy.lazerTimerReset()
            } else if enemy.jumpTimer%4 == 0 && !enemy.canFly {
                enemy.run(actionModel.enemyMiniJump!)
                enemy.jumpTimerReset()
            }
            
            // 再生
            if enemy.heal != 0 {
                enemy.healHP(enemy.heal)
                changeEnemyLifeBar(enemy.pos, per: enemy.hp_per())
            }
            
            // 移動
            if enemy.isMovingFree {
                if enemy.position.x < getPositionX(1) {
                    enemy.convertDxPlus()
                } else if enemy.position.x > getPositionX(Const.maxPosition-1) {
                    enemy.convertDxMinus()
                }
                if enemy.position.y < kappa_first_position_y {
                    enemy.convertDyPlus()

                } else if enemy.position.y > kappa_first_position_y + 250.0 {
                    enemy.convertDyMinus()
                }
                enemy.run(SKAction.moveBy(x: CGFloat(enemy.dx), y: CGFloat(enemy.dy) , duration: 1.0))
            }
            
            // 移動制限
            if enemy.canFly && !enemy.isMovingFree && enemy.position.y > kappa_first_position_y + 250 {
                enemy.physicsBody?.velocity = CGVector(dx:0, dy:0)
            }
        }
    }
}
