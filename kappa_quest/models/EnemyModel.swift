import Foundation


class EnemyModel {

    var enemies : Array<EnemyNode> = [EnemyNode(),EnemyNode(),EnemyNode(),EnemyNode(),EnemyNode(),EnemyNode(),EnemyNode(),EnemyNode(),EnemyNode()]
    var enemiesData = NSDictionary()

    func readDataByPlist(){
        let enemiesDataPath = Bundle.main.path(forResource: "enemies", ofType:"plist" )!
        enemiesData = NSDictionary(contentsOfFile: enemiesDataPath)!
    }
    
    func getRnadomEnemy() -> EnemyNode {
        let enem = ["hiyoko", "skelton", "miira", "angel", "maou"]
        let enemy_name = enem[CommonUtil.minimumRnd(enem.count)]
        
        let enemyNode = EnemyNode.makeEnemy(name: enemy_name)
        enemyNode.setParameterByDictionary(dictionary: enemiesData.object(forKey: enemy_name) as! NSDictionary)
        return enemyNode
    }

}
