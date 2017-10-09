// お知らせ数に関するモデル
import Foundation

class NotificationModel {

    class func getBarCount() -> Int {
        return UserDefaults.standard.integer(forKey: "bar_count")
    }
    
    // 酒場のお知らせ数を＋１する
    class func plusBarCount(){
        let count = UserDefaults.standard.integer(forKey: "bar_count")
        UserDefaults.standard.set(count+1,  forKey: "bar_count")
    }
    
    // 職業のお知らせ数を＋１する
    class func plusShopCount(_ page : Int){
        let count = UserDefaults.standard.integer(forKey: "shop_count\(page)")
        UserDefaults.standard.set(count+1,  forKey: "shop_count\(page)")
    }
    
    // 酒場のお知らせ数をリセット
    class func resetBarCount(){
        UserDefaults.standard.set(0,  forKey: "bar_count")
    }
    
    class func getShopCount() -> Int {
        let count1 = UserDefaults.standard.integer(forKey: "shop_count0")
        let count2 = UserDefaults.standard.integer(forKey: "shop_count1")
        let count3 = UserDefaults.standard.integer(forKey: "shop_count2")

        return count1 + count2 + count3
    }

    class func getShopCountByPage(_ page : Int) -> Int {
        return UserDefaults.standard.integer(forKey: "shop_count\(page)")
    }
    
    // 転職のお知らせ数をリセット
    class func resetShopCount(_ page : Int){
        UserDefaults.standard.set(0,  forKey: "shop_count\(page)")
    }


}
