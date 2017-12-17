// ゲーム画面
import SpriteKit
import GameplayKit
import AVFoundation

class Game2Scene: GameBaseScene {
    
    // 章に応じて変数を上書き
    override func setBaseVariable(){
        chapter = 2        
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
    
    
    
    
    

    // フレーム毎の処理
    override func frameExec(){
        for enemy in enemyModel.enemies {
            if enemy.isDead {
                continue
            }
            enemy.position.x = enemy.position.x + CGFloat(enemy.dx)
            enemy.position.y = enemy.position.y + CGFloat(enemy.dy)
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
                
//                enemy.run(SKAction.moveBy(x: CGFloat(enemy.dx), y: CGFloat(enemy.dy) , duration: 1.0))
            }
            
            // 移動制限
            if enemy.canFly && !enemy.isMovingFree && enemy.position.y > kappa_first_position_y + 250 {
                enemy.physicsBody?.velocity = CGVector(dx:0, dy:0)
            }
        }
    }

}

