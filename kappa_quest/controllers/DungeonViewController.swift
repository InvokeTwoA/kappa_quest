// ダンジョン情報の表示
// 消しても良いかも

import Foundation

// 職業情報を示すコントローラー
// 転職前と、ステータス画面から見られる可能性がある
import Foundation
import UIKit

protocol DungeonDelegate{
    func didEnteredDungeon(key : String)
}

class DungeonViewController : BaseTableViewController {
    
    @IBOutlet weak var _tableView: UITableView!
    
    private var worldModel : WorldModel = WorldModel()
    var delegate : DungeonDelegate? = nil
    
    var world = "tutorial"
    
    private let dungeon_sections = ["ダンジョン名", "クエスト内容", "あなたの行動"]
    private let DUNGEON_NAME = 0
    private let DUNGEON_EXPLAIN = 1
    private let YOUR_CHOICE = 2
    
    private let GO_DUNGEON = 0
    private let BACK_DUNGEON = 1
    
    override func viewDidLoad() {
        print("world=\(world)")
        super.viewDidLoad()
        worldModel.readDataByPlist()
        worldModel.setData(world)
        
        setSections(dungeon_sections)
        setTableSetting(_tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        _tableView.reloadData()
    }
    
    func goLibrary(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let listViewController = storyboard.instantiateViewController(withIdentifier: "ListViewController") as! ListViewController
        listViewController.type = "enemies"
        listViewController.world = world
        self.view?.window?.rootViewController?.present(listViewController, animated: true, completion: nil)
    }

    // row count
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        switch section {
        case DUNGEON_NAME, DUNGEON_EXPLAIN:
            rows = 1
        case YOUR_CHOICE:
            rows = 2
        default:
            break
        }
        return rows
    }

    // cell に関するデータソースメソッド
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for:indexPath) as UITableViewCell
        cell.textLabel?.numberOfLines = 0
        switch indexPath.section {
        case DUNGEON_NAME:
            let cell2 = UITableViewCell(style: .subtitle, reuseIdentifier: "tableCell")
            cell2.textLabel?.text = worldModel.display_name
            return cell2
        case DUNGEON_EXPLAIN:
            cell.textLabel?.text = worldModel.explain
        case YOUR_CHOICE :
            cell.textLabel?.numberOfLines = 0
            if indexPath.row == GO_DUNGEON {
                cell.textLabel?.text = "突入する"
            } else if indexPath.row == BACK_DUNGEON {
                cell.textLabel?.text = "引き返す"
            }
        default:
            break
        }
        return cell
    }

    // タップ時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case YOUR_CHOICE:
            if indexPath.row == GO_DUNGEON {
                dismiss(animated: false, completion: nil)
                delegate?.didEnteredDungeon(key: world)
            } else if indexPath.row == BACK_DUNGEON {
                dismiss(animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    // cell の色表示
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        if indexPath.section == YOUR_CHOICE {
            if indexPath.row == GO_DUNGEON {
                cell.backgroundColor = CommonUtil.UIColorFromRGB(0x98fb98)
            } else {
                cell.backgroundColor = CommonUtil.UIColorFromRGB(0xfff0f5)
            }
        } else {
            cell.backgroundColor = UIColor.white
        }
    }
}
