import SpriteKit
import GameplayKit

class ShopScene: BaseScene {
    
    var backScene : WorldScene!
    var page = 0
    
    private var jobNameList0 = ["murabito", "wizard", "priest", "thief", "fighter", "knight"]
    private var jobList : [String]!

    // node
    private var jobLvLabel : SKLabelNode?
    private var jobNameLabel : SKLabelNode?
    private var jobImage : SKSpriteNode!

    private var jobImage0 : SKSpriteNode?
    private var jobImage1 : SKSpriteNode?
    private var jobImage2 : SKSpriteNode?
    private var jobImage3 : SKSpriteNode?
    private var jobImage4 : SKSpriteNode?
    private var jobImage5 : SKSpriteNode?
    
    override func sceneDidLoad() {
        jobModel.readDataByPlist()
        jobModel.loadParam()

        jobLvLabel      = childNode(withName: "//JobLvLabel") as? SKLabelNode
        jobNameLabel    = childNode(withName: "//JobNameLabel") as? SKLabelNode
        jobImage        = childNode(withName: "//JobImage") as? SKSpriteNode        
        jobImage0       = childNode(withName: "//JobImage0") as? SKSpriteNode
        
        let skillText   = childNode(withName: "//skillText") as? SKLabelNode
        skillText?.text = ""
    }
    
    override func didMove(to view: SKView) {
        setJobData()
    }
    
    func setJobData(){
        if page == 0 {
            jobList = jobNameList0
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
    
    func displayJobInfo(pos : Int, job : String){
        
        let jobLvLabel  = childNode(withName: "//JobLv\(pos)") as! SKLabelNode
        let jobImageNode = childNode(withName: "//JobImage\(pos)") as! SKSpriteNode

        switch job {
        case "murabito":
            setJobInfo(pos: pos, job: job)
        case "wizard":
            if GameData.isClear("tutorial") {
                setJobInfo(pos: pos, job: job)
            } else {
                setHatenaImage(pos: pos)
            }
        case "priest":
            if GameData.isClear("priest") {
                jobLvLabel.text = "LV \(JobModel.getLV(job))"
                jobImageNode.texture = SKTexture(imageNamed: job)
            } else {
                setHatenaImage(pos: pos)
            }
        case "thief":
            if GameData.isClear("thief") {
                jobLvLabel.text = "LV \(JobModel.getLV(job))"
                jobImageNode.texture = SKTexture(imageNamed: job)
            } else {
                setHatenaImage(pos: pos)
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
        jobLvLabel?.text = "LV  \(jobModel.lv)"
        jobNameLabel?.text = jobModel.displayName
        jobImage!.texture = SKTexture(imageNamed: jobModel.name)
    }
    
    func goBack(){
        self.view!.presentScene(backScene, transition: .doorway(withDuration: 2.0))
    }
    
    func changeJob(_ position: Int) {
        let selected_job = jobList[position]
        
        let alert = UIAlertController(
            title: jobModel.getDisplayName(key: selected_job),
            message: jobModel.getExplain(key: selected_job),
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "転職する", style: .default, handler: { action in
            self.jobModel.setData(self.jobList[position])
            self.jobModel.saveParam()
            self.setCurrentJobInfo()
            self.changeBoxColor(position)
            
            let kappa = KappaNode()
            kappa.setNextExp(self.jobModel)
        }))
        alert.addAction(UIAlertAction(title: "やめる", style: .cancel))
        self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func changeBoxColor(_ position: Int) {
        for num in 0...5 {
            let box = self.childNode(withName: "//Job\(num)") as? SKShapeNode
            box?.fillColor = .white
        }
        
        let box = self.childNode(withName: "//Job\(position)") as? SKShapeNode
        box?.fillColor = .green
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
                goBack()
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
