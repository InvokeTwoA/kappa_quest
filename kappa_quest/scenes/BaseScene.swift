// 親クラス
// 共通用のメソッドなどを記載
import Foundation
import SpriteKit
import GameplayKit

class BaseScene: SKScene {

    // メッセージダイアログを表示
    func displayAlert(_ title: String, message: String, okString: String){
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let defaultAction = UIAlertAction(title: okString, style: .default, handler: nil)
        alert.addAction(defaultAction)
        self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
}
