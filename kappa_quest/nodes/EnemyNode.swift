import Foundation
import SpriteKit

class EnemyNode: SKSpriteNode {
    
    var hp = 10
    var str = 1
    var def = 1
    var agi = 1
    var pie = 1
    var exp = 1
    var isMagic = false
    var displayName = "敵"
    
    class func makeEnemy(name : String) -> EnemyNode {
        let enemy = EnemyNode(imageNamed: name)
        enemy.size = CGSize(width: Const.enemySize, height: Const.enemySize)
        enemy.anchorPoint = CGPoint(x: 0.5, y: 0)     // 中央下がアンカーポイント
        enemy.zPosition = 2
        return enemy
    }
    
    func setParameterByDictionary(dictionary : NSDictionary){
        displayName = dictionary.object(forKey: "name") as! String
        hp      = dictionary.object(forKey: "hp") as! Int
        str     = dictionary.object(forKey: "str") as! Int
        def     = dictionary.object(forKey: "def") as! Int
        agi     = dictionary.object(forKey: "agi") as! Int
        pie     = dictionary.object(forKey: "pie") as! Int
        exp     = dictionary.object(forKey: "exp") as! Int
        isMagic = dictionary.object(forKey: "isMagic") as! Bool
    }
    
    // 上下移動
    

}
