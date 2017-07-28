//
//  TesplayerViewController.swift
//  FRios
//
//  Created by MacBook on 7/23/17.
//  Copyright © 2017 MacBook. All rights reserved.
//

import UIKit
import AVFoundation

class TesplayerViewController: UIViewController {

    var player:AVAudioPlayer! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //let urlstring = "http://radio.spainmedia.es/wp-content/uploads/2015/12/tailtoddle_lo4.mp3"
        let urlstring: String = "http://45.121.26.141/w/colorring/al/601/766/0/0000/0004/932.mp3"
        let url = NSURL(string: urlstring)
        print("the url = \(url!)")
        downloadFileFromURL(url: url!)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func downloadFileFromURL(url:NSURL){  
        let task = URLSession.shared.downloadTask(with: url as URL) { location, response, error in
            guard location != nil && error == nil else {
                print(error)
                return
            }
            print("xong")
           self.play(url: location as! NSURL)
        }
        task.resume()
        
    }
    func play(url:NSURL) {
        print("playing \(url)")
        
        do {
            self.player = try AVAudioPlayer(contentsOf: url as URL)
            player.prepareToPlay()
            player.volume = 1.0
          
            player.play()
        } catch let error as NSError {
            //self.player = nil
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
