/*
 * 便利な関数
 */
import Foundation
import SpriteKit
class CommonUtil {
    // 0 から max までの乱数
    class func rnd(_ max : Int) -> Int {
        if(max <= 0){
            return 0
        }
        let rand = Int(arc4random_uniform(UInt32(max)))
        return rand
    }
    
    // rnd()を２回繰り返す
    // 低いきーの配列ほど出やすくなり、最後の方の配列は出にくくなる
    class func minimumRnd(_ max : Int) -> Int {
        if(max <= 0){
            return 0
        }
        return rnd(rnd(max))
    }
 
    class func setTimeout(delay:TimeInterval, block:@escaping ()->Void) -> Timer {
        return Timer.scheduledTimer(timeInterval: delay, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: false)
    }
}
