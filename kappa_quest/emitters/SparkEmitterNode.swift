import SpriteKit

class SparkEmitterNode: SKEmitterNode {
    class func makeSpark() -> SKEmitterNode {
        let path = Bundle.main.path(forResource: "spark", ofType: "sks")
        let particle = NSKeyedUnarchiver.unarchiveObject(withFile: path!) as! SKEmitterNode
        particle.zPosition = 5
        particle.numParticlesToEmit = 80 // 何個、粒を出すか。
        particle.particleBirthRate = 160 // 一秒間に何個、粒を出すか。
        particle.particleSpeed = 60 // 粒の速度
        particle.xAcceleration = 0
        particle.yAcceleration = 0
        return particle
    }
    
    class func makeMiniSpark() -> SKEmitterNode {
        let path = Bundle.main.path(forResource: "spark", ofType: "sks")
        let particle = NSKeyedUnarchiver.unarchiveObject(withFile: path!) as! SKEmitterNode
        particle.zPosition = 1
        particle.numParticlesToEmit = 40 // 何個、粒を出すか。
        particle.particleBirthRate = 80 // 一秒間に何個、粒を出すか。
        particle.particleSpeed = 40 // 粒の速度
        particle.xAcceleration = 0
        particle.yAcceleration = 0
        return particle
    }
}
