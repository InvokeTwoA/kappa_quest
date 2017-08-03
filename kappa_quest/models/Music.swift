import Foundation
import AVFoundation

class Music: NSObject, AVAudioPlayerDelegate  {

    var _audioPlayer:AVAudioPlayer!

    override init() {
        super .init()
    }
    

    func prepareBGM(fileName : String){
        /*
         if _music_off == true {
         return
         }
         */
        let bgm_path = NSURL(fileURLWithPath: Bundle.main.path(forResource: fileName, ofType: "mp3")!)
        var audioError:NSError?
        do {
            _audioPlayer = try AVAudioPlayer(contentsOf: bgm_path as URL)
        } catch let error as NSError {
            audioError = error
            _audioPlayer = nil
        }
        if let error = audioError {
            print("Error \(error.localizedDescription)")
        }
        
        _audioPlayer.delegate = self
        _audioPlayer.prepareToPlay()
    }
    
    func playBGM(){
        /*
         if _music_off == true {
         return
         }
         */
        
        _audioPlayer.numberOfLoops = -1;
        if ( !_audioPlayer.isPlaying ){
            _audioPlayer.play()
        }
    }



}
