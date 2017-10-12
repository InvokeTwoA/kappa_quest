// 職業情報を示すコントローラー
// 転職前と、ステータス画面から見られる可能性がある
import Foundation
import UIKit

protocol JobDelegate{
    func jobDidChanged()
}

class JobViewController : BaseTableViewController {

    @IBOutlet weak var _tableView: UITableView!

    /*
    @IBAction func didBackButtonPushed(_ sender: Any) {
    }
    
    @IBAction func didChangeButtonPushed(_ sender: Any) {
        jobModel.saveParam()
        delegate?.jobDidChanged()
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var jobChangeButton: UIButton!
 */
    
    private var jobModel : JobModel = JobModel()
    var delegate : JobDelegate? = nil
    
    var job = "murabito"
    var from = ""
    
    let sections = ["職業名", "説明", "成長率", "固有スキル", "習得スキル", "あなたの選択"]
    let JOB_NAME = 0
    let JOB_EXPLAIN = 1
    let JOB_LVUP_PER = 2
    let JOB_OWN_SKILL = 3
    let JOB_GENERAL_SKILL = 4
    let YOUR_CHOICE = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSections(sections)
        
        jobModel.readDataByPlist()
        jobModel.loadParam()
        jobModel.setData(job)
        
        setTableSetting(_tableView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        _tableView.reloadData()
    }
    
    func jobChange(){
        jobModel.saveParam()
        delegate?.jobDidChanged()
        dismiss(animated: true, completion: nil)
    }
    
    
    // row count
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        switch section {
        case JOB_NAME, JOB_EXPLAIN, JOB_LVUP_PER, JOB_OWN_SKILL, JOB_GENERAL_SKILL:
            rows = 1
        case YOUR_CHOICE:
            if from == "shop" {
                rows = 2
            } else {
                rows = 1
            }
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
        case JOB_NAME:
            cell.textLabel?.text = jobModel.getDisplayName(key: job)
            cell.imageView?.image = UIImage(named: job)
        case JOB_EXPLAIN:
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = jobModel.explain
        case JOB_LVUP_PER:
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = "HP:\(jobModel.hp)\n筋力:\(jobModel.str)\n魔力:\(jobModel.int)\n敏捷:\(jobModel.agi)\n幸運:\(jobModel.luc)"
        case JOB_OWN_SKILL :
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = jobModel.own_skill
        case JOB_GENERAL_SKILL :
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = jobModel.general_skill
        case YOUR_CHOICE:
            if from == "shop" {
                if indexPath.row == 0 {
                    cell.textLabel?.text = "転職する"
                } else {
                    cell.textLabel?.text = "やめておく"
                }
            } else {
                cell.textLabel?.text = "立ち去る"
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
            if from == "shop" && indexPath.row == 0 {
                jobChange()
            } else {
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
            if from == "shop" && indexPath.row == 0 {
                cell.backgroundColor = CommonUtil.UIColorFromRGB(0x98fb98)
            } else {
                cell.backgroundColor = CommonUtil.UIColorFromRGB(0xfff0f5)
            }
        } else {
            cell.backgroundColor = UIColor.white
        }
    }
}
