// （隠し）音楽テスト画面

import SpriteKit
import GameplayKit

class MusicScene: BaseScene {
    
    private var volume : Float = 1.0
    private var page = 0
    
    private var music_list = ["", "", "", "", ""]
    private var music_names = ["", "", "", "", ""]
    
    private var music_list0 = [Const.bgm_ahurera, Const.bgm_castle, Const.bgm_gameover, Const.bgm_fantasy,  Const.bgm_last_battle]
    private var music_names0 = ["オープニング「アフレラ」", "ワールドマップ", "ゲームオーバー", "1章ステージ", "1章ボス"]

    private var music_list1 = [Const.bgm_bit_cry, Const.bgm_bit_ahurera, Const.bgm_bit_millky, Const.bgm_zinna, Const.bgm_brave]
    private var music_names1 = ["闇のカッパ「crying again」", "スタッフロール「アフレラ (piano)」", "１章エンディング「millky way」", "2章ラスボス「zinnia」", "2章ステージ「bravery heart」"]

    private var music_list2 = [Const.bgm_moon, Const.bgm_kessen, Const.bgm_opening, Const.bgm_piano_millky, Const.bgm_brave]
    private var music_names2 = ["２章ステージ２", "２章特殊ボス「けっせん」", "２章オープニング", "2章エンディング「millky way (piano)」", "2章フィールド「bravery heart」"]

    override func sceneDidLoad() {
        prepareBGM(fileName: "maoudamashii_fantasy15")
        gameData.setParameterByUserDefault()
    }

    override func didMove(to view: SKView) {
        loadPageData()
    }

    override func willMove(from view: SKView) {
        stopBGM()
    }
    
    func play(_ name : String) {
        stopBGM()
        prepareBGM(fileName: name)
        playBGM(volume: volume)
    }
    
    func volumeUp(){
        volume += 0.1
        if volume > 1.0 {
            volume = 1.0
        }
        _audioPlayer.volume = volume
        
        let volumeLabel = childNode(withName: "//volumeLabel") as! SKLabelNode
        volumeLabel.text = "音量 \(volume)"
        
        gameData.volume = volume
        gameData.saveParam()
    }

    func volumeDown(){
        volume -= 0.1
        if volume <= 0.1 {
            volume = 0.1
        }
        _audioPlayer.volume = volume
        
        let volumeLabel = childNode(withName: "//volumeLabel") as! SKLabelNode
        volumeLabel.text = "音量 \(volume)"
        
        gameData.volume = volume
        gameData.saveParam()
    }
    
    func goNextPage(){
        page += 1
        loadPageData()
    }
    
    func goBackPage(){
        page -= 1
        loadPageData()
    }
    
    func loadPageData(){
        if page == 0 {
            music_list = music_list0
            music_names = music_names0
        } else if page == 1 {
            music_list = music_list1
            music_names = music_names1
        } else if page == 2 {
            music_list = music_list2
            music_names = music_names2
        }
        
        if page == 0 {
            hideLabelNode("BackPageLabel")
            hideSpriteNode("BackPageNode")
        } else {
            showLabelNode("BackPageLabel")
            showSpriteNode("BackPageNode")
        }
        
        if page == 2 {
            hideLabelNode("NextPageLabel")
            hideSpriteNode("NextPageNode")

        } else {
            showLabelNode("NextPageLabel")
            showSpriteNode("NextPageNode")
        }
        
        updateMusicList()
    }
    
    func updateMusicList(){
        for i in 0...4 {
            let node = childNode(withName: "//bgm\(i)") as! SKLabelNode
            node.text = music_names[i]
        }
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let positionInScene = t.location(in: self)
            let tapNode = self.atPoint(positionInScene)
            if tapNode.name == nil {
                return
            }
            
            switch tapNode.name! {
            case "0", "1", "2", "3", "4":
                let name = music_list[Int(tapNode.name!)!]
                play(name)
            case "VolumeUp":
                volumeUp()
            case "VolumeDown":
                volumeDown()
            case "NextPageNode", "NextPageLabel":
                goNextPage()
            case "BackPageNode", "BackPageLabel":
                goBackPage()
            case "BackNode", "BackLabel":
                goTitle()
            default:
                break
            }
        }
    }
}
