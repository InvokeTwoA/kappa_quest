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
    
    // 最低値1の値を返す
    class func valueMin1(_ num : Int) -> Int {
        var value : Int!
        if num <= 0 {
            value = 1
        } else {
            value = num
        }
        return value
    }
    
    // rnd()を２回繰り返す
    // 低いキーの配列ほど出やすくなり、最後の方の配列は出にくくなる
    // 期待値は max の 1/4 か？
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
