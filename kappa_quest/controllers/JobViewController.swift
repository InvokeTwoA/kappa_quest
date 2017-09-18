import Foundation
import UIKit

class JobViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var _tableView: UITableView!

    let imgArray: NSArray = ["kappa", "kappa_kick", "kappa_punch"]
    
    //Table Viewのセルの数を指定
    func tableView(_ table: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imgArray.count
    }
    
    //各セルの要素を設定する
    func tableView(_ table: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // tableCell の ID で UITableViewCell のインスタンスを生成
        let cell = table.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        
        let img = UIImage(named:"\(imgArray[indexPath.row])")
        
        // Tag番号 1 で UIImageView インスタンスの生成
        let imageView = table.viewWithTag(1) as! UIImageView
        imageView.image = img
        
        // Tag番号 ２ で UILabel インスタンスの生成
        let label1 = table.viewWithTag(2) as! UILabel
        label1.text = "No.\(indexPath.row + 1)"
                
        return cell
    }
}
