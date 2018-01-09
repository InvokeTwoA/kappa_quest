// ゲーム画面
import SpriteKit
import GameplayKit
import AVFoundation

class Game2Scene: GameBaseScene {
    private var abilityModel = AbilityModel()
    
    // 章に応じて変数を上書き
    override func setBaseVariable(){
        chapter = 2
        abilityModel.setFlag()
        prepareBGM(fileName: Const.bgm_brave)
        
        enemyModel.readDataByPlist(chapter)
        jobModel.readDataByPlist(chapter)
        jobModel.loadParam(chapter)
        actionModel.setActionData(sceneWidth: size.width)
        createKappa()
        displayExpLabel()
        changeExpBar()
        updateName()
        updateSpecialView()


        if abilityModel.canUse("body_tanuki") {
            kappa.isTanuki = true
        }
    }
    
    override func createKappaByChapter(){
        kappa.setParameterByChapter2()
        kappa.setNextExp(jobModel)
    }
    
    // ２章では「かっこよさ」以上に回復しない
    override func heal(_ heal_val : Int){
        if heal_val <= 0 || kappa.hp == kappa.maxHp {
            return
        }
        var val = heal_val
        if val > kappa.beauty {
            val = kappa.beauty
        }
        kappa.hp += val
        displayDamage(value: val, point: kappa.position, color: .green, direction: "up")
        updateStatus()
    }
    
    override func getMoveActionRight() -> SKAction {
        if abilityModel.canUse("shukuchi2") {
            return actionModel.speedMaxMoveRight
        } else if abilityModel.canUse("shukuchi") {
            return actionModel.speedMoveRight
        } else {
            return actionModel.moveRight
        }
    }

    override func getMoveActionLeft() -> SKAction {
        if abilityModel.canUse("shukuchi2") {
            return actionModel.speedMaxMoveLeft
        } else if abilityModel.canUse("shukuchi") {
            return actionModel.speedMoveLeft
        } else {
            return actionModel.moveLeft
        }
    }

    
    // メニュー画面へ遷移
    override func goMenu(){
        stopBGM()
        let nextScene = MenuScene(fileNamed: "MenuScene")!
        nextScene.size = self.scene!.size
        nextScene.scaleMode = SKSceneScaleMode.aspectFit
        nextScene.back2Scene = self.scene as! Game2Scene
        nextScene.back = "game"
        nextScene.chapter = 2
        self.view!.presentScene(nextScene, transition: .fade(withDuration: Const.transitionInterval))
    }
    
    // カットイン画面へ
    override func goCutin(_ key : String){
        let nextScene = CutinScene(fileNamed: "CutinScene")!
        nextScene.size = scene!.size
        nextScene.scaleMode = SKSceneScaleMode.aspectFit
        nextScene.back2Scene = scene as! Game2Scene
        nextScene.key = key
        nextScene.world = world_name
        nextScene.bgm = _audioPlayer
        nextScene.chapter = 2
        view!.presentScene(nextScene, transition: .fade(with: .black, duration: Const.gameOverInterval))
    }
    
    
    // ボスで特別な処理を行う場合
    override func bossExec(){
        if world_name == "hiyoko" {
            let ButtonLabel = childNode(withName: "//ButtonLabel") as! SKLabelNode
            ButtonLabel.text = "わかるってばよ"
            ButtonLabel.fontSize = 24
        }
        
        stopBGM()
        prepareBGM(fileName: Const.bgm_kessen)
        playBGM()
    }
    
    override func setEnemyBirthSpeed(_ enemy : EnemyNode) {
    }

    /***********************************************************************************/
    /********************************** 敵の攻撃 ****************************************/
    /***********************************************************************************/
    // 敵のバスター
    func createEnemyBuster(_ enemy : EnemyNode){
        let buster = EnemyBusterNode.createEnemyBuster(enemy)
        self.addChild(buster)        
        buster.shot()
    }
    
    /***********************************************************************************/
    /********************************** specialAttack **********************************/
    /***********************************************************************************/
    // カッパバスター
    override func kappaBuster(){
        // 正面に一撃
        if abilityModel.canUse("buster_right") {
            kappa.xScale = 1.0
            createBuster(xScale: 1.0, y: 0.0)
        } else {
            createBuster(xScale: kappa.xScale, y: 0.0)
        }
        kappa.buster()
        // 二丁拳銃
        if abilityModel.canUse("buster_up") {
            createBuster(xScale: kappa.xScale, y: Const.enemyFlyHeight)
        }
        
        // 背後に一撃
        if abilityModel.canUse("buster_back") {
            createBuster(xScale: -1.0*kappa.xScale, y: 0.0)
        }
        
        if abilityModel.canUse("buster_heal") {
            heal(1)
        }
        rushCount += 1
        updateSpecialView()
    }
    
