
import Foundation
import UIKit

class BaseTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    private var sections = [""]

    func setSections(_ array : [String]){
        sections = array
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    // section title
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    // tableview の共通設定
    func setTableSetting(_ tableView : UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 88
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.reloadData()
    }
    
    /* 以下、テーブル設定 */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        if(editingStyle == UITableViewCellEditingStyle.delete){
        }
    }
    
    // スワイプによる削除を許可するかどうか
    func tableView(_ tableView: UITableView,canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    // row count
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    // cell に関するデータソースメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for:indexPath) as UITableViewCell
        return cell
    }
}
