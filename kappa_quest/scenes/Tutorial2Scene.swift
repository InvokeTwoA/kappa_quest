/* チュートリアル2画面 */
import SpriteKit
import GameplayKit

class Tutorial2Scene: BaseScene {
    
    private var kappa : KappaNode!
    private var actionModel : ActionModel = ActionModel()
    private var enemy_hp = 10
    
    override func sceneDidLoad() {
        setKappa()
        actionModel.setActionData(sceneWidth: size.width)
        prepareSoundEffect()
        
    }
    
    func setKappa(){
        kappa = childNode(withName: "//kappa") as! KappaNode
        kappa.setPhysic()
    }
    
    func goNextMap(){
        let nextScene = Tutorial3Scene(fileNamed: "Tutorial3Scene")!
        nextScene.size = nextScene.size
        nextScene.scaleMode = SKSceneScaleMode.aspectFit
        view!.presentScene(nextScene, transition: .fade(withDuration: Const.transitionInterval))
    }
    
    private var kappa_position = 1
    private var isMoving = false
    func moveRight(){
        if isMoving {
            return
        }
        isMoving = true
        kappa_position += 1
        
        kappa.walkRight()
        kappa.run(actionModel.moveRight!, completion: {() -> Void in
            if self.kappa_position == Const.maxPosition {
                self.goNextMap()
            }
            self.isMoving = false
        })
    }
    
    func moveLeft(){
        if isMoving {
            return
        }
        isMoving = true
        kappa_position -= 1
        
        kappa.walkLeft()
        kappa.run(actionModel.moveLeft!, completion: {() -> Void in
            self.isMoving = false
        })
    }
    
    // ダメージを数字で表示
    func displayDamage(value: String, point: CGPoint){
        let location = CGPoint(x: point.x, y: point.y + 30.0)
        let label = SKLabelNode(fontNamed: Const.damageFont)
        label.name = "damage_text"
        label.text = value
        label.fontSize = Const.damageFontSize - 5
        label.position = location
        label.fontColor = .white
        label.zPosition = 90
        label.alpha = 0.9
        addChild(label)
        
        let bg_label = SKLabelNode(fontNamed: Const.damageFont)
        bg_label.name = "bg_damage_text"
        bg_label.position = location
        bg_label.fontColor = .black
        bg_label.text = "\(value)"
        bg_label.fontSize = Const.damageFontSize
        bg_label.zPosition = 89
        addChild(bg_label)
        
        label.run(actionModel.displayDamage!)
        bg_label.run(actionModel.displayDamage!)
    }
    
    
    func attack(){
        kappa.attack()
        kappa.run(actionModel.attack!)
        
        let enemy = childNode(withName: "//enemy") as! EnemyNode
        for _ in 0...2 {
            makeSpark(point: enemy.position)
        }
        enemy_hp -= 1
        displayDamage(value: "1", point: enemy.position)
        
        playSoundEffect(type: 3)
        
        if enemy_hp <= 0 {
            enemy.setPhysic()
            enemy.setBeatPhysic()
        }
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let positionInScene = t.location(in: self)
            touchDown(atPoint: positionInScene)
            
            let tapNode = self.atPoint(positionInScene)
            if tapNode.name == nil {
                self.touchDown(atPoint: positionInScene)
                return
            }
            switch tapNode.name! {
            case "SkipNode", "SkipLabel":
                goNextMap()
            default:
                self.touchDown(atPoint: positionInScene)
            }
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if pos.x >= 0 {
            if kappa_position == 3 && enemy_hp > 0 {
                attack()
            } else {
                moveRight()
            }
        } else {
            if kappa_position != 1 {
                moveLeft()
            } else {
                kappa!.run(actionModel.moveBack!)
            }
        }
    }
    
    private var lastUpdateTime : TimeInterval = 0
    private var doubleTimer = 0.0 // 経過時間（小数点単位で厳密）
    override func update(_ currentTime: TimeInterval) {
        if enemy_hp <= 0 {
            return
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
        
        let enemy = childNode(withName: "//enemy") as! EnemyNode
        enemy.timerUp()
        if enemy.isAttack() {
            enemy.normalAttack(actionModel)
        } else if enemy.jumpTimer%4 == 0 {
            enemy.run(actionModel.enemyMiniJump!)
            enemy.jumpTimerReset()
        }
    }
}
