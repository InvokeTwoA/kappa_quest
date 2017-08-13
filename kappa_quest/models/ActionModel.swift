// SKAction の sequence を定義
import SpriteKit
import Foundation

class ActionModel {

    var attack          : SKAction?
    var moveRight       : SKAction?
    var moveLeft        : SKAction?
    var displayDamage   : SKAction?
    var displayMessage  : SKAction?
    var fadeInOut       : SKAction?
    var fadeOutEternal  : SKAction?
    var swordSlash      : SKAction?
    var enemyJump       : SKAction?
    var normalAttack    : SKAction?
    var sparkFadeOut    : SKAction?

    
    func setActionData(sceneWidth : CGFloat){
        
        // 攻撃アクション
        attack = SKAction.sequence([
            SKAction.moveBy(x: 20, y: 0, duration: 0.1),
            SKAction.moveBy(x: -20, y: 0, duration: 0.1),
        ])
        
        // 移動
        let moveSpace = sceneWidth/7.0/4.0
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
        
        // ダメージ表示
        displayDamage = SKAction.sequence([
            SKAction.moveBy(x: 20, y:  70, duration: 0.1),
            SKAction.moveBy(x: 20, y: -40, duration: 0.1),
            SKAction.fadeOut(withDuration: 0.5)
        ])
        
        // 右上のメッセージダイアログ表示
        displayMessage = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.1),
            SKAction.moveBy(x: -100, y:  0, duration: 0.1),
            SKAction.fadeOut(withDuration: 4.5)
        ])
        
        // 少しだけ表示して消える
        fadeInOut = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.1),
            SKAction.fadeOut(withDuration: 4.5)
        ])
        
        // 一定時間後に完全消滅
        // 少しだけ表示して消える
        fadeOutEternal = SKAction.sequence([
            SKAction.fadeOut(withDuration: 4.5),
            SKAction.removeFromParent()
        ])
        
        // 火花など、一瞬だけ出てfadeOut
        sparkFadeOut = SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.25),
            SKAction.removeFromParent()
            ])
        
        
        // 剣を振るアクション
        let angle = CGFloat.pi/2.0
        swordSlash = SKAction.sequence([
            SKAction.rotate( byAngle: -1.0*angle, duration: Const.swordSpeed),
            SKAction.rotate( byAngle:      angle, duration: Const.swordSpeed),
        ])

        // 敵のジャンプ
        enemyJump = SKAction.sequence([
            SKAction.moveBy(x: 0, y:    Const.enemyJumpSpace, duration: Const.enemyJump),
            SKAction.moveBy(x: 0, y: -1*Const.enemyJumpSpace, duration: Const.enemyJump),
        ])
        
        // ノーマルアタック
        let attackSpace = sceneWidth/7.0/2.0
        normalAttack = SKAction.sequence([
            SKAction.moveBy(x: -1*attackSpace, y:    Const.normalAttackY, duration: Const.normalAttackSpeed),
            SKAction.moveBy(x: -1*attackSpace, y: -1*Const.normalAttackY, duration: Const.normalAttackSpeed),
            SKAction.removeFromParent()
        ])
        
    }
}
