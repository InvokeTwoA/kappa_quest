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
}
