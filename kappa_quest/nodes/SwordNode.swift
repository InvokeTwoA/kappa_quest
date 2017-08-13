import Foundation
import SpriteKit

class SwordNode: SKSpriteNode {

    
    // カッパの横に剣を置く
    func setSwordByKappa(kappa_x : CGFloat){
        if xScale == 1 {
            position.x = kappa_x + 50
        } else {
            position.x = kappa_x - 50
        }
    }
}