    func createBuster(xScale: CGFloat, y : CGFloat){
        var BUSTER_RADIUS : CGFloat = 16.0
        if abilityModel.canUse("buster_big") {
            BUSTER_RADIUS = 32.0
        }
        
        let circle = SKShapeNode(circleOfRadius: BUSTER_RADIUS)
        circle.physicsBody = busterPhysic(BUSTER_RADIUS)
        circle.fillColor = UIColor.yellow
        circle.position = CGPoint(x: kappa.position.x, y: kappa.position.y + 40)
        circle.zPosition = 12
        self.addChild(circle)

        var BUSTER_LONG : CGFloat = 300.0
        if abilityModel.canUse("buster_long") {
            BUSTER_LONG = 600.0
        }
        if xScale < 0 {
            BUSTER_LONG *= -1
        }
        
        let busterAction = SKAction.sequence([
            SKAction.moveBy(x: BUSTER_LONG, y: y, duration: busterSpeed()),
            SKAction.removeFromParent()
        ])
        circle.run(busterAction)
    }
    
    func busterSpeed() -> TimeInterval {
        if abilityModel.canUse("buster_slow") {
            return 0.9
        }
        return 0.5
    }
    
    func busterPhysic(_ r : CGFloat) -> SKPhysicsBody {
        //let physics = SKPhysicsBody(circleOfRadius: r)
        let physics = SKPhysicsBody(rectangleOf: CGSize(width: r*2.0, height: r*2.0))
        physics.categoryBitMask = Const.busterCategory
        physics.contactTestBitMask = Const.enemyCategory
        physics.collisionBitMask = Const.worldCategory
        physics.affectedByGravity = abilityModel.canUse("buster_gravity")
        physics.restitution = 0.0
        return physics
    }
    
    override func updateSpecialView(){
        let rushNode = childNode(withName: "//IconNotKappaRush") as! SKSpriteNode
        rushNode.isHidden = canRush()
        let rushBar  = childNode(withName: "//RushBar") as! SKSpriteNode
        rushBar.size.width = barRush()
    }
    
    // kappa jump
    private var jumpFlag = false
    func kappaJump(){
        if jumpFlag {
            return
        }
        jumpFlag = true
        
        let JUMP_DURATION = 0.4
        var JUMP_STOP = 0.2
        if abilityModel.canUse("jump_plus") {
            JUMP_STOP = 0.6
        }
        
        let jumpAction = SKAction.sequence([
            SKAction.moveBy(x: 0, y: jumpHeight(), duration: JUMP_DURATION),
            SKAction.wait(forDuration: JUMP_STOP),
            SKAction.moveBy(x: 0, y: -1*jumpHeight(), duration: JUMP_DURATION),
            ])
        kappa.run(jumpAction)
        
        let TOTAL_DURATION = JUMP_DURATION*2.0 + JUMP_STOP
        _ = CommonUtil.setTimeout(delay: TOTAL_DURATION, block: { () -> Void in
            self.jumpFlag = false
        })
        
        if abilityModel.canUse("jump_heal") {
            heal(kappa.beauty)
        }
    }
    
    func jumpHeight() -> CGFloat {
        if abilityModel.canUse("jump_high") {
            return Const.enemyFlyHeight + 100.0
        }
        return Const.enemyFlyHeight
    }
    

    var rushCount = 0
    var isRushing = false
    func kappaRush(){
        if isRushing || rushCount < 10 {
            return
        }
        rushCount = 0
        isRushing = true
        _ = CommonUtil.setTimeout(delay: 2.0, block: { () -> Void in
            self.isRushing = false
        })
        if abilityModel.canUse("rush_heal") {
            heal(kappa.beauty)
        }
        if abilityModel.canUse("rash_hado") {
            createHado()
        }
        updateSpecialView()
    }
    
    func canRush() -> Bool {
        return rushCount >= 10
    }
    
    func barRush() -> CGFloat {
        let BAR_LENGTH = 131.0
        var length = Double(rushCount)/Double(10)*BAR_LENGTH
        if length > BAR_LENGTH {
            length = BAR_LENGTH
        }
        return CGFloat(length)
    }
    
