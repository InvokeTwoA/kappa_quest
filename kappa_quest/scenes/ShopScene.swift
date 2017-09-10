import SpriteKit
import GameplayKit

class ShopScene: BaseScene {
    
    var backScene : WorldScene!
    var page = 0
    
    var jobModel : JobModel = JobModel()
    
    private var jobList : [String]!

    // node
    private var jobLvLabel : SKLabelNode?
    private var jobNameLabel : SKLabelNode?
    private var jobImage : SKSpriteNode!
    private var graph : SKSpriteNode!

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
        graph           = childNode(withName: "//graph") as? SKSpriteNode
        
        jobImage0       = childNode(withName: "//JobImage0") as? SKSpriteNode
        
        let skillText   = childNode(withName: "//skillText") as? SKLabelNode
        skillText?.text = ""
    }
    
    override func didMove(to view: SKView) {
        setJobData()
    }
    
    func setJobData(){
        if page == 0 {
            jobList = jobModel.jobNameList0
        }

        let jobLvLabel0     = childNode(withName: "//JobLv0") as? SKLabelNode
        let jobLvLabel1     = childNode(withName: "//JobLv1") as? SKLabelNode
        let jobLvLabel2     = childNode(withName: "//JobLv2") as? SKLabelNode
        let jobLvLabel3     = childNode(withName: "//JobLv3") as? SKLabelNode
        let jobLvLabel4     = childNode(withName: "//JobLv4") as? SKLabelNode
        let jobLvLabel5     = childNode(withName: "//JobLv5") as? SKLabelNode

        jobLvLabel0?.text = "LV \(JobModel.getLV(jobList[0]))"
        jobLvLabel1?.text = "LV \(JobModel.getLV(jobList[1]))"
        jobLvLabel2?.text = "LV \(JobModel.getLV(jobList[2]))"
        jobLvLabel3?.text = "LV \(JobModel.getLV(jobList[3]))"
        jobLvLabel4?.text = "LV \(JobModel.getLV(jobList[4]))"
        jobLvLabel5?.text = "LV \(JobModel.getLV(jobList[5]))"
        
        for (index, key) in jobList.enumerated() {
            if key == jobModel.name {
                changeBoxColor(index)
            }
        }
        setCurrentJobInfo()
    }
    
    func setCurrentJobInfo(){
        jobLvLabel?.text = "LV  \(jobModel.lv)"
        jobNameLabel?.text = jobModel.displayName
        jobImage!.texture = SKTexture(imageNamed: jobModel.name)
        graph!.texture = SKTexture(imageNamed: "graph_\(jobModel.name)")
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
