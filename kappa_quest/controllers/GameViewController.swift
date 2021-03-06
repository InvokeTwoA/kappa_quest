import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds

class GameViewController: UIViewController {

    @IBOutlet weak var _bannerView: GADBannerView!

    @IBOutlet weak var _skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // adMob
        _bannerView.adUnitID = Const.adMobID
        _bannerView.rootViewController = self
        _bannerView.load(GADRequest())

        if let scene = GKScene(fileNamed: "TitleScene") {
            if let sceneNode = scene.rootNode as! TitleScene? {
                sceneNode.scaleMode = .aspectFit

                _skView.presentScene(sceneNode)
                _skView.ignoresSiblingOrder = true
//                _skView.showsFPS = true
//                _skView.showsNodeCount = true
                _skView.showsPhysics = true
            }
        }
    }
    
    func hideBanner(){
        _bannerView.isHidden = true
    }
    
    var hideBannerFlag = false
    func hideBannerEternal(){
        _bannerView.isHidden = true
        hideBannerFlag = true
    }
    
    func showBanner(){
        if hideBannerFlag {
            return
        }
        _bannerView.isHidden = false
    }
    
    func changeDebugMode(){
        _skView.showsQuadCount = true
        _skView.showsFields = true
        _skView.showsDrawCount = true
        _skView.showsFPS = true
        _skView.showsNodeCount = true
        _skView.showsPhysics = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // 画面を自動で回転させるか
    override var shouldAutorotate: Bool {
        get {
            return false
        }
    }
    
    // 画面の向きを指定
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait
        }
    }    
}
