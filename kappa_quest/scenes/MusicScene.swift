// （隠し）音楽テスト画面

import SpriteKit
import GameplayKit

class MusicScene: BaseScene {
    
    var volume : Float = 1.0
    
    override func sceneDidLoad() {
        prepareBGM(fileName: "maoudamashii_fantasy15")
    }

    override func willMove(from view: SKView) {
        stopBGM()
    }

    
    func play(_ name : String) {
        stopBGM()
        prepareBGM(fileName: name)
        playBGM()
    }
    
    func volumeUp(){
        volume += 0.1
        if volume > 1.0 {
            volume = 1.0
        }
        _audioPlayer.volume = volume
    }

    func volumeDown(){
        if volume < 0.0 {
            volume = 0.0
        }
        volume -= 0.1
        _audioPlayer.volume = volume
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let positionInScene = t.location(in: self)
            let tapNode = self.atPoint(positionInScene)
            if tapNode.name == nil {
                return
            }
            
            switch tapNode.name! {
            case "maoudamashii_fantasy15", "maoudamashii_lastboss02", "bgm_maoudamashii_piano_ahurera", "bgm_maoudamashii_8bit06", "bgm_maoudamashii_8bit20", "bgm_maoudamashii_8bit22", "bgm_maoudamashii_8bit23", "bgm_maoudamashii_8bit26":
                play(tapNode.name!)
            case "VolumeUp":
                volumeUp()
            case "VolumeDown":
                volumeDown()
            case "BackNode", "BackLabel":
                goTitle()
            default:
                break
            }
        }
    }
}
