// 一覧情報を表示するコントローラー
import Foundation
import UIKit
class AbilityViewController : BaseTableViewController {
 
    @IBOutlet weak var _tableView: UITableView!
    
    @IBOutlet weak var _abilityLabel: UILabel!
    
    let kappa = KappaNode()
    let abilityModel = AbilityModel()

    private let sections = ["", "移動系スキル", "回復系スキル", "かっぱバスター", "宇宙スキル", ""]
    private let ABILITY_BACK = 0
    private let ABILITY_MOVE = 1
    private let ABILITY_HEAL = 2
    private let ABILITY_BUSTER = 3
    private let ABILITY_BACK2 = 5

    private let move_list = ["shukuchi", "shukuchi2", "jump_plus"]
    private let heal_list = ["time_heal", "jump_heal", "buster_heal"]
    private let buster_list = ["buster_long", "buster_penetrate", "buster_big"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        abilityModel.readDataByPlist()
        setData()
    }

    // 初期データセット
    func setData(){
        abilityModel.setParameterByUserDefault()
        setSections(sections)
        setTableSetting(_tableView)
        kappa.setParameterByUserDefault()
        updateAbilityLabel()
    }
    
    func updateAbilityLabel(){
        _abilityLabel.text = "アビリティポイント　 \(kappa.lv - abilityModel.spendCost) / \(kappa.lv)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        _tableView.reloadData()
    }
    
    // row count
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var row = 0
        switch section {
        case ABILITY_BACK:
            row = 1
        case ABILITY_MOVE:
            row = move_list.count
        case ABILITY_HEAL:
            row = heal_list.count
        case ABILITY_BUSTER:
            row = buster_list.count
        case ABILITY_BACK2:
            row = 1
        default:
            row = 0
        }
        return row
    }
    // cell に関するデータソースメソッド
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for:indexPath) as UITableViewCell
        cell.textLabel?.numberOfLines = 0

        var skill_name = ""
        switch indexPath.section {
        case ABILITY_MOVE:
            skill_name = move_list[indexPath.row]
        case ABILITY_HEAL:
            skill_name = heal_list[indexPath.row]
        case ABILITY_BUSTER:
            skill_name = buster_list[indexPath.row]
        default:
            break
        }
        
        switch indexPath.section {
        case ABILITY_MOVE, ABILITY_HEAL, ABILITY_BUSTER:
            var head = ""
            if AbilityModel.haveSkill(skill_name) {
                head = "✔︎"
            }
            let name = abilityModel.getName(skill_name)
            let cost = abilityModel.getCost(skill_name)
            let info = abilityModel.getInfo(skill_name)
            cell.accessoryType = .detailButton
            cell.textLabel?.text = "\(head)\(name)"
            cell.detailTextLabel?.text = "コスト: \(cost)  \(info)"
        case ABILITY_BACK, ABILITY_BACK2:
            cell.textLabel?.text = "戻る"
            cell.detailTextLabel?.text = ""
        default:
            break
        }
        
        cell.imageView?.isHidden = true
        return cell
    }
    
    // タップ時の処理
    var bar_tap_count = 0
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var skill_name = ""
        switch indexPath.section {
        case ABILITY_MOVE:
            skill_name = move_list[indexPath.row]
        case ABILITY_HEAL:
            skill_name = heal_list[indexPath.row]
        case ABILITY_BUSTER:
            skill_name = buster_list[indexPath.row]
        default:
            break
        }

        switch indexPath.section {
        case ABILITY_MOVE, ABILITY_HEAL, ABILITY_BUSTER:
            if AbilityModel.haveSkill(skill_name) {
                abilityModel.forgetSkill(skill_name)
            } else {
                if abilityModel.canGetSkill(skill_name) {
                    abilityModel.getSkill(skill_name)
                } else {
                    print("\(skill_name)は既に習得済みです")
                    displayAlert("アビリティを取得できません", message: "諦めよ", okString: "OK")
                }
            }
        case ABILITY_BACK, ABILITY_BACK2:
            dismiss(animated: false, completion: nil)
        default:
            break
        }
        _tableView.reloadData()
        updateAbilityLabel()
    }
    
    // アクセサリボタンを押した時の処理
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        var skill_name = ""
        switch indexPath.section {
        case ABILITY_MOVE:
            skill_name = move_list[indexPath.row]
        case ABILITY_HEAL:
            skill_name = heal_list[indexPath.row]
        case ABILITY_BUSTER:
            skill_name = buster_list[indexPath.row]
        default:
            break
        }
        
        switch indexPath.section {
        case ABILITY_MOVE, ABILITY_HEAL, ABILITY_BUSTER:
            let name = abilityModel.getName(skill_name)
            let explain = abilityModel.getExplain(skill_name)
            displayAlert(name, message: explain, okString: "OK")
        default:
            break
        }
    }
    
    // cell の色表示
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        var skill_name = ""
        switch indexPath.section {
        case ABILITY_MOVE:
            skill_name = move_list[indexPath.row]
        case ABILITY_HEAL:
            skill_name = heal_list[indexPath.row]
        case ABILITY_BUSTER:
            skill_name = buster_list[indexPath.row]
        default:
            break
        }
                
        switch indexPath.section {
        case ABILITY_BACK, ABILITY_BACK2:
            cell.backgroundColor = CommonUtil.UIColorFromRGB(0xfff0f5)
        case ABILITY_MOVE, ABILITY_HEAL, ABILITY_BUSTER:
            if AbilityModel.haveSkill(skill_name) {
                cell.backgroundColor = UIColor.cyan
            } else {
                cell.backgroundColor = UIColor.white
            }
        default:
            cell.backgroundColor = UIColor.white
        }
    }
}
