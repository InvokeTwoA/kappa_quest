import Foundation


class EnemyModel {

    var enemies : Array<EnemyNode> = [EnemyNode(),EnemyNode(),EnemyNode(),EnemyNode(),EnemyNode(),EnemyNode(),EnemyNode(),EnemyNode(),EnemyNode()]
    var enemiesData = NSDictionary()

    func readDataByPlist(){
        let enemiesDataPath = Bundle.main.path(forResource: "enemies", ofType:"plist" )!
        enemiesData = NSDictionary(contentsOfFile: enemiesDataPath)!
    }

    func getRnadomEnemy(_ enemyList : [String], lv : Int) -> EnemyNode {
        let enemy_name = enemyList[CommonUtil.rnd(enemyList.count)]

        let enemyNode = EnemyNode.makeEnemy(name: enemy_name)
        enemyNode.setParameterByDictionary(dictionary: enemiesData.object(forKey: enemy_name) as! NSDictionary, set_lv : lv)
        return enemyNode
    }

    func getEnemy(enemy_name: String, lv : Int) -> EnemyNode {
        let enemyNode = EnemyNode.makeEnemy(name: enemy_name)
        enemyNode.setParameterByDictionary(dictionary: enemiesData.object(forKey: enemy_name) as! NSDictionary, set_lv : lv)
        return enemyNode
    }

    func resetEnemies(){
        enemies = [EnemyNode(),EnemyNode(),EnemyNode(),EnemyNode(),EnemyNode(),EnemyNode(),EnemyNode(),EnemyNode(),EnemyNode()]
    }

    class func getData(_ key : String) -> NSDictionary {
        let enemiesDataPath = Bundle.main.path(forResource: "enemies", ofType:"plist" )!
        let enemiesData = NSDictionary(contentsOfFile: enemiesDataPath)!
        let data = enemiesData.object(forKey: key) as! NSDictionary
        return data
    }

    class func displayStatus(_ key : String) -> String{
        let dictionary = getData(key)
        hp      = dictionary.object(forKey: "hp") as! Int
        str     = dictionary.object(forKey: "str") as! Int
        def     = dictionary.object(forKey: "def") as! Int
        agi     = dictionary.object(forKey: "agi") as! Int
        int     = dictionary.object(forKey: "int") as! Int
        pie     = dictionary.object(forKey: "pie") as! Int
        range   = Double(dictionary.object(forKey: "range") as! CGFloat)

        var text =  "HP : \(hp)\n"
        var text += "物理攻撃力 : \(str)\n"
        var text += "物理防御力 : \(def)\n"
        var text += "特殊攻撃力 : \(int)\n"
        var text += "特殊防御力 : \(pie)\n"
        var text += "行動の速度 : \(agi)\n"
        var text += "攻撃の射程 : \(range)"
        return text
    }

}
