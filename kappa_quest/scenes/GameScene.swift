// ゲーム画面
import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate, AVAudioPlayerDelegate {
    
    // 音楽
    var _audioPlayer:AVAudioPlayer!
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    private var lastUpdateTime : TimeInterval = 0

    // 各種モデル
    private var gameData : GameData = GameData()
    private var map : Map = Map()
    private var enemyModel : EnemyModel = EnemyModel()
    private var actionModel : ActionModel = ActionModel()
    var jobModel : JobModel = JobModel()

    // ラベル定義
    private var LVLabel : SKLabelNode?
    private var MAXHPLabel : SKLabelNode?
    private var HPLabel : SKLabelNode?
    private var StrLabel : SKLabelNode?
    private var DefLabel : SKLabelNode?
    private var AgiLabel : SKLabelNode?
    private var IntLabel : SKLabelNode?
    private var PieLabel : SKLabelNode?
    private var LucLabel : SKLabelNode?
    private var HPUpLabel : SKLabelNode?
    private var StrUpLabel : SKLabelNode?
    private var DefUpLabel : SKLabelNode?
    private var AgiUpLabel : SKLabelNode?
    private var IntUpLabel : SKLabelNode?
    private var PieUpLabel : SKLabelNode?
    private var LucUpLabel : SKLabelNode?
    private var ExpLabel : SKLabelNode?
    
    private var JobLVLabel : SKLabelNode?
    private var JobNameLabel : SKLabelNode?
    private var DistanceLabel: SKLabelNode?
    private var TapCountLabel: SKLabelNode?
    private var ButtonLabel: SKLabelNode?
    private var MessageLabel: SKLabelNode?
    
    // Node
    private var tapNode : TapNode?  // タップ時に発生するノード
    var kappa : KappaNode?   // かっぱ画像
    private var sword : SwordNode?   // 剣
    private var underground : SKShapeNode?   // 地面
    private var MessageNode : SKShapeNode?   // メッセージノード

    private var isMoving = false  // 移動中かどうか
    
    private var isSceneDidLoaded = false
    
    override func sceneDidLoad() {
        // 二重読み込みの防止
        if isSceneDidLoaded {
            return
        } else {
            isSceneDidLoaded = true
        }

        self.lastUpdateTime = 0
        
        // 音楽関係の処理
        prepareBGM(fileName: Const.bgm_last_battle)
        playBGM()
        
        // データをセット
        enemyModel.readDataByPlist()
        jobModel.readDataByPlist()
        jobModel.loadParam()
        actionModel.setActionData(sceneWidth: self.size.width)
        createKappa()
        createMap()
        gameData.setParameterByUserDefault()
        map.setParameterByUserDefault()
        setLabel()
        createTapNode()
        setInitData()
        updateStatus()
        
        showMessage("冒険の始まりだ！")
    }
    
    func setInitData(){
        TapCountLabel?.text = "\(gameData.tapCount)"
    }
    
    func setLabel(){
        LVLabel        = self.childNode(withName: "//LVLabel") as? SKLabelNode
        HPLabel        = self.childNode(withName: "//HPLabel") as? SKLabelNode
        StrLabel       = self.childNode(withName: "//StrLabel") as? SKLabelNode
        DefLabel       = self.childNode(withName: "//DefLabel") as? SKLabelNode
        AgiLabel       = self.childNode(withName: "//AgiLabel") as? SKLabelNode
        IntLabel       = self.childNode(withName: "//IntLabel") as? SKLabelNode
        PieLabel       = self.childNode(withName: "//PieLabel") as? SKLabelNode
        LucLabel       = self.childNode(withName: "//LucLabel") as? SKLabelNode
        HPUpLabel      = self.childNode(withName: "//HPUpLabel") as? SKLabelNode
        StrUpLabel     = self.childNode(withName: "//StrUpLabel") as? SKLabelNode
        DefUpLabel     = self.childNode(withName: "//DefUpLabel") as? SKLabelNode
        AgiUpLabel     = self.childNode(withName: "//AgiUpLabel") as? SKLabelNode
        IntUpLabel     = self.childNode(withName: "//IntUpLabel") as? SKLabelNode
        PieUpLabel     = self.childNode(withName: "//PieUpLabel") as? SKLabelNode
        LucUpLabel     = self.childNode(withName: "//LucUpLabel") as? SKLabelNode
        ExpLabel       = self.childNode(withName: "//ExpLabel") as? SKLabelNode

        JobLVLabel     = self.childNode(withName: "//JobNameLabel") as? SKLabelNode
        JobNameLabel   = self.childNode(withName: "//JobLVLabel") as? SKLabelNode
        DistanceLabel  = self.childNode(withName: "//DistanceLabel") as? SKLabelNode
        TapCountLabel  = self.childNode(withName: "//TapCountLabel") as? SKLabelNode
        ButtonLabel    = self.childNode(withName: "//ButtonLabel") as? SKLabelNode
        MessageLabel   = self.childNode(withName: "//MessageLabel") as? SKLabelNode
        
        MessageNode    = self.childNode(withName: "//MessageNode") as? SKShapeNode
    }

    // かっぱ画像にphysic属性を与える
    func createKappa(){
        self.kappa = self.childNode(withName: "//kappa") as? KappaNode
        kappa?.setParameterByUserDefault()
        kappa?.setPhysic()
        setFirstPosition()
        sword = self.childNode(withName: "//Sword") as? SwordNode
        sword?.setSwordByKappa(kappa_x: (self.kappa?.position.x)!)
    }
    
    // 左からpos番目のx座標を返す
    func getPositionX(_ pos : Int) -> CGFloat {
        let position = CGFloat(pos)/7.0-1.0/2.0
        return self.size.width*position
    }
    
    // カッパを初期ポジションに設置
    func setFirstPosition(){
        map.myPosition = 1
        kappa?.position.x = getPositionX(1)
    }
    
    // カッパを右端ポジションに設置
    func setRightPosition(){
        map.myPosition = Const.maxPosition - 1
        kappa?.position.x = getPositionX(Const.maxPosition - 1)
    }
    
    // タップ時に発生させるノード作成（初回のみ１回）
    func createTapNode(){
        let size = (self.size.width + self.size.height) * 0.005
        tapNode = tapNode?.makeNode(size: size)
    }
    
    func changeHP(value : Int){
        kappa?.hp += value
        HPLabel?.text = "HP \(kappa!.hp)"
    }
    
    func createEnemy(pos: Int){
        let enemy = enemyModel.getRnadomEnemy()
        enemy.position.x = getPositionX(pos)
        enemy.position.y = (kappa?.position.y)!
        self.addChild(enemy)
        
//        createEnemyLifeBar(pos: pos, x: enemy.position.x, y: enemy.position.y - 120)
        enemyModel.enemies[pos] = enemy
    }
    
    func createShop(pos : Int){
        let shop = ShopNode.makeShop()
        shop.position = CGPoint(x: getPositionX(pos), y: (kappa?.position.y)!)
        shop.name = "shop"
        self.addChild(shop)
    }
    
    /*
    func createEnemyLifeBar(pos: Int, x: CGFloat, y: CGFloat){
        let lifeBarBackGround = SKShapeNode(rect: CGRect(x: x, y: y, width: 100, height: 30))
        lifeBarBackGround.fillColor = .black
        lifeBarBackGround.zPosition = 98
        lifeBarBackGround.name = "back_life_bar\(pos)"
        self.addChild(lifeBarBackGround)
        
        let lifeBar = SKShapeNode(rect: CGRect(x: x, y: y, width: 100, height: 30))
        lifeBar.fillColor = .yellow
        lifeBar.zPosition = 99
        lifeBar.name = "life_bar\(pos)"
        self.addChild(lifeBar)
    }
 */
    func saveData(){
        kappa?.saveParam()
        gameData.saveParam()
        jobModel.saveParam()
    }
    
    func createMap(){
        map.updatePositionData()
        for (index, positionData) in map.positionData.enumerated() {
            switch positionData {
                case "enemy":
                    createEnemy(pos: index)
                case "shop":
                    createShop(pos: index)
                default:
                    break
            }
        }
    }
    
    // 右へ移動
    func moveRight(){
        if isMoving {
            return
        }
        isMoving = true
        kappa?.xScale = 1
        sword?.xScale = 1
        sword?.setSwordByKappa(kappa_x: (self.kappa?.position.x)!)
        map.myPosition += 1
        
        kappa?.run(actionModel.moveRightSequence!, completion: {() -> Void in
            if self.map.myPosition == Const.maxPosition {
                self.goNextMap()
            } else {
                self.updateButtonByPos()
            }
            self.isMoving = false
        })
        sword?.run(actionModel.moveRightSequence!)
    }
    
    // マップを右に移動
    func goNextMap(){
        clearMap()
        setFirstPosition()
        sword?.setSwordByKappa(kappa_x: (self.kappa?.position.x)!)
        map.distance += 0.1
        DistanceLabel?.text = "\(map.distance)km"
        saveData()
        createMap()
    }
    
    // 左へ移動
    func moveLeft(){
        if isMoving {
            return
        }
        isMoving = true
        kappa?.xScale = -1
        sword?.xScale = -1
        sword?.setSwordByKappa(kappa_x: (self.kappa?.position.x)!)
        
        map.myPosition -= 1
        kappa?.run(actionModel.moveLeftSequence!, completion: {() -> Void in
            self.isMoving = false
            if self.map.myPosition == Const.minPosition {
                self.goBackMap()
            } else {
                self.updateButtonByPos()
            }

        })
        sword?.run(actionModel.moveLeftSequence!)
    }

    // マップを左に移動
    func goBackMap(){
        clearMap()
        setRightPosition()
        sword?.setSwordByKappa(kappa_x: (self.kappa?.position.x)!)
        map.distance -= 0.1
        DistanceLabel?.text = "\(map.distance)km"
        saveData()
        createMap()
    }
    
    // マップの情報を削除
    func clearMap(){
        for (index, mapData) in map.positionData.enumerated() {
            if mapData == "enemy" {
                enemyModel.enemies[index].removeFromParent()
            }
            if mapData == "shop" {
                let shop = self.childNode(withName: "//shop") as? SKSpriteNode
                shop?.removeFromParent()
            }
        }
    }
    
    // 現在位置によってボタン文言を変更
    func updateButtonByPos(){
        if map.isShop() {
            ButtonLabel?.text = "中に入る"
        } else {
            ButtonLabel?.text = "メニューを開く"
        }
    }

    // 攻撃
    func attack(pos: Int){
        kappa?.run(actionModel.attackSequence!, completion: {() -> Void in
            let damage = self.calculateDamage(str: (self.kappa?.str)!, def: self.enemyModel.enemies[pos].def)
            let point = CGPoint(x: self.enemyModel.enemies[pos].position.x, y: self.enemyModel.enemies[pos].position.y + 30)
            self.displayDamage(value: damage, point: point, color: UIColor.white)
            self.enemyModel.enemies[pos].hp -= damage
            
//            let bar = self.childNode(withName: "//life_bar\(pos)") as? SKShapeNode
//            bar?.run(SKAction.resize(toWidth: 50, duration: 0.01))
            
            if self.enemyModel.enemies[pos].hp <= 0 {
                self.enemyModel.enemies[pos].hp = 0
                self.beatEnemy(pos: pos)
            }
        })
        sword?.run(actionModel.attackSequence!)
    }
    
    func calculateDamage(str: Int, def: Int) -> Int {
        var damage = str - CommonUtil.rnd(def)
        if damage <= 0 {
            damage = 1
        }
        return damage
    }
    
    // ダメージを数字で表示
    func displayDamage(value: Int, point: CGPoint, color: UIColor){
        let location = CGPoint(x: point.x, y: point.y + 30.0)
        let label = SKLabelNode(fontNamed: Const.damageFont)
        label.text = "\(value)"
        label.position = location
        label.fontColor = color
        label.fontSize = 48
        label.zPosition = 90
        self.addChild(label)
        
        label.run(actionModel.displayDamageSequence!)
    }
    
    // モンスター撃破処理
    func beatEnemy(pos: Int){
        enemyModel.enemies[pos].removeFromParent()
        map.positionData[pos] = "free"
        updateExp(enemyModel.enemies[pos].exp)
    }
    
    // 経験値更新
    func updateExp(_ getExp : Int){
        kappa?.nextExp -= getExp
        if (kappa?.nextExp)! <= 0 {
            LvUp()
        }
        updateStatus()
    }
    
    func LvUp(){
        kappa?.LvUp(jobModel)
        showMessage("LVがあがった")
        if jobModel.hp != 0 {
            HPUpLabel?.isHidden = false
            HPUpLabel?.text = "+\(jobModel.hp)"
            HPUpLabel?.run(actionModel.fadeInOutSequence!)
        }
        if jobModel.str != 0 {
            StrUpLabel?.isHidden = false
            StrUpLabel?.text = "+\(jobModel.str)"
            StrUpLabel?.run(actionModel.fadeInOutSequence!)
        }
        if jobModel.def != 0 {
            DefUpLabel?.isHidden = false
            DefUpLabel?.text = "+\(jobModel.def)"
            DefUpLabel?.run(actionModel.fadeInOutSequence!)
        }
        if jobModel.str != 0 {
            AgiUpLabel?.isHidden = false
            AgiUpLabel?.text = "+\(jobModel.agi)"
            AgiUpLabel?.run(actionModel.fadeInOutSequence!)
        }
        if jobModel.int != 0 {
            IntUpLabel?.isHidden = false
            IntUpLabel?.text = "+\(jobModel.int)"
            IntUpLabel?.run(actionModel.fadeInOutSequence!)
        }
        if jobModel.pie != 0 {
            PieUpLabel?.isHidden = false
            PieUpLabel?.text = "+\(jobModel.pie)"
            PieUpLabel?.run(actionModel.fadeInOutSequence!)
        }
        if jobModel.luc != 0 {
            LucUpLabel?.isHidden = false
            LucUpLabel?.text = "+\(jobModel.luc)"
            LucUpLabel?.run(actionModel.fadeInOutSequence!)
        }
    }
    
    // ステータス更新
    func updateStatus(){
        LVLabel?.text  = "LV  \(String(describing: kappa!.lv))"
        HPLabel?.text  = "HP  \(String(describing: kappa!.hp))"
        MAXHPLabel?.text = "HP  \(String(describing: kappa!.maxHp))"
        StrLabel?.text = "筋力  \(String(describing: kappa!.str))"
        DefLabel?.text = "体力  \(String(describing: kappa!.def))"
        AgiLabel?.text = "敏捷  \(String(describing: kappa!.agi))"
        IntLabel?.text = "知恵  \(String(describing: kappa!.int))"
        PieLabel?.text = "精神  \(String(describing: kappa!.pie))"
        LucLabel?.text = "幸運  \(String(describing: kappa!.luc))"
        ExpLabel?.text = "次のレベルまで　　\(String(describing: kappa!.nextExp))"
        
        JobNameLabel?.text = jobModel.displayName
        JobLVLabel?.text = "LV  \(jobModel.lv)"
    }
    
    // タップ数アップ
    func tapCountUp(){
        gameData.tapCount += 1
        TapCountLabel?.text = "\(gameData.tapCount)"
    }

    // メッセージ表示
    func showMessage(_ text : String){
        MessageLabel?.text = text
        MessageNode?.position.x += 100
        MessageNode?.run(actionModel.displayMessageSequence!)
    }
    
    /***********************************************************************************/
    /********************************** 画面遷移 ****************************************/
    /***********************************************************************************/
    
    // 店へ行く
    func goShop(){
        let scene = ShopScene(fileNamed: "ShopScene")
        scene?.size = self.scene!.size
        scene?.scaleMode = SKSceneScaleMode.aspectFill
        scene!.backScene = self.scene as! GameScene
        self.view!.presentScene(scene!, transition: .doorway(withDuration: 2.0))
    }
    
    // メニュー画面へ遷移
    func goMenu(){
        let scene = MenuScene(fileNamed: "MenuScene")
        scene?.size = self.scene!.size
        scene?.scaleMode = SKSceneScaleMode.aspectFill
        scene?.backScene = self.scene as! GameScene
        self.view!.presentScene(scene!, transition: .fade(withDuration: 0.5))
    }

    /***********************************************************************************/
    /********************************** touch ******************************************/
    /***********************************************************************************/
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.tapNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
        
        if pos.x >= 0 {
            if map.canMoveRight() {
                moveRight()
            } else {
                attack(pos: map.myPosition+1)
            }
        } else {
            moveLeft()
        }
    }
    
    // 押し続け地得る時の処理
    func touchMoved(toPoint pos : CGPoint) {
        // FIXME
        return
/*
        if isMoving {
            return
        }
        if pos.x >= 0 {
            if map.canMoveRight() {
                moveRight()
            } else {
                attack(pos: map.myPosition+1)
            }
        } else {
            moveLeft()
        }
 */
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.tapNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tapCountUp()
        if map.myPosition+1 > Const.maxPosition {
            return
        }
        for t in touches {
            let positionInScene = t.location(in: self)
            let tapNode = self.atPoint(positionInScene)
            if tapNode.name == "ButtonNode" || tapNode.name == "ButtonLabel" {
                if map.isShop() {
                    goShop()
                } else {
                    goMenu()
                }
            } else {
                self.touchDown(atPoint: positionInScene)
            }
        }        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        let dt = currentTime - self.lastUpdateTime
        
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
    
    
    /***********************************************************************************/
    /********************************** music ******************************************/
    /***********************************************************************************/
    func prepareBGM(fileName : String){
        /*
        if _music_off == true {
            return
        }
         */
 
        let bgm_path = NSURL(fileURLWithPath: Bundle.main.path(forResource: fileName, ofType: "mp3")!)
        var audioError:NSError?
        do {
            _audioPlayer = try AVAudioPlayer(contentsOf: bgm_path as URL)
        } catch let error as NSError {
            audioError = error
            _audioPlayer = nil
        }
        if let error = audioError {
            print("Error \(error.localizedDescription)")
        }
        _audioPlayer.delegate = self
        _audioPlayer.prepareToPlay()
 
    }
    
    func playBGM(){
        /*
        if _music_off == true {
            return
        }
        */

        _audioPlayer.numberOfLoops = -1;
        if ( !_audioPlayer.isPlaying ){
            _audioPlayer.play()
        }
    }
    
}
