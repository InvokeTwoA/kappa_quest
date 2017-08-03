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
        self.view.addSubview(_bannerView)
        _bannerView.adUnitID = Const.adMobID
        _bannerView.rootViewController = self
        _bannerView.load(GADRequest())

        if let scene = GKScene(fileNamed: "GameScene") {
            if let sceneNode = scene.rootNode as! GameScene? {
                sceneNode.entities = scene.entities
                sceneNode.graphs = scene.graphs
                sceneNode.scaleMode = .aspectFill
                _skView.presentScene(sceneNode)
                _skView.ignoresSiblingOrder = true
//                    view.showsFPS = true
//                    view.showsNodeCount = true
            }
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
