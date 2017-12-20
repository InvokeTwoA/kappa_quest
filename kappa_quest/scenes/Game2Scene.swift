// ゲーム画面
import SpriteKit
import GameplayKit
import AVFoundation

class Game2Scene: GameBaseScene {
    private var abilityMoedl = AbilityModel()
    
    // 章に応じて変数を上書き
    override func setBaseVariable(){
        chapter = 2
        abilityMoedl.setFlag()
        prepareBGM(fileName: Const.bgm_brave)
    }
    
    // ２章では「かっこよさ」以上に回復しない
    override func heal(_ heal_val : Int){
        if heal_val <= 0 {
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
        if abilityMoedl.shukuchi2Flag {
            return actionModel.speedMaxMoveRight
        } else if abilityMoedl.shukuchiFlag {
            return actionModel.speedMoveRight
        } else {
            return actionModel.moveRight
        }
    }

    override func getMoveActionLeft() -> SKAction {
        if abilityMoedl.shukuchi2Flag {
            return actionModel.speedMaxMoveLeft
        } else if abilityMoedl.shukuchiFlag {
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

    
    /***********************************************************************************/
    /********************************** specialAttack **********************************/
    /***********************************************************************************/
    // カッパバスター
    override func kappaBuster(){
        kappa.hado()
        createBuster()
        if abilityMoedl.busterHealFlag {
            heal(1)
        }
    }
    
    func createBuster(){
        var BUSTER_RADIUS : CGFloat = 16.0
        
        if abilityMoedl.busterBigFlag {
            BUSTER_RADIUS = 32.0
        }
        
        let circle = SKShapeNode(circleOfRadius: BUSTER_RADIUS)
        circle.physicsBody = busterPhysic(BUSTER_RADIUS)
        circle.fillColor = UIColor.yellow
        circle.position = CGPoint(x: kappa.position.x, y: kappa.position.y + 40)
        circle.zPosition = 12
        self.addChild(circle)

        var BUSTER_LONG : CGFloat = 300.0
        if abilityMoedl.busterLongFlag {
            BUSTER_LONG = 600.0
        }        
        let busterAction = SKAction.sequence([
            SKAction.moveBy(x: BUSTER_LONG, y: 0, duration: 0.5),
            SKAction.removeFromParent()
        ])
        circle.run(busterAction)
    }
    
    func busterPhysic(_ r : CGFloat) -> SKPhysicsBody {
        //let physics = SKPhysicsBody(circleOfRadius: r)
        let physics = SKPhysicsBody(rectangleOf: CGSize(width: r*2.0, height: r*2.0))
        physics.categoryBitMask = Const.busterCategory
        physics.contactTestBitMask = Const.enemyCategory
        physics.collisionBitMask = 0
        physics.affectedByGravity = false
        return physics
    }
    
    override func updateSpecialView(){
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
        if abilityMoedl.jumpPlusFlag {
            JUMP_STOP = 0.6
        }
        
        let jumpAction = SKAction.sequence([
            SKAction.moveBy(x: 0, y: Const.enemyFlyHeight, duration: JUMP_DURATION),
            SKAction.wait(forDuration: JUMP_STOP),
            SKAction.moveBy(x: 0, y: -1*Const.enemyFlyHeight, duration: JUMP_DURATION),
            ])
        kappa.run(jumpAction)
        
        let TOTAL_DURATION = JUMP_DURATION*2.0 + JUMP_STOP
        _ = CommonUtil.setTimeout(delay: TOTAL_DURATION, block: { () -> Void in
            self.jumpFlag = false
        })
        
        if abilityMoedl.jumpHealFlag {
            heal(kappa.beauty)
        }
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
        } else if firstBody.categoryBitMask & Const.busterCategory != 0 {
            if secondBody.categoryBitMask & Const.enemyCategory != 0 {
                let enemy = secondBody.node as! EnemyNode
                if enemy.isDead {
                    return
                }
                makeSpark(point: (secondBody.node?.position)!)
                attackCalculate(str: kappa.beauty, type: "beauty", enemy: enemy)
                
                // 貫通スキルがなければ消滅
                if !abilityMoedl.busterPenetrateFlag {
                    firstBody.node?.removeFromParent()
                }
            }
        }
    }
    
    
    /***********************************************************************************/
    /********************************** touch ******************************************/
    /***********************************************************************************/
    override func touchDown(atPoint pos : CGPoint) {
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
                if map.isBoss && world_name == "hiyoko" {
                    beatBoss()
                } else {
                    goMenu()
                }
            case "IconKappaBuster":
                kappaBuster()
            case "IconKappaJump":
                kappaJump()
            default:
                self.touchDown(atPoint: positionInScene)
            }
            updateSpecialView()
        }
    }

    
    /***********************************************************************************/
    /********************************** フレーム処理    **********************************/
    /***********************************************************************************/
    // 秒ごとの処理
    override func secondTimerExec(){
        if abilityMoedl.timeHealFlag {
            heal(1)
        }
    }

    
    // フレーム毎の処理
    override func frameExec(){
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

