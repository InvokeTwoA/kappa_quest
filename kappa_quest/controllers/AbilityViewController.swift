// 一覧情報を表示するコントローラー
import Foundation
import UIKit
class AbilityViewController : BaseTableViewController {
 
    @IBOutlet weak var _tableView: UITableView!
    
    @IBOutlet weak var _abilityLabel: UILabel!
    
    let kappa = KappaNode()
    let abilityModel = AbilityModel()

    private let sections = ["", "移動系スキル", "回復系スキル", "1.1.0", "宇宙スキル", ""]
    private let ABILITY_BACK = 0
    private let ABILITY_MOVE = 1
    private let ABILITY_HEAL = 2
    private let ABILITY_BACK2 = 5
    private let MOVE_SHUKUCHI = 0
    private let MOVE_SHUKUCHI2 = 1

    private let move_list = ["shukuchi", "shukuchi2"]
    private let heal_list = ["time_heal"]
    
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
            row = 2
        case ABILITY_HEAL:
            row = 1
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
        switch indexPath.section {
        case ABILITY_MOVE:
            cell.accessoryType = .detailButton
            let skill_name = move_list[indexPath.row]
            let name = abilityModel.getName(skill_name)
            var head = ""
            if abilityModel.haveSkill(skill_name) {
                head = "✔︎"
            }
            cell.textLabel?.text = "\(head)\(name)"
            cell.detailTextLabel?.text = "取得条件: なし"
        case ABILITY_HEAL:
            let head = ""
            let skill_name = heal_list[indexPath.row]
            let name = abilityModel.getName(skill_name)
            cell.textLabel?.text = "\(head)\(name)"
            cell.detailTextLabel?.text = "取得条件: なし"
        case ABILITY_BACK, ABILITY_BACK2:
            cell.textLabel?.text = "戻る"
        default:
            print("")
        }
        cell.imageView?.isHidden = true
        return cell
    }
    
    // タップ時の処理
    var bar_tap_count = 0
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case ABILITY_MOVE:
            let skill_name = move_list[indexPath.row]
            if abilityModel.haveSkill(skill_name) {
                abilityModel.forgetSkill(skill_name)
            } else {
                if abilityModel.canGetSkill(skill_name) {
                    abilityModel.getSkill(skill_name)
                } else {
                    print("\(skill_name)は既に習得済みです")
                    displayAlert("アビリティを取得できません", message: "諦めよ", okString: "OK")
                }
            }
        case ABILITY_HEAL:
            print("heal")
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
        switch indexPath.section {
        case ABILITY_MOVE:
            let skill_name = move_list[indexPath.row]
            let name = abilityModel.getName(skill_name)
            let explain = abilityModel.getExplain(skill_name)
            displayAlert(name, message: explain, okString: "OK")
        case ABILITY_HEAL:
            let skill_name = move_list[indexPath.row]
            let name = abilityModel.getName(skill_name)
            let explain = abilityModel.getExplain(skill_name)
            displayAlert(name, message: explain, okString: "OK")
        default:
            print("")
        }
    }
    
    // cell の色表示
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case ABILITY_BACK, ABILITY_BACK2:
            cell.backgroundColor = CommonUtil.UIColorFromRGB(0xfff0f5)
        case ABILITY_MOVE:
            let skill_name = move_list[indexPath.row]
            if abilityModel.haveSkill(skill_name) {
                cell.backgroundColor = UIColor.cyan
            } else {
                cell.backgroundColor = UIColor.white
            }
        case ABILITY_HEAL:
            print("heal")
        default:
            cell.backgroundColor = UIColor.white
        }
    }
}
