import SpriteKit
import GameplayKit

class ShopScene: SKScene {
    
    var backScene : GameScene!
    var page = 0
    private var jobList : [String]!

    // node
    private var jobLvLabel : SKLabelNode?
    private var jobNameLabel : SKLabelNode?
    private var jobImage : SKSpriteNode!
    private var graph : SKSpriteNode!

    private var jobLvLabel0 : SKLabelNode?
    private var jobLvLabel1 : SKLabelNode?
    private var jobLvLabel2 : SKLabelNode?
    private var jobLvLabel3 : SKLabelNode?
    private var jobLvLabel4 : SKLabelNode?
    private var jobLvLabel5 : SKLabelNode?
    
    private var jobImage0 : SKSpriteNode?
    private var jobImage1 : SKSpriteNode?
    private var jobImage2 : SKSpriteNode?
    private var jobImage3 : SKSpriteNode?
    private var jobImage4 : SKSpriteNode?
    private var jobImage5 : SKSpriteNode?
    
    private var job0 : SKShapeNode?
    private var job1 : SKShapeNode?
    private var job2 : SKShapeNode?
    private var job3 : SKShapeNode?
    private var job4 : SKShapeNode?
    private var job5 : SKShapeNode?
    
    override func sceneDidLoad() {
        jobLvLabel      = self.childNode(withName: "//JobLvLabel") as? SKLabelNode
        jobNameLabel    = self.childNode(withName: "//JobNameLabel") as? SKLabelNode
        jobImage        = self.childNode(withName: "//JobImage") as? SKSpriteNode
        graph           = self.childNode(withName: "//graph") as? SKSpriteNode
        
        jobLvLabel0     = self.childNode(withName: "//JobLv0") as? SKLabelNode
        jobLvLabel1     = self.childNode(withName: "//JobLv1") as? SKLabelNode
        jobLvLabel2     = self.childNode(withName: "//JobLv2") as? SKLabelNode
        jobLvLabel3     = self.childNode(withName: "//JobLv3") as? SKLabelNode
        jobLvLabel4     = self.childNode(withName: "//JobLv4") as? SKLabelNode
        jobLvLabel5     = self.childNode(withName: "//JobLv5") as? SKLabelNode

        jobImage0       = self.childNode(withName: "//JobImage0") as? SKSpriteNode

        job0            = self.childNode(withName: "//Job0") as? SKShapeNode
        job1            = self.childNode(withName: "//Job1") as? SKShapeNode
        job2            = self.childNode(withName: "//Job2") as? SKShapeNode
        job3            = self.childNode(withName: "//Job3") as? SKShapeNode
        job4            = self.childNode(withName: "//Job4") as? SKShapeNode
        job5            = self.childNode(withName: "//Job5") as? SKShapeNode
    }
    
    override func didMove(to view: SKView) {
        setJobData()
    }
    
    func setJobData(){
        if page == 0 {
            jobList = backScene.jobModel.jobNameList0
        }

        jobLvLabel0?.text = "LV \(JobModel.getLV(jobList[0]))"
        jobLvLabel1?.text = "LV \(JobModel.getLV(jobList[1]))"
        jobLvLabel2?.text = "LV \(JobModel.getLV(jobList[2]))"
        jobLvLabel3?.text = "LV \(JobModel.getLV(jobList[3]))"
        jobLvLabel4?.text = "LV \(JobModel.getLV(jobList[4]))"
        jobLvLabel5?.text = "LV \(JobModel.getLV(jobList[5]))"
        
        for (index, key) in jobList.enumerated() {
            if key == backScene?.jobModel.name {
                changeBoxColor(index)
            }
        }
        setCurrentJobInfo()
    }
    
    func setCurrentJobInfo(){
        jobLvLabel?.text = "LV  \(backScene.jobModel.lv)"
        jobNameLabel?.text = backScene.jobModel.displayName
        jobImage!.texture = SKTexture(imageNamed: backScene.jobModel.name)
        graph!.texture = SKTexture(imageNamed: "graph_\(backScene.jobModel.name)")
    }
    
    func goBack(){
        self.view!.presentScene(backScene, transition: .doorway(withDuration: 2.0))
    }
    
    func changeJob(_ position: Int) {
        backScene.jobModel.setData(jobList[position])
        setCurrentJobInfo()
        changeBoxColor(position)
        backScene.kappa?.setNextExp(backScene.jobModel)
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
