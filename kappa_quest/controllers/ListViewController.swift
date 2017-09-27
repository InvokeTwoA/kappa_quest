// 一覧情報を表示するコントローラー
import Foundation
import UIKit

class ListViewController : BaseTableViewController {

    @IBOutlet weak var _tableView: UITableView!

    private var enemy_array = [
        "hiyoko",
        "usagi",
        "chibidora",
        "wizard",
        "ghost",
        "knight",
        "arakure",
        "thief",
        "priest",
        "buffalo",
        "archer",
        "dancer",
        "skelton",
        "zombi",
        "miira",
        "necro",
        "fighter",
        "samurai",
        "ninja",
        "tokage",
        "angel",
    ]

    private let library_section = ["名称", "説明", "能力(LV1の状態)", "特性", "戻る"]
    private let LIBRARY_ENEMY_NAME = 0
    private let LIBRARY_ENEMY_EXPLAIN = 1
    private let LIBRARY_ENEMY_STATUS  = 2
    private let LIBRARY_ENEMY_BACK    = 3

    var type = ""
    var enemy_name = ""
    var world = ""
    var enemy_data : NSDictionary!

    var worldModel = WorldModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
    }

    func setData(){
        switch type {
        case "enemies":
            let sections_array = ["戻る", "モンスター一覧", "戻る"]
            if world != "" {
                 worldModel.readDataByPlist()
                 worldModel.setData(world)
                 enemy_array = worldModel.enemies
            }
            setSections(sections_array)
        case "library":
            setSections(library_section)
            enemy_data = EnemyModel.getData(enemy_name)
        default:
            break
        }
        setTableSetting(_tableView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        _tableView.reloadData()
    }

    // row count
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch type {
        case "enemies":
            if section == 0 || section == 2 {
                return 1
            } else {
                return enemy_array.count
            }
        case "library":
            return 1
        default:
            return 0
        }
    }

    // cell に関するデータソースメソッド
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for:indexPath) as UITableViewCell
        cell.textLabel?.numberOfLines = 0
        switch type {
        case "enemies":
            if indexPath.section == 0 || indexPath.section == 2 {
                cell.textLabel?.text = "戻る"
                cell.imageView?.isHidden = true
            } else {
                let enemy = EnemyModel.getData(enemy_array[indexPath.row])
                cell.textLabel?.text = enemy.object(forKey: "name") as? String
                cell.imageView?.image = UIImage(named: enemy_array[indexPath.row])
                cell.imageView?.isHidden = false
            }
        case "library":
            switch indexPath.section {
            case LIBRARY_ENEMY_NAME:
                let enemy_displaya_name = enemy_data["name"] as! String
                cell.textLabel?.text = enemy_displaya_name
                cell.imageView?.image = UIImage(named: enemy_name)
                cell.imageView?.isHidden = false
            case LIBRARY_ENEMY_EXPLAIN:
                if enemy_data["explain"] != nil {
                    cell.textLabel?.text = enemy_data["explain"] as? String
                    cell.imageView?.isHidden = true
                } else {
                    cell.textLabel?.text = ""
                    cell.imageView?.isHidden = true
                }
            case LIBRARY_ENEMY_STATUS:
                cell.textLabel?.text = EnemyModel.displayStatus(enemy_name)
                cell.imageView?.isHidden = true
            case LIBRARY_ENEMY_BACK:
                cell.textLabel?.text = "戻る"
                cell.imageView?.isHidden = true
            default:
                break
            }
            default:
            break
        }
        return cell
    }

    // タップ時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch type {
        case "enemies":
            if indexPath.section == 0 || indexPath.section == 2 {
                dismiss(animated: true, completion: nil)
            } else {
                enemy_name = enemy_array[indexPath.row]
                type = "library"
                setData()
                _tableView.reloadData()
            }
        case "library":
            if indexPath.section == LIBRARY_ENEMY_BACK {
                dismiss(animated: false, completion: nil)
            }
        default:
            break
        }
    }

    // cell の色表示
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        switch type {
        case "enemies":
            if indexPath.section == 0 || indexPath.section == 2 {
                cell.backgroundColor = CommonUtil.UIColorFromRGB(0xfff0f5)
                return
            }
        case "library":
            if indexPath.section == LIBRARY_ENEMY_BACK {
                cell.backgroundColor = CommonUtil.UIColorFromRGB(0xfff0f5)
                return
            }
        default:
            break
        }
        cell.backgroundColor = UIColor.white
    }
}
