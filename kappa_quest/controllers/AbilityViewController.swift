// スキル取得画面を表示するコントローラー
import Foundation
import UIKit
class AbilityViewController : BaseTableViewController {
 
    @IBOutlet weak var _tableView: UITableView!
    @IBOutlet weak var _abilityLabel: UILabel!
    
    let kappa = KappaNode()
    let abilityModel = AbilityModel()

    private let sections = ["", "移動系スキル", "かっぱバスター", "かっぱ張り手",  "回復系スキル","宇宙スキル", "その他のスキル", ""]
    private let ABILITY_BACK = 0
    private let ABILITY_MOVE = 1
    private let ABILITY_BUSTER = 2
    private let ABILITY_RUSH = 3
    private let ABILITY_HEAL = 4
    private let ABILITY_SPACE = 5
    private let ABILITY_OTHER = 6
    private let ABILITY_BACK2 = 7

    private let move_list = ["shukuchi", "shukuchi2", "jump_plus", "jump_high"]
    private let heal_list = ["time_heal", "jump_heal", "buster_heal", "rush_heal"]
    private let buster_list = ["buster_long", "buster_penetrate", "buster_gravity", "buster_right", "buster_up", "buster_back", "buster_big", "buster_slow"]
    private let rush_list = ["rush_muteki", "rush_move", "rush_hado"]
    private let space_list = ["space_hp_up"]
    private let other_list = ["tanuki_body", "eyes"]

    override func viewDidLoad() {
        super.viewDidLoad()
        abilityModel.readDataByPlist()
        setData()
    }

    @IBAction func didPushedSkillResetButton(_ sender: Any) {
        let alert = UIAlertController(
            title: "全てのスキルを外します。",
            message: "よろしいですか？",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.resetSkill()
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        present(alert, animated: true, completion: nil)
    }
    
    func resetSkill(){
        abilityModel.resetAllSkill()
        _tableView.reloadData()
        updateAbilityLabel()
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
        _abilityLabel.text = "アビリティポイント　 \(abilityModel.abilityPoint) / \(kappa.lv)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        _tableView.reloadData()
    }
    
    func getSKillName(_ indexPath : IndexPath) -> String {
        var skill_name = ""
        switch indexPath.section {
        case ABILITY_MOVE:
            skill_name = move_list[indexPath.row]
        case ABILITY_HEAL:
            skill_name = heal_list[indexPath.row]
        case ABILITY_BUSTER:
            skill_name = buster_list[indexPath.row]
        case ABILITY_RUSH:
            skill_name = rush_list[indexPath.row]
        case ABILITY_SPACE:
            skill_name = space_list[indexPath.row]
        case ABILITY_SPACE:
            skill_name = space_list[indexPath.row]
        case ABILITY_OTHER:
            skill_name = other_list[indexPath.row]
        default:
            break
        }
        return skill_name
    }
    
    func getSKillHead(_ skill_name : String) -> String {
        var head = ""
        if AbilityModel.haveSkill(skill_name) {
            head = "✔︎"
        }
        return head
    }
    
    
    // row count
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var row = 0
        switch section {
        case ABILITY_BACK, ABILITY_BACK2:
            row = 1
        case ABILITY_MOVE:
            row = move_list.count
        case ABILITY_HEAL:
            row = heal_list.count
        case ABILITY_BUSTER:
            row = buster_list.count
        case ABILITY_RUSH:
            row = rush_list.count
        case ABILITY_SPACE:
            row = space_list.count
        case ABILITY_OTHER:
            row = other_list.count
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
        case ABILITY_MOVE, ABILITY_HEAL, ABILITY_BUSTER, ABILITY_RUSH, ABILITY_SPACE, ABILITY_OTHER:
            let skill_name = getSKillName(indexPath)
            let head = getSKillHead(skill_name)
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
        _tableView.reloadData()
        
        switch indexPath.section {
        case ABILITY_MOVE, ABILITY_HEAL, ABILITY_BUSTER, ABILITY_RUSH, ABILITY_SPACE, ABILITY_OTHER:
            let skill_name = getSKillName(indexPath)
            if AbilityModel.haveSkill(skill_name) {
                abilityModel.forgetSkill(skill_name)
            } else {
                print("\(skill_name)を持っていない")
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
        _tableView.reloadData()
        switch indexPath.section {
        case ABILITY_MOVE, ABILITY_HEAL, ABILITY_BUSTER, ABILITY_RUSH, ABILITY_SPACE, ABILITY_OTHER:
            let skill_name = getSKillName(indexPath)
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
        switch indexPath.section {
        case ABILITY_MOVE, ABILITY_HEAL, ABILITY_BUSTER, ABILITY_RUSH, ABILITY_SPACE, ABILITY_OTHER:
            let skill_name = getSKillName(indexPath)
            if AbilityModel.haveSkill(skill_name) {
                cell.backgroundColor = UIColor.cyan
            } else {
                cell.backgroundColor = UIColor.white
            }
        case ABILITY_BACK, ABILITY_BACK2:
            cell.backgroundColor = CommonUtil.UIColorFromRGB(0xfff0f5)
        default:
            cell.backgroundColor = UIColor.white
        }
    }
}
