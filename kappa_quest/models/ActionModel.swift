// SKAction の sequence を定義
import SpriteKit
import Foundation

class ActionModel {
    
    let HIGH_JUMP_SPACE : CGFloat = 60.0
    let HIGH_JUMP_SPEED : TimeInterval = 0.1

    
    var moveSpace : CGFloat = 0.0

    var attack            : SKAction!
    var moveRight         : SKAction!
    var moveLeft          : SKAction!
    var speedMoveRight    : SKAction!
    var speedMoveLeft     : SKAction!
    var moveBack          : SKAction!
    var moveBack2         : SKAction!
    var dead              : SKAction!
    var displayDamage     : SKAction!
    var displayDamaged    : SKAction!
    var displayHeal       : SKAction!
    var displayExp        : SKAction!
    var displayMessage    : SKAction!
    var displayBigMessage : SKAction!
    var moveButton        : SKAction!
    var fadeInOut         : SKAction!
    var fadeOutQuickly    : SKAction!
    var fadeOutEternal    : SKAction!
    var enemyJump         : SKAction!
    var enemyMiniJump     : SKAction!
    var normalAttack      : SKAction!
    var highJump          : SKAction!
    var sparkFadeOut      : SKAction!
    
    func setActionData(sceneWidth : CGFloat){
        moveSpace = sceneWidth/7.0/4.0
        
        // 攻撃アクション
        attack = SKAction.sequence([
            SKAction.moveBy(x: moveSpace*2, y: 0, duration: 0.1),
            SKAction.moveBy(x: -1*moveSpace*2, y: 0, duration: 0.1),
        ])
        
        // 移動
        moveRight = SKAction.sequence([
            SKAction.moveBy(x: moveSpace, y:    Const.jumpSpace, duration: Const.moveSpeed),
            SKAction.moveBy(x: moveSpace, y: -1*Const.jumpSpace, duration: Const.moveSpeed),
            SKAction.moveBy(x: moveSpace, y:    Const.jumpSpace, duration: Const.moveSpeed),
            SKAction.moveBy(x: moveSpace, y: -1*Const.jumpSpace, duration: Const.moveSpeed),
        ])

        moveLeft = SKAction.sequence([
            SKAction.moveBy(x: -1*moveSpace, y:    Const.jumpSpace, duration: Const.moveSpeed),
            SKAction.moveBy(x: -1*moveSpace, y: -1*Const.jumpSpace, duration: Const.moveSpeed),
            SKAction.moveBy(x: -1*moveSpace, y:    Const.jumpSpace, duration: Const.moveSpeed),
            SKAction.moveBy(x: -1*moveSpace, y: -1*Const.jumpSpace, duration: Const.moveSpeed),
        ])
        
        speedMoveRight = SKAction.sequence([
            SKAction.moveBy(x: moveSpace, y:    0, duration: Const.moveSpeed/2.0),
            SKAction.moveBy(x: moveSpace, y:    0, duration: Const.moveSpeed/2.0),
            SKAction.moveBy(x: moveSpace, y:    0, duration: Const.moveSpeed/2.0),
            SKAction.moveBy(x: moveSpace, y:    0, duration: Const.moveSpeed/2.0),
        ])
        
        speedMoveLeft = SKAction.sequence([
            SKAction.moveBy(x: -1*moveSpace, y:    0, duration: Const.moveSpeed/2.0),
            SKAction.moveBy(x: -1*moveSpace, y:    0, duration: Const.moveSpeed/2.0),
            SKAction.moveBy(x: -1*moveSpace, y:    0, duration: Const.moveSpeed/2.0),
            SKAction.moveBy(x: -1*moveSpace, y:    0, duration: Const.moveSpeed/2.0),
            ])
        
        // 左に戻れない
        moveBack = SKAction.sequence([
            SKAction.moveBy(x: -1*moveSpace, y:    Const.jumpSpace, duration: Const.moveSpeed),
            SKAction.moveBy(x: -1*moveSpace, y: -1*Const.jumpSpace, duration: Const.moveSpeed),
            SKAction.moveBy(x: moveSpace, y:    Const.jumpSpace, duration: Const.moveSpeed),
            SKAction.moveBy(x: moveSpace, y: -1*Const.jumpSpace, duration: Const.moveSpeed),
        ])
        
        // 右に行けない
        moveBack2 = SKAction.sequence([
            SKAction.moveBy(x: moveSpace,       y:    Const.jumpSpace, duration: Const.moveSpeed),
            SKAction.moveBy(x: moveSpace,       y: -1*Const.jumpSpace, duration: Const.moveSpeed),
            SKAction.moveBy(x: -1*moveSpace,    y:    Const.jumpSpace, duration: Const.moveSpeed),
            SKAction.moveBy(x: -1*moveSpace,    y: -1*Const.jumpSpace, duration: Const.moveSpeed),
            ])

        
        
        // 死亡時（真上に飛び上がってから落ちていく）
        dead = SKAction.sequence([
            SKAction.moveBy(x: 0, y:    Const.jumpSpace * 5, duration: Const.moveSpeed*3),
            SKAction.moveBy(x: 0, y: -1*Const.jumpSpace * 30, duration: Const.moveSpeed*18),
        ])
        
        // ダメージ表示
        displayDamage = SKAction.sequence([
            SKAction.moveBy(x: 0, y:  70, duration: 0.1),
            SKAction.moveBy(x: 0, y: 70, duration: 0.5),
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeOut(withDuration: 0.1),
            SKAction.removeFromParent()
        ])
        
        displayDamaged = SKAction.sequence([
            SKAction.moveBy(x: -20, y:  70, duration: 0.1),
            SKAction.moveBy(x: -20, y: -40, duration: 0.1),
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeOut(withDuration: 0.1),
            SKAction.removeFromParent()
        ])
        
        displayHeal = SKAction.sequence([
            SKAction.moveBy(x: 0, y:  90, duration: 0.2),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ])
        
        displayExp = SKAction.sequence([
            SKAction.moveBy(x: 0, y:  70, duration: 0.2),
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeOut(withDuration: 0.1),
            SKAction.removeFromParent()
        ])
        
        // 右上のメッセージダイアログ表示
        displayMessage = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.1),
            SKAction.moveBy(x: -100, y:  0, duration: 0.1),
            SKAction.fadeOut(withDuration: 4.5)
        ])

        displayBigMessage = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.2),
            SKAction.wait(forDuration: 2.0),
            SKAction.fadeOut(withDuration: 4.5)
        ])

        moveButton = SKAction.sequence([
            SKAction.moveBy(x: 0, y: -250 , duration: 0.2),
            SKAction.wait(forDuration: 6.4),
            SKAction.moveBy(x: 0, y:  250 , duration: 0.1)
        ])

        // 少しだけ表示して消える(レベルアップ文字表示の時など)
        fadeInOut = SKAction.sequence([
            SKAction.fadeAlpha(to: 1.0, duration: 0.1),
            SKAction.fadeAlpha(to: 0.01, duration: 4.5)
        ])
        
        // 一定時間後に完全消滅
        // 少しだけ表示して消える
        fadeOutEternal = SKAction.sequence([
            SKAction.fadeOut(withDuration: 4.5),
            SKAction.removeFromParent()
        ])

        fadeOutQuickly = SKAction.sequence([
            SKAction.fadeOut(withDuration: 1.5),
            SKAction.removeFromParent()
        ])

        
        // 火花など、一瞬だけ出てfadeOut
        sparkFadeOut = SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.25),
            SKAction.removeFromParent()
        ])
        

        // 敵のジャンプ
        enemyJump = SKAction.sequence([
            SKAction.moveBy(x: 0, y:    Const.enemyJumpSpace, duration: Const.enemyJump),
            SKAction.moveBy(x: 0, y: -1*Const.enemyJumpSpace, duration: Const.enemyJump),
        ])
        
        // 敵のミニジャンプ
        enemyMiniJump = SKAction.sequence([
            SKAction.moveBy(x: 0, y:    Const.enemyJumpSpace/4, duration: Const.enemyJump),
            SKAction.moveBy(x: 0, y: -1*Const.enemyJumpSpace/4, duration: Const.enemyJump),
        ])

        // ノーマルアタック
        let attackSpace = sceneWidth/7.0/2.0
        normalAttack = SKAction.sequence([
            SKAction.moveBy(x: -1*attackSpace, y:    Const.normalAttackY, duration: Const.normalAttackSpeed),
            SKAction.moveBy(x: -1*attackSpace, y: -1*Const.normalAttackY, duration: Const.normalAttackSpeed),
            SKAction.removeFromParent()
        ])
        
        // 宝箱出現じ
        highJump = SKAction.sequence([
            SKAction.moveBy(x: 0, y:    HIGH_JUMP_SPACE, duration: HIGH_JUMP_SPEED),
            SKAction.moveBy(x: 0, y: -1*HIGH_JUMP_SPACE, duration: HIGH_JUMP_SPEED)
        ])

    }
    
    func enemyAttack(range: CGFloat) -> SKAction {
        let attack = SKAction.sequence([
            SKAction.moveBy(x: -2*moveSpace*range, y:  0, duration: Const.enemyJump),
            SKAction.moveBy(x:  2*moveSpace*range, y:  0, duration: Const.enemyJump),
        ])
    
        return attack
    }
    
}
