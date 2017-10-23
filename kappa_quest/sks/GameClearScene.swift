// ゲームクリア画面
import SpriteKit
import GameplayKit

class GameClearScene: BaseScene {

    var world = ""

    override func sceneDidLoad() {
    }

    override func didMove(to view: SKView) {
        let clearLabel     = childNode(withName: "//clearWord")  as! SKLabelNode
        let getLabel1      = childNode(withName: "//clearText1")  as! SKLabelNode
        let getLabel2      = childNode(withName: "//clearText2")  as! SKLabelNode
        let getLabel3      = childNode(withName: "//clearText3")  as! SKLabelNode

        getLabel3.text = ""
        
        switch world {
        case "tutorial":
            clearLabel.text = "これから伝説が始まる！"
            getLabel3.text = ""
            if !GameData.isClear(world) {
                getLabel1.text = "「酒場」がオープン！"
                getLabel2.text = "「魔法使い」のステージが出現！"
                NotificationModel.plusBarCount()
            }
        case "wizard":
            clearLabel.text = "そして、次の戦いが始まるのです"
            if !GameData.isClear(world) {
                getLabel1.text = "「魔法使い」のジョブを取得！"
                getLabel2.text = "「魔法使い」が酒場に登場！"
                getLabel3.text = "「騎士」のステージが出現！"
                NotificationModel.plusBarCount()
                NotificationModel.plusShopCount(0)
            }
        case "knight":
            clearLabel.text = "まだ戦いは続く"
            if !GameData.isClear(world) {
                getLabel1.text = "「騎士」のジョブを取得！"
                getLabel2.text = "「騎士」が酒場に登場！"
                getLabel3.text = "新ステージが３つ出現！"
                NotificationModel.plusBarCount()
                NotificationModel.plusShopCount(0)
            }
        case "priest":
            clearLabel.text = "そして、次の戦いが始まるのです"
            if !GameData.isClear(world) {
                getLabel1.text = "「僧侶」のジョブを取得！"
                getLabel2.text = "「僧侶」が酒場に登場！"
                getLabel3.text = "「勇者」のステージが出現！"
                NotificationModel.plusBarCount()
                NotificationModel.plusShopCount(0)
            }
        case "thief":
            clearLabel.text = "悪は滅びる運命"
            if !GameData.isClear(world) {
                getLabel1.text = "「盗賊」のジョブを取得！"
                getLabel2.text = "「盗賊」が酒場に登場！"
                getLabel3.text = "「古代文明」のステージが出現！"
                NotificationModel.plusBarCount()
                NotificationModel.plusShopCount(0)
            }
        case "archer":
            clearLabel.text = "獣たちとフレンズになった"
            if !GameData.isClear(world) {
                getLabel1.text = "「狩人」のジョブを取得！"
                getLabel2.text = "「狩人」が酒場に登場！"
                getLabel3.text = "「死霊術師」のステージが出現！"
                NotificationModel.plusBarCount()
                NotificationModel.plusShopCount(0)
            }
        case "necro":
            clearLabel.text = "後で坊さんを呼んでおこう"
            if !GameData.isClear(world) {
                getLabel1.text = "「死霊術師」のジョブを取得！"
                getLabel2.text = "「死霊術師」が酒場に登場！"
                NotificationModel.plusBarCount()
                NotificationModel.plusShopCount(1)
            }
        case "gundom":
            clearLabel.text = "さらば哀戦士"
            if !GameData.isClear(world) {
                getLabel1.text = "「機動戦士」のジョブを取得！"
                getLabel2.text = "「機動戦士」が酒場に登場！"
                NotificationModel.plusBarCount()
                NotificationModel.plusShopCount(1)
            }
        case "fighter":
            clearLabel.text = "帝国城はもう目の前だ"
            if !GameData.isClear(world) {
                getLabel1.text = "「勇者」のジョブを取得！"
                getLabel2.text = "「勇者」が酒場に登場！"
                NotificationModel.plusBarCount()
                NotificationModel.plusShopCount(1)
            }
        case "dancer":
            clearLabel.text = "ノーダメージクリア！"
            if !GameData.isClear(world) {
                getLabel1.text = "「踊り子」のジョブを取得！"
                getLabel2.text = "「踊り子」が酒場に登場！"
                NotificationModel.plusBarCount()
                NotificationModel.plusShopCount(1)
            }
        case "ninja":
            clearLabel.text = "これで忍者になれる！"
            if !GameData.isClear(world) {
                getLabel1.text = "「忍者」のジョブを取得！"
                getLabel2.text = "「忍者」が酒場に登場！"
                NotificationModel.plusBarCount()
                NotificationModel.plusShopCount(1)
            }
        case "angel":
            clearLabel.text = "これで忍者になれる！"
            if !GameData.isClear(world) {
                getLabel1.text = "「忍者」のジョブを取得！"
                getLabel2.text = "「忍者」が酒場に登場！"
                NotificationModel.plusBarCount()
                NotificationModel.plusShopCount(2)
            }
        case "king":
            clearLabel.text = "帝国の圧政も終わりだ！"
            if !GameData.isClear(world) {
                getLabel1.text = "「皇帝」のジョブを取得！"
                getLabel2.text = "「皇帝」が酒場に登場！"
                NotificationModel.plusBarCount()
                NotificationModel.plusShopCount(2)
            }
        case "maou":
            clearLabel.text = "真の黒幕は誰だ？"
            if !GameData.isClear(world) {
                getLabel1.text = "「魔王」のジョブが解禁！"
                getLabel2.text = "「妹」が酒場に登場！"
                getLabel3.text = "「妹」のステージが出現！"
                NotificationModel.plusBarCount()
                NotificationModel.plusShopCount(2)
            }
        case "miyuki":
            let hint = CommonUtil.rnd(5)
            clearLabel.text = "真の黒幕のヒント(\(hint+1)/5)"
            switch hint {
            case 0:
                getLabel1.text = "酒場の常連を全て集めよ"
                getLabel2.text = "常連客は全てで12人"
            case 1:
                getLabel1.text = "常連客の言葉に注目"
                getLabel2.text = "会話はそれぞれ８パターン"
            case 2:
                getLabel1.text = "会話にはそれぞれ色がある"
                getLabel2.text = "聖なる色で統一してみよう"
            case 3:
                getLabel1.text = "聖なる色"
                getLabel2.text = "それはカッパの緑色"
            case 4:
                getLabel1.text = "一文字目を"
                getLabel2.text = "縦読みすべし"
            default:
                break
            }
        case "master":
            clearLabel.text = "最後の戦いが始まる"
            getLabel1.text = "店長は正体を現した"
        case "dark_kappa":
            clearLabel.text = "次回、最終回！"
            if !GameData.isClear(world) {
                getLabel1.text = ""
                getLabel2.text = ""
                getLabel3.text = ""
            }
        default:
            clearLabel.text = "未設定"
            getLabel1.text = "未設定"
            getLabel2.text = "未設定"
        }
        
        // クリアフラグを立てる
        GameData.clearCountUp(world)
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let positionInScene = t.location(in: self)
            let tapNode = self.atPoint(positionInScene)
            if tapNode.name == nil {
                return
            }
            switch tapNode.name! {
            case "ContinueNode", "ContinueLabel":
                goWorld()
            default:
                break
            }
        }
    }
}
