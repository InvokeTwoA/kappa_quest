// モンスターの情報を格納したモデル
import Foundation
class EnemyModel {

    var enemies : Array<EnemyNode> = [EnemyNode(),EnemyNode(),EnemyNode(),EnemyNode(),EnemyNode(),EnemyNode(),EnemyNode(),EnemyNode(),EnemyNode()]
    var enemiesData = NSDictionary()

    func readDataByPlist(_ chapter : Int){
        let enemiesDataPath = Bundle.main.path(forResource: "enemies_chapter\(chapter)", ofType:"plist" )!
        enemiesData = NSDictionary(contentsOfFile: enemiesDataPath)!
    }

    func getRnadomEnemy(_ enemyList : [String], lv : Int) -> EnemyNode {
        let enemy_name = enemyList[CommonUtil.rnd(enemyList.count)]
        let enemy_data = enemiesData.object(forKey: enemy_name) as! NSDictionary
        let enemyNode = EnemyNode.makeEnemy(name: enemy_name, enemy_data: enemy_data)
        return enemyNode
    }

    func getEnemy(enemy_name: String) -> EnemyNode {
        let enemy_data = enemiesData.object(forKey: enemy_name) as! NSDictionary
        let enemyNode = EnemyNode.makeEnemy(name: enemy_name, enemy_data: enemy_data)
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
        let hp      = dictionary.object(forKey: "hp") as! Int
        let str     = dictionary.object(forKey: "str") as! Int
        let def     = dictionary.object(forKey: "def") as! Int
        let agi     = dictionary.object(forKey: "agi") as! Int
        let int     = dictionary.object(forKey: "int") as! Int
        let pie     = dictionary.object(forKey: "pie") as! Int
        let range   = dictionary.object(forKey: "range") as! Double

        var text  =  "HP : \(hp)\n"
        text += "物理攻撃力 : \(str)\n"
        text += "物理防御力 : \(def)\n"
        text += "特殊攻撃力 : \(int)\n"
        text += "特殊防御力 : \(pie)\n"
        text += "行動の速度 : \(agi)\n"
        text += "攻撃の射程 : \(range)"
        return text
    }
}
