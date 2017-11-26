import SpriteKit
import GameplayKit

class ShopScene: BaseScene, JobDelegate {

    private var page = 0
    private var jobNameList0 = ["murabito", "wizard", "knight", "priest", "thief", "archer"]
    private var jobNameList1 = ["dancer", "necro", "ninja", "angel", "gundom", "fighter"]
    private var jobNameList2 = ["king", "maou", "miyuki", "assassin", "dark_kappa", "arakure"]
    private var enableJob : [Bool] = [true,false,false,false,false,false,false]
    private var jobList : [String]!

    override func sceneDidLoad() {
    }

    override func didMove(to view: SKView) {
        setPageData()
    }

    // delegate method
    func jobDidChanged() {
        setPageData()
    }

    func setPageData(){
        jobModel.readDataByPlist()
        jobModel.loadParam()
        setJobData()
        updatePageButton()
    }

    func setJobData(){
        if page == 0 {
            jobList = jobNameList0
        } else if page == 1 {
            jobList = jobNameList1
        } else if page == 2 {
            jobList = jobNameList2
        }
        
        // お知らせ数
        NotificationModel.resetShopCount(page)
        if page == 0 {
            updateNextPageNotification(1)
        } else if page == 1 {
            updateNextPageNotification(2)
        } else if page == 2 {
            updateNextPageNotification(3)
        }
        

        for i in 0...5 {
            displayJobInfo(pos: i, job: jobList[i])
        }

        for (index, key) in jobList.enumerated() {
            if key == jobModel.name {
                changeBoxColor(index)
            }
        }
        setCurrentJobInfo()
    }
    
    func updateNextPageNotification(_ page : Int ){
        let shop_notification_label = childNode(withName: "//ShopNotificationLabel") as! SKLabelNode
        let shop_notification_node  = childNode(withName: "//ShopNotificationNode") as! SKSpriteNode
        
        if page == 2 {
            shop_notification_label.isHidden = true
            shop_notification_node.isHidden = true
            return
        }
        
        if NotificationModel.getShopCountByPage(page) == 0 {
            shop_notification_label.isHidden = true
            shop_notification_node.isHidden = true
        } else {
            shop_notification_label.isHidden = false
            shop_notification_node.isHidden = false
            shop_notification_label.text = "\(NotificationModel.getShopCountByPage(page))"
        }
    }
    

    func displayJobInfo(pos : Int, job : String){
        switch job {
        case "murabito":
            setJobInfo(pos: pos, job: job)
        case "arakure":
            setJobInfo(pos: pos, job: job)
            enableJob[pos] = true
        case "assassin":
            if GameData.isClear("master") {
                setJobInfo(pos: pos, job: job)
                enableJob[pos] = true
            } else {
                setHatenaImage(pos: pos)
                enableJob[pos] = false
            }
        case "dark_kappa":
            if GameData.isClear("last") {
                setJobInfo(pos: pos, job: job)
                enableJob[pos] = true
            } else {
                setHatenaImage(pos: pos)
                enableJob[pos] = false
            }
        case "wizard", "knight", "priest", "thief", "archer", "necro", "fighter", "dancer", "ninja", "samurai", "gundom", "king", "angel", "maou", "miyuki", "dark_knight":
            if GameData.isClear(job) {
                enableJob[pos] = true
                setJobInfo(pos: pos, job: job)
            } else {
                setHatenaImage(pos: pos)
                enableJob[pos] = false
            }
        default:
            setHatenaImage(pos: pos)
            break
        }
    }

    func setJobInfo(pos : Int, job : String){
        let jobLvLabel  = childNode(withName: "//JobLv\(pos)") as! SKLabelNode
        let jobImageNode = childNode(withName: "//JobImage\(pos)") as! SKSpriteNode
        jobLvLabel.text = "LV \(JobModel.getLV(job))"
        jobImageNode.texture = SKTexture(imageNamed: job)
    }

    func setHatenaImage(pos : Int){
        let jobLvLabel  = childNode(withName: "//JobLv\(pos)") as! SKLabelNode
        let jobImageNode = childNode(withName: "//JobImage\(pos)") as! SKSpriteNode
        jobLvLabel.text = ""
        jobImageNode.texture = SKTexture(imageNamed: "hatena")
    }

    func setCurrentJobInfo(){
        let jobLvLabel      = childNode(withName: "//JobLvLabel") as! SKLabelNode
        let jobNameLabel    = childNode(withName: "//JobNameLabel") as! SKLabelNode
        let jobImage        = childNode(withName: "//JobImage") as! SKSpriteNode

        jobLvLabel.text = "LV  \(jobModel.lv)"
        jobNameLabel.text = jobModel.displayName
        jobImage.texture = SKTexture(imageNamed: jobModel.name)
    }

    func goNextPage(){
        page += 1
        updatePageButton()
        changeBoxColor(7)
        setJobData()
    }

    func goBackPage(){
        page -= 1
        updatePageButton()
        changeBoxColor(7)
        setJobData()
    }

    func updatePageButton(){
        let nextLabel  = childNode(withName: "//nextLabel") as? SKLabelNode
        let nextNode = childNode(withName: "//nextNode") as? SKSpriteNode
        let backLabel  = childNode(withName: "//backLabel") as? SKLabelNode
        let backNode = childNode(withName: "//backNode") as? SKSpriteNode
        if page == 0 {
            nextLabel?.isHidden = false
            nextNode?.isHidden = false
            backLabel?.isHidden = true
            backNode?.isHidden = true
        } else if page == 1 {
            nextLabel?.isHidden = false
            nextNode?.isHidden = false
            backLabel?.isHidden = false
            backNode?.isHidden = false
        } else if page == 2 {
            nextLabel?.isHidden = true
            nextNode?.isHidden = true
            backLabel?.isHidden = false
            backNode?.isHidden = false
        }
    }

    func changeJob(_ position: Int) {
        let selected_job = jobList[position]
        if selected_job == "" || !enableJob[position] {
            return
        }

        let storyboard = UIStoryboard(name: "Job", bundle: nil)
        let jobViewController = storyboard.instantiateViewController(withIdentifier: "JobViewController") as! JobViewController
        jobViewController.job = selected_job
        jobViewController.from = "shop"
        jobViewController.delegate = self
        self.view?.window?.rootViewController?.present(jobViewController, animated: true, completion: nil)
    }

    func changeBoxColor(_ position: Int) {
        for num in 0...5 {
            let box = self.childNode(withName: "//Job\(num)") as? SKShapeNode
            box?.fillColor = .white
        }

        if position != 7 {
            let box = self.childNode(withName: "//Job\(position)") as? SKShapeNode
            box?.fillColor = .green
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let positionInScene = t.location(in: self)
            let tapNode = self.atPoint(positionInScene)

            if tapNode.name == nil {
                return
            }

            switch tapNode.name! {
            case "CloseNode", "CloseLabel":
                goWorld()
            case "nextNode", "nextLabel":
                goNextPage()
            case "backNode", "backLabel":
                goBackPage()
            case "Job0", "JobLv0", "JobImage0":
                changeJob(0)
            case "Job1", "JobLv1", "JobImage1":
                changeJob(1)
            case "Job2", "JobLv2", "JobImage2":
                changeJob(2)
            case "Job3", "JobLv3", "JobImage3":
                changeJob(3)
            case "Job4", "JobLv4", "JobImage4":
                changeJob(4)
            case "Job5", "JobLv5", "JobImage5":
                changeJob(5)
            default:
                break
            }
        }
    }
}
