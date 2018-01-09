// 親クラス
// 共通用のメソッドなどを記載
import Foundation
import SpriteKit
import GameplayKit
import AVFoundation
import TwitterKit

class BaseScene: SKScene, AVAudioPlayerDelegate {

    var gameData : GameData = GameData()
    var jobModel : JobModel = JobModel()
    var chapter = 1
    
    override func didMove(to view: SKView) {
        gameData.setParameterByUserDefault()
    }
    
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
    
    let RANDOM_WIDTH = 100
    func makeSpark(point : CGPoint, isCtirical : Bool = false){
        var particle = SparkEmitterNode.makeSpark()
        if isCtirical {
            particle = SparkEmitterNode.makeBlueSpark()
        }

        let sparkFadeOut = SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.25),
            SKAction.removeFromParent()
            ])
        
        let point_x =  point.x + CGFloat(CommonUtil.rnd(RANDOM_WIDTH) - RANDOM_WIDTH/2)
        let point_y =  point.y + CGFloat(CommonUtil.rnd(RANDOM_WIDTH) - RANDOM_WIDTH/2)
        particle.position = CGPoint(x: point_x, y: point_y)
        particle.run(sparkFadeOut)
        addChild(particle)

        let point_x2 =  point.x + CGFloat(CommonUtil.rnd(RANDOM_WIDTH) - RANDOM_WIDTH/2)
        let point_y2 =  point.y + CGFloat(CommonUtil.rnd(RANDOM_WIDTH) - RANDOM_WIDTH/2)
        let black_particle = SparkEmitterNode.makeBlackSpark()
        black_particle.position = CGPoint(x: point_x2, y: point_y2)
        black_particle.run(sparkFadeOut)
        addChild(black_particle)
    }
    
    // 左からpos番目のx座標を返す
    func getPositionX(_ pos : Int) -> CGFloat {
        let position = CGFloat(pos)/7.0-1.0/2.0
        return size.width*position
    }

    
    /***********************************************************************************/
    /*************************** SNS操作         ****************************************/
    /***********************************************************************************/
    
    // スクショを貼り付けてツィート
    func tweet(_ message : String) {
        
        // 呟く前に広告を非表示にしてスクショを撮る
        let root = self.view?.window?.rootViewController as! GameViewController
        root.hideBanner()
        let screen_shot = CommonUtil.screenShot(self.view!)
        
        let composer = TWTRComposer()
        composer.setText(message)
        composer.setImage(screen_shot)
//        composer.setURL(URL(string: "https://goo.gl/GyrTzZ"))
        composer.show(from: self.view!.window!.rootViewController!, completion: { result in
            root.showBanner()
        })
    }
    
    /***********************************************************************************/
    /*************************** Node Label 操作 ****************************************/
    /***********************************************************************************/
    func hideSpriteNode(_ name : String){
        let node = childNode(withName: "//\(name)") as? SKSpriteNode
        node?.isHidden = true
    }

    func removeSpriteNode(_ name : String){
        let node = childNode(withName: "//\(name)") as? SKSpriteNode
        node?.removeFromParent()
    }

    func showSpriteNode(_ name : String){
        let node = childNode(withName: "//\(name)") as? SKSpriteNode
        node?.isHidden = false
    }

    func hideLabelNode(_ name : String){
        let node = childNode(withName: "//\(name)") as? SKLabelNode
        node?.isHidden = true
    }
    
    func removeLabelNode(_ name : String){
        let node = childNode(withName: "//\(name)") as? SKLabelNode
        node?.removeFromParent()
    }
    
    func showLabelNode(_ name : String){
        let node = childNode(withName: "//\(name)") as? SKLabelNode
        node?.isHidden = false
    }

    
    func deleteSPriteNode(_ name : String){
        let node = childNode(withName: "//\(name)") as? SKSpriteNode
        if (node != nil) {
            node?.physicsBody = SKPhysicsBody(rectangleOf: (node?.size)!)
            WorldNode.setWorldEnd((node?.physicsBody)!)
        }
    }
    

    /***********************************************************************************/
    /********************************** 画面遷移 ****************************************/
    /***********************************************************************************/
    func goTitle(){
        let nextScene = TitleScene(fileNamed: "TitleScene")!
        nextScene.size = scene!.size
        nextScene.scaleMode = SKSceneScaleMode.aspectFit
        view!.presentScene(nextScene, transition: .fade(withDuration: Const.transitionInterval))
    }
    
    // 1章ワールドへ
    func goGame(_ world_name : String){
        let nextScene = GameScene(fileNamed: "GameScene")!
        nextScene.size = self.scene!.size
        nextScene.scaleMode = SKSceneScaleMode.aspectFit
        nextScene.world_name = world_name
        view!.presentScene(nextScene, transition: .doorway(withDuration: Const.doorTransitionInterval))
    }
    
    func goWorld(){
        if chapter == 1 {
            let nextScene = WorldScene(fileNamed: "WorldScene")!
            nextScene.size = scene!.size
            nextScene.scaleMode = SKSceneScaleMode.aspectFit
            view!.presentScene(nextScene, transition: .doorway(withDuration: Const.doorTransitionInterval))
        } else if chapter == 2 {
            goWorld2()
        }
    }

    // 2章ゲーム画面へ
    func goGame2(_ world_name : String){
        let nextScene = Game2Scene(fileNamed: "Game2Scene.sks")!
        nextScene.size = scene!.size
        nextScene.scaleMode = SKSceneScaleMode.aspectFit
        nextScene.world_name = world_name
        self.view!.presentScene(nextScene, transition: .doorway(withDuration: Const.doorTransitionInterval))
    }
    
    // ２章ワールドへ
    func goWorld2(){
        let nextScene = World2Scene(fileNamed: "World2Scene")!
        nextScene.size = scene!.size
        nextScene.scaleMode = SKSceneScaleMode.aspectFit
        view!.presentScene(nextScene, transition: .doorway(withDuration: Const.doorTransitionInterval))
    }
    
    // アップデート履歴の ListViewController を表示
    func goUpdate(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let listViewController = storyboard.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
        listViewController.type = "update"
        view?.window?.rootViewController?.present(listViewController, animated: true, completion: nil)
    }
    
    // 1章ボス画面へ遷移
    func goLast(){
        let nextScene = LastBattleScene(fileNamed: "LastBattleScene")!
        nextScene.size = scene!.size
        nextScene.scaleMode = SKSceneScaleMode.aspectFit
        nextScene.world_name = "last"
        view!.presentScene(nextScene, transition: .fade(withDuration: Const.transitionInterval))
    }

    // ２章ボス画面へ遷移
    func goLastBoss2(){
        let nextScene = LastBattle2Scene(fileNamed: "LastBattle2Scene")!
        nextScene.size = scene!.size
        nextScene.scaleMode = SKSceneScaleMode.aspectFit
        view!.presentScene(nextScene, transition: .fade(withDuration: Const.transitionInterval))
    }
    
    // ムービー画面へ
    func goMovie(){
        let nextScene = MovieScene(fileNamed: "MovieScene")!
        nextScene.size = scene!.size
        nextScene.scaleMode = SKSceneScaleMode.aspectFit
        nextScene.chapter = chapter
        view!.presentScene(nextScene, transition: .crossFade(withDuration: 1.8))
    }
    
    // ２章オープニングへ
    func goOpening2(){
        let nextScene = Opening2Scene(fileNamed: "Opening2Scene")!
        nextScene.size = nextScene.size
        nextScene.scaleMode = SKSceneScaleMode.aspectFit
        nextScene.chapter = 2
        view!.presentScene(nextScene, transition: .doorway(withDuration: Const.doorTransitionInterval))
    }



    /***********************************************************************************/
    /********************************** music ******************************************/
    /***********************************************************************************/
    var _audioPlayer:AVAudioPlayer!
    func prepareBGM(fileName : String){
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

    func playBGM(volume : Float = 1.0){
        if !gameData.bgmFlag {
            return
        }
        _audioPlayer.volume = volume
        _audioPlayer.numberOfLoops = -1;
        if !_audioPlayer.isPlaying {
            _audioPlayer.play()
        }
    }

    func stopBGM(){
        if _audioPlayer.isPlaying {
            _audioPlayer.stop()
        }
    }

    var _audioSoundEffect1 : AVAudioPlayer!
    var _audioSoundEffect2 : AVAudioPlayer!
    var _audioSoundEffect3 : AVAudioPlayer!
    func prepareSoundEffect(){
        let bgm_path1 = NSURL(fileURLWithPath: Bundle.main.path(forResource: Const.sound_effect1, ofType: "mp3")!)
        let bgm_path2 = NSURL(fileURLWithPath: Bundle.main.path(forResource: Const.sound_effect2, ofType: "mp3")!)
        let bgm_path3 = NSURL(fileURLWithPath: Bundle.main.path(forResource: Const.sound_effect3, ofType: "mp3")!)
        var audioError:NSError?
        do {
            _audioSoundEffect1 = try AVAudioPlayer(contentsOf: bgm_path1 as URL)
            _audioSoundEffect2 = try AVAudioPlayer(contentsOf: bgm_path2 as URL)
            _audioSoundEffect3 = try AVAudioPlayer(contentsOf: bgm_path3 as URL)
        } catch let error as NSError {
            audioError = error
            _audioSoundEffect3 = nil
        }
        if let error = audioError {
            print("Error \(error.localizedDescription)")
        }
        _audioSoundEffect1.delegate = self
        _audioSoundEffect2.delegate = self
        _audioSoundEffect3.delegate = self
        _audioSoundEffect1.prepareToPlay()
        _audioSoundEffect2.prepareToPlay()
        _audioSoundEffect3.prepareToPlay()
    }

    func playSoundEffect(type: Int){
        if !gameData.soundEffectFlag {
            return
        }
        switch type {
        case 1:
            _audioSoundEffect1.currentTime = 0
            _audioSoundEffect1.play()
        case 2:
            _audioSoundEffect2.currentTime = 0
            _audioSoundEffect2.play()
        case 3:
            _audioSoundEffect3.currentTime = 0
            _audioSoundEffect3.play()
        default:
            break
        }
    }
}
