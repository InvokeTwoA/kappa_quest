// ゲーム画面
import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: GameBaseScene {
    
    // 章に応じて変数を上書き
    override func setBaseVariable(){
        chapter = 1
        prepareBGM(fileName: Const.bgm_fantasy)
    }
    
    override func bossExec(){
        stopBGM()
        if world_name == "dark_kappa" {
            prepareBGM(fileName: Const.bgm_bit_cry)
        } else {
            prepareBGM(fileName: Const.bgm_last_battle)
        }
        playBGM()
    }
    
    /***********************************************************************************/
    /********************************** specialAttack **********************************/
    /***********************************************************************************/
    // スーパー頭突き
    override func specialAttackHead(){
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
    override func specialAttackUpper(){
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
    override func specialAttackTornado(){
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
    override func specialAttackHado(){
        kappa.hado()
        heal(skillModel.hado_heal)
        specialAttackModel.execHado()
        createHado()
        specialAttackModel.finishAttack()
    }
    
    override func updateSpecialView(){
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
            case "specialBack", "IconNotKappaUpper", "IconNotKappaHead", "IconNotKappaTornado", "IconNotKappaHado":
                break
            default:
                self.touchDown(atPoint: positionInScene)
            }
            updateSpecialView()
        }
    }    
    
    /***********************************************************************************/
    /********************************** フレーム処理    **********************************/
    /***********************************************************************************/
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
                enemy.run(SKAction.moveBy(x: CGFloat(enemy.dx), y: CGFloat(enemy.dy) , duration: 1.0))
            }
            
            // 移動制限
            if enemy.canFly && !enemy.isMovingFree && enemy.position.y > kappa_first_position_y + 250 {
                enemy.physicsBody?.velocity = CGVector(dx:0, dy:0)
            }
        }
    }

}