    /***********************************************************************************/
    /********************************** 衝突判定        *********************************/
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
            if bossStopFlag {
                return
            }
            if secondBody.categoryBitMask & Const.fireCategory != 0 {
                if jobModel.name != "gundom" {
                    let fire = secondBody.node as! FireEmitterNode
                    attacked(attack: fire.damage, point: (firstBody.node?.position)!)
                    makeSpark(point: (secondBody.node?.position)!)
                    secondBody.node?.removeFromParent()
                }
            } else if secondBody.categoryBitMask & Const.thunderCategory != 0 {
                let thunder = secondBody.node as! ThunderEmitterNode
                attacked(attack: thunder.damage, point: (firstBody.node?.position)!)
                makeSpark(point: (secondBody.node?.position)!)
                secondBody.node?.removeFromParent()
            } else if secondBody.categoryBitMask & Const.busterEnemyCategory != 0 {
                let buster = secondBody.node as! EnemyBusterNode
                attacked(attack: buster.str, point: (firstBody.node?.position)!)
                makeSpark(point: (secondBody.node?.position)!)
                secondBody.node?.removeFromParent()
            } else if secondBody.categoryBitMask & Const.enemyCategory != 0 {
                let enemy = secondBody.node as! EnemyNode
                if enemy.isDead {
                    return
                }
                // 敵の攻撃
                if enemy.isAttacking && !(isRushing && abilityModel.canUse("rush_muteki")) {
                    attacked(attack: enemy.str, point: (firstBody.node?.position)!)
                    makeSpark(point: (firstBody.node?.position)!)
                }
                
                // カッパの反撃
                if isRushing {
                    let damage = CommonUtil.minimumRnd(kappa.agi + kappa.int + kappa.str)
                    attackCalculate(str: damage, type: "physic", enemy: enemy)
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
            }
        } else if firstBody.categoryBitMask & Const.busterCategory != 0 {
            if secondBody.categoryBitMask & Const.enemyCategory != 0 {
                let enemy = secondBody.node as! EnemyNode
                if enemy.isDead {
                    return
                }
                makeSpark(point: (secondBody.node?.position)!)
                attackCalculate(str: busterDamage(), type: "beauty", enemy: enemy)
                
                // 貫通スキルがなければ消滅
                if !abilityModel.canUse("buster_penetrate") {
                    firstBody.node?.removeFromParent()
                }
            }
        }
    }
    
    func busterDamage() -> Int {
        var damage = kappa.beauty
        if abilityModel.canUse("buster_slow") {
            damage += 2
        }
        if abilityModel.canUse("buster_big") {
            damage += 1
        }
        return damage
    }
    
    
    /***********************************************************************************/
    /********************************** touch ******************************************/
    /***********************************************************************************/
    override func touchDown(atPoint pos : CGPoint) {
        if gameOverFlag || bossStopFlag || (!abilityModel.canUse("rush_muteki") && isRushing){
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
                if map.isBoss && world_name == "hiyoko" {
                    beatBoss()
                } else {
                    goMenu()
                }
            case "IconKappaBuster":
                kappaBuster()
            case "IconKappaJump":
                kappaJump()
            case "IconKappaRush":
                kappaRush()
            case "specialBack", "IconNotKappaRush":
                break
            default:
                self.touchDown(atPoint: positionInScene)
            }
        }
    }

    
    /***********************************************************************************/
    /********************************** フレーム処理    **********************************/
    /***********************************************************************************/
    // 秒ごとの処理
    override func secondTimerExec(){
        if abilityModel.canUse("time_heal") {
            heal(1)
        }
        enemyAction()
    }

    // フレーム毎の処理
    override func frameExec(){
        if isRushing {
            kappa.punchRush()
        }
        
        for enemy in enemyModel.enemies {
            if enemy.isDead {
                continue
            }
            enemy.position.x += CGFloat(enemy.dx)
            enemy.position.y += CGFloat(enemy.dy)
        }
    }

    // モンスターが1秒おきに実行する処理
    override func enemyAction(){
        for enemy in enemyModel.enemies {
            if enemy.isDead {
                continue
            }
            enemy.timerUp()
            if enemy.isAttack() {
                enemy.normalAttack(actionModel)
            } else if enemy.isFire() {
                showSkillBox("ファイアボール")
                if !enemy.isMovingFree {
                    enemy.run(actionModel.enemyJump!)
                }
                enemy.makeFire()
                enemy.fire.position = CGPoint(x: enemy.position.x, y: enemy.position.y + 40 )
                self.addChild(enemy.fire)
                enemy.fire.shot()
                enemy.fireTimerReset()
            } else if enemy.isThunder() {
                showSkillBox("黒き雷")
                createThunder(pos: enemy.pos - 1, damage: enemy.int)
                createThunder(pos: enemy.pos - 2, damage: enemy.int)
                createThunder(pos: enemy.pos - 3, damage: enemy.int)
                enemy.thunderTimerReset()
            } else if enemy.isArrow() {
                showSkillBox("アローレイン")
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
                showSkillBox("死霊召喚")
                makeDeath(position: enemy.position)
                enemy.deathTimerReset()
            } else if enemy.isLazer() {
                showSkillBox("ヨルのかまいたち")
                makeLazer(enemy.int)
                enemy.lazerTimerReset()
            } else if enemy.isBuster() {
                createEnemyBuster(enemy)
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
            }
            
            // 移動制限
            if enemy.canFly && !enemy.isMovingFree && enemy.position.y > kappa_first_position_y + 250 {
                enemy.physicsBody?.velocity = CGVector(dx:0, dy:0)
            }
        }
    }

}

