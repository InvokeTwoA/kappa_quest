// 一覧情報を表示するコントローラー
import Foundation
import UIKit

class ListViewController : BaseTableViewController {

    @IBOutlet weak var _tableView: UITableView!

    var type = ""
    var world = ""
    private var enemy_data : NSDictionary!
    private var worldModel = WorldModel()

    // モンスター図鑑（一覧）
    private var enemy_array = [
        "hiyoko",
        "chibidora",
        "megane",
        "ghost",
        "wizard",
        "usagi",
        "knight",
        "arakure",
        "buffalo",
        "thief",
        "priest",
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

    // モンスター図鑑（詳細）
    var enemy_name = ""
    private let library_section = ["名称", "説明", "能力", ""]
    private let LIBRARY_ENEMY_NAME = 0
    private let LIBRARY_ENEMY_EXPLAIN = 1
    private let LIBRARY_ENEMY_STATUS  = 2
    private let LIBRARY_ENEMY_BACK    = 3

    // 酒場
    private let barModel = BarModel()
    private let bar_section = ["酒場の店長K(タップで話しかける)", "常連たち(タップで話しかける)", "あなたの行動"]
    private var bar_people = ["megane"]
    private let BAR_MASTER = 0
    private let BAR_PEOPLE = 1
    private let BAR_BACK = 2
    private var talk_array = [0,0,0,0,0,0,0,0,0,0,0,0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
    }

    func setData(){
        switch type {
        case "enemies":
            let sections_array = ["", "モンスター一覧", ""]
            if world != "" {
                 worldModel.readDataByPlist()
                 worldModel.setData(world)
                 enemy_array = worldModel.enemies
            }
            setSections(sections_array)
        case "library":
            setSections(library_section)
            enemy_data = EnemyModel.getData(enemy_name)
        case "bar":
            setSections(bar_section)
            barModel.readDataByPlist()
            setBarPeople()
        default:
            break
        }
        setTableSetting(_tableView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if type != "bar" {
            _tableView.reloadData()
        }
    }
    
    func setBarPeople(){
        let array : [String] = [
            "miyuki",
            "gundom",
            "angel",
            "fighter",
            "wizard",
            "necro",
            "knight", // si
            "archer",  // tu
            "priest",  // du
            "thief",  // ke
            "dancer",  // ro
        ]
        for name in array {
            if GameData.isClear(name) {
                bar_people.append(name)
            }
        }
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
        case "bar":
            if section == BAR_MASTER || section == BAR_BACK {
                return 1
            } else {
                return bar_people.count
            }
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
        case "bar":
            switch indexPath.section {
            case BAR_MASTER:
                let list = barModel.getList("master")
                cell.textLabel?.text = list[CommonUtil.rnd(list.count)]
                cell.imageView?.isHidden = false
                cell.imageView?.image = UIImage(named: "master")
            case BAR_PEOPLE:
                let people = bar_people[indexPath.row]
                let list = barModel.getList(people)
                
//                cell.textLabel?.text = list[CommonUtil.rnd(list.count)]
                cell.textLabel?.text = list[talk_array[indexPath.row]]
                cell.imageView?.isHidden = false
                cell.imageView?.image = UIImage(named: people)
            case BAR_BACK:
                cell.textLabel?.text = "もう帰る"
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
                type = "enemies"
                _tableView.reloadData()
            }
        case "bar":
            if indexPath.section == BAR_BACK {
                dismiss(animated: false, completion: nil)
            } else {
                let people = bar_people[indexPath.row]
                let list = barModel.getList(people)

                talk_array[indexPath.row] = CommonUtil.rnd(list.count)
                _tableView.reloadRows(at: [indexPath], with: .none)
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
        case "bar":
            if indexPath.section == BAR_BACK {
                cell.backgroundColor = CommonUtil.UIColorFromRGB(0xfff0f5)
            }
            return
        default:
            break
        }
        cell.backgroundColor = UIColor.white
    }
}
