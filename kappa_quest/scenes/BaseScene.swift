// 親クラス
// 共通用のメソッドなどを記載
import Foundation
import SpriteKit
import GameplayKit
import AVFoundation

class BaseScene: SKScene, AVAudioPlayerDelegate {

    var gameData : GameData = GameData()
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

    func goWorld(){
        let scene = WorldScene(fileNamed: "WorldScene")
        scene?.size = self.scene!.size
        scene?.scaleMode = SKSceneScaleMode.aspectFill
        self.view!.presentScene(scene!, transition: .doorway(withDuration: Const.doorTransitionInterval))
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

    func playBGM(){
        if !gameData.bgmFlag {
            return
        }
        _audioPlayer.numberOfLoops = -1;
        if ( !_audioPlayer.isPlaying ){
            _audioPlayer.play()
        }
    }

    func stopBGM(){
        if ( _audioPlayer.isPlaying ){
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
