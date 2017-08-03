// SKAction の sequence を定義
import SpriteKit
import Foundation

class ActionModel {

    var attackSequence          : SKAction?
    var moveRightSequence       : SKAction?
    var moveLeftSequence        : SKAction?
    var displayDamageSequence   : SKAction?
    var displayMessageSequence  : SKAction?
    var fadeInOutSequence       : SKAction?
    
    func setActionData(sceneWidth : CGFloat){
        
        // 攻撃アクション
        attackSequence = SKAction.sequence([
            SKAction.moveBy(x: 20, y: 0, duration: 0.1),
            SKAction.moveBy(x: -20, y: 0, duration: 0.1),
        ])
        
        // 移動
        let moveSpace = sceneWidth/7.0/4.0
        moveRightSequence = SKAction.sequence([
            SKAction.moveBy(x: moveSpace, y:    Const.jumpSpace, duration: Const.moveSpeed),
            SKAction.moveBy(x: moveSpace, y: -1*Const.jumpSpace, duration: Const.moveSpeed),
            SKAction.moveBy(x: moveSpace, y:    Const.jumpSpace, duration: Const.moveSpeed),
            SKAction.moveBy(x: moveSpace, y: -1*Const.jumpSpace, duration: Const.moveSpeed),
        ])
        moveLeftSequence = SKAction.sequence([
            SKAction.moveBy(x: -1*moveSpace, y:    Const.jumpSpace, duration: Const.moveSpeed),
            SKAction.moveBy(x: -1*moveSpace, y: -1*Const.jumpSpace, duration: Const.moveSpeed),
            SKAction.moveBy(x: -1*moveSpace, y:    Const.jumpSpace, duration: Const.moveSpeed),
            SKAction.moveBy(x: -1*moveSpace, y: -1*Const.jumpSpace, duration: Const.moveSpeed),
        ])
        
        // ダメージ表示
        displayDamageSequence = SKAction.sequence([
            SKAction.moveBy(x: 20, y:  70, duration: 0.1),
            SKAction.moveBy(x: 20, y: -40, duration: 0.1),
            SKAction.fadeOut(withDuration: 0.5)
        ])
        
        // 右上のメッセージダイアログ表示
        displayMessageSequence = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.1),
            SKAction.moveBy(x: -100, y:  0, duration: 0.1),
            SKAction.fadeOut(withDuration: 4.5)
        ])
        
        // 少しだけ表示して消える
        fadeInOutSequence = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.1),
            SKAction.fadeOut(withDuration: 4.5)
            ])
        
        
    }
}
