////
//  PlayerViewController.swift
//  ChurchConnect
//
//  Created by iOSDev1 on 27/02/17.
//  Copyright © 2017 Harshal Jadhav. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Alamofire
import GoogleMobileAds
import MessageUI

class PlayerViewController: UIViewController,UITableViewDelegate,MFMessageComposeViewControllerDelegate {
    
    @IBOutlet weak var thumbNailImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var playerSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
   // @IBOutlet weak var //loadingLabel: UILabel!
    //@IBOutlet weak var //seek//loadingLabel: UILabel!

    @IBOutlet weak var myTable: UITableView!
     @IBOutlet var songNameLabel : UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
 @IBOutlet weak var lbtonecode: UILabel!
    
       @IBOutlet weak var bannerView: GADBannerView!

    @IBOutlet weak var btncaidat: DesignButton!
    /// The interstitial ad.
    var interstitial: GADInterstitial!

    
    var playList: NSMutableArray = NSMutableArray()
    var timer: Timer?
    var index: Int = Int()
    var avPlayer: AVPlayer!
    var isPaused: Bool!
    
    var listtophit=[Song]()
    var chonInt:Int!
    var loai:Int!
    var albumid:String!
    
    var currsong:Song!
    var currentAudioIndex = 0
    
    enum UIUserInterfaceIdiom : Int {
        case unspecified
        
        case phone // iPhone and iPod touch style UI
        case pad // iPad style UI
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isPaused = false
        playButton.setImage(UIImage(named:"ipause"), for: .normal)
        //let soundUrl = "http://45.121.26.141/w/colorring/al/601/785/0/0000/0001/399.mp3"
        
        print("loai:\(loai) ;chon \(chonInt); id=\(albumid)")
        print("size \(listtophit.count)")
        
        //currentAudioIndex=chonInt
        //currsong = listtophit[chonInt]
        
        //print("currsong:\(currsong.tonename)")
        currentAudioIndex=chonInt
        playerSlider.value = 0.0
        currentTimeLabel.text = "00:00"
        timeLabel.text = "00:00"
       
        showwaiting()
        
        if (UIDevice.current.userInterfaceIdiom == .pad)
        {
            btncaidat.isHidden=true
        }

        //ads
        bannerView.adSize=kGADAdSizeSmartBannerPortrait
        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
        bannerView.adUnitID = "ca-app-pub-8623108209004118/8052505184"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        
        createAndLoadInterstitial()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //setCurrentAudioPath()
        do {
            //keep alive audio at background
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        if (loai>=1)
        {
            alamofireGetTophit(id: albumid)
        
        }
        else
        {
           preparePlay()
        }
        
        
    }
    func preparePlay() -> Void {
    if (listtophit.count>0)
    {
        currsong = listtophit[currentAudioIndex]
        setinfor()
        var soundUrl=getvalidURL(song: currsong!)
        print("posiyion: \(currentAudioIndex), song: \(currsong.tonename)")
        print("hople: \(soundUrl)")
        if (soundUrl == "notfound")
        {
            playNextAudio()
            
        }
        else
        {
            self.play(url: URL(string:soundUrl)!)
            self.setupTimer()
            stopwaiting()
        }

    }
    }
    func alamofireGetTophit(id:String) {
        var todoEndpoint: String = "http://123.30.100.126:8081/Restapi/rest/Appservice/gettophit?id=" + id
        let urlcasi="http://123.30.100.126:8081/Restapi/rest/Appservice/getsongofsinger/chonloc?singerid=" + id.replacingOccurrences(of: " ", with: "%20")
        if loai==3
        {
            todoEndpoint=urlcasi
        }
        print("ur;:\(todoEndpoint)")
        Alamofire.request(todoEndpoint)
            
            .responseJSON { response in
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print(response.result.error!)
                    //completionHandler(.failure(response.result.error!))
                    return
                }
                
                // make sure we got JSON and it's an array of dictionaries
                guard let json = response.result.value as? [[String: AnyObject]] else {
                    print("didn't get todo objects as JSON from API")
                    //                    completionHandler(.failure(BackendError.objectSerialization(reason: "Did not get JSON array in response")))
                    return
                }
                
                // turn each item in JSON in to Todo object
                //print("result:\(json)")
                self.listtophit.removeAll()
                for element in json {
                    if let todoResult = Song(json: element) {
                        self.listtophit.append(todoResult)
                    }
                }
                print("out listtophit:\(self.listtophit.count)")
                self.stopwaiting()

                if (self.listtophit.count>0)
                {
                    self.myTable.reloadData()
                    self.preparePlay()
                }
        }
    }

    func setinfor() -> Void {
        artistNameLabel.text=currsong.singer
        songNameLabel.text=currsong.tonename
        lbtonecode.text = "MS: \(currsong.tonecode)  $: \(currsong.prices)"
    }
    func play(url:URL) {
        self.avPlayer = AVPlayer(playerItem: AVPlayerItem(url: url))
        if #available(iOS 10.0, *) {
            self.avPlayer.automaticallyWaitsToMinimizeStalling = false
        }
        avPlayer!.volume = 1.0
        avPlayer.play()
    }
    func playAudio() -> Void {
     
        currsong = listtophit[currentAudioIndex]
        
        print("currsong:\(currsong.tonename)")
        setinfor()
        showwaiting()
        var soundUrl=getvalidURL(song: currsong!)
        print("posiyion: \(currentAudioIndex), song: \(currsong.tonename)")
        print("hople: \(soundUrl)")
        if (soundUrl == "notfound")
        {
            playNextAudio()
            
        }
        else
        {
            self.play(url: URL(string:soundUrl)!)
            //self.setupTimer()
            stopwaiting()
        }
    }
    
    override func viewDidDisappear( _ animated: Bool) {
        super.viewWillDisappear(animated)
       NotificationCenter.default.removeObserver(self)
       self.avPlayer = nil
       self.timer?.invalidate()
    }
    
    
    @IBAction func caidat_click(_ sender: Any) {

        
        let messageVC = MFMessageComposeViewController()
        
        messageVC.body = "DK NC " + currsong.tonecode.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) + " 1214324336";
        messageVC.recipients = ["909"]
        messageVC.messageComposeDelegate = self;
        
        self.present(messageVC, animated: false, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController!, didFinishWith result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResult.cancelled.rawValue:
            print("Message was cancelled")
           
            

            
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed.rawValue:
            print("Message failed")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent.rawValue:
            print("Message was sent")
            self.dismiss(animated: true, completion: nil)
        default:
            break;
        }
    }
fileprivate func createAndLoadInterstitial() {
    interstitial = GADInterstitial(adUnitID: "ca-app-pub-8623108209004118/5622775628")
    let request = GADRequest()
    // Request test ads on devices you specify. Your test device ID is printed to the console when
    // an ad request is made.
    request.testDevices = [ kGADSimulatorID, "2077ef9a63d2b398840261c8221a0c9a" ]
    interstitial.load(request)
}

    @IBAction func close_click(_ sender: Any) {
        if avPlayer != nil
        {
                if (avPlayer.isPlaying)
                {
                    avPlayer.pause()
                    isPaused=true
                    //avPlayer=nil
                }
        }
        
//        if interstitial.isReady {
//            interstitial.present(fromRootViewController: self)
//        } else {
//            print("Ad wasn't ready")
//        }

                               self.dismiss(animated: true, completion: nil)
    }

    @IBAction func play(_ sender : AnyObject) {
        
        print("play click")
        let play = UIImage(named: "iplay")
        let pause = UIImage(named: "ipause")
        if avPlayer.isPlaying{
            print("is playing")
           
            avPlayer.pause()
            isPaused = true
            playButton.setImage(#imageLiteral(resourceName: "iplay.png"), for: .normal)
            
        }else{
            print("is pause")
           
            avPlayer.play()
            isPaused = false
            //audioPlayer.isPlaying ? "\(playButton.setImage( pause, for: UIControlState()))" : "\(playButton.setImage(play , for: UIControlState()))"
            playButton.setImage(#imageLiteral(resourceName: "ipause.png"), for: .normal)
        }
    }
    
    func playNextAudio(){
        //showwaiting()
        print("play next")
        isPaused = false
        currentAudioIndex += 1
        if currentAudioIndex>self.listtophit.count-1{
            currentAudioIndex -= 1
            
            return
        }
        if avPlayer.isPlaying{
          
            playAudio()
        }else{
            
        }
        
    }
    
    
    func playPreviousAudio(){
        //showwaiting()
        isPaused = false
        currentAudioIndex -= 1
        if currentAudioIndex<0{
            currentAudioIndex += 1
            return
        }
        if avPlayer.isPlaying{
          
            playAudio()
        }else{
            
        }
        
    }
    
    
    func stopAudiplayer(){
        avPlayer.pause()
        
    }
    
    func pauseAudioPlayer(){
        avPlayer.pause()
        
    }
    
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        //self.nextTrack()
        playNextAudio()
    }
    
    @IBAction func prevButtonClicked(_ sender: Any) {
        //self.prevTrack()
        playPreviousAudio()
    }
    
    @IBAction func sliderValueChange(_ sender: UISlider) {
        let seconds : Int64 = Int64(sender.value)
        let targetTime:CMTime = CMTimeMake(seconds, 1)
        avPlayer!.seek(to: targetTime)
        if(isPaused == false){
            //seek//loadingLabel.alpha = 1
        }
    }
    
    @IBAction func sliderTapped(_ sender: UILongPressGestureRecognizer) {
        if let slider = sender.view as? UISlider {
            if slider.isHighlighted { return }
            let point = sender.location(in: slider)
            let percentage = Float(point.x / slider.bounds.width)
            let delta = percentage * (slider.maximumValue - slider.minimumValue)
            let value = slider.minimumValue + delta
            slider.setValue(value, animated: false)
            let seconds : Int64 = Int64(value)
            let targetTime:CMTime = CMTimeMake(seconds, 1)
            avPlayer!.seek(to: targetTime)
            if(isPaused == false){
                //seek//loadingLabel.alpha = 1
            }
        }
    }
    
    func setupTimer(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.didPlayToEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        timer = Timer(timeInterval: 0.001, target: self, selector: #selector(PlayerViewController.tick), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
    }
    
    func didPlayToEnd() {
        //self.nextTrack()
        print("play finish")
        //playNextAudio()
    }
    
    func tick(){
        if(avPlayer.currentTime().seconds == 0.0){
            //loadingLabel.alpha = 1
        }else{
            //loadingLabel.alpha = 0
        }
        
        if(isPaused == false){
            if(avPlayer.rate == 0){
                avPlayer.play()
                //seek//loadingLabel.alpha = 1
            }else{
                //seek//loadingLabel.alpha = 0
            }
        }
        
        if((avPlayer.currentItem?.asset.duration) != nil){
            let currentTime1 : CMTime = (avPlayer.currentItem?.asset.duration)!
            let seconds1 : Float64 = CMTimeGetSeconds(currentTime1)
            let time1 : Float = Float(seconds1)
            playerSlider.minimumValue = 0
            playerSlider.maximumValue = time1
            let currentTime : CMTime = (self.avPlayer?.currentTime())!
            let seconds : Float64 = CMTimeGetSeconds(currentTime)
            let time : Float = Float(seconds)
            self.playerSlider.value = time
            timeLabel.text =  self.formatTimeFromSeconds(totalSeconds: Int32(Float(Float64(CMTimeGetSeconds((self.avPlayer?.currentItem?.asset.duration)!)))))
            currentTimeLabel.text = self.formatTimeFromSeconds(totalSeconds: Int32(Float(Float64(CMTimeGetSeconds((self.avPlayer?.currentItem?.currentTime())!)))))
            
        }else{
            playerSlider.value = 0
            playerSlider.minimumValue = 0
            playerSlider.maximumValue = 0
            timeLabel.text = "Live stream \(self.formatTimeFromSeconds(totalSeconds: Int32(CMTimeGetSeconds((avPlayer.currentItem?.currentTime())!))))"
        }
    }
    
    
    func nextTrack(){
        if(index < playList.count-1){
            index = index + 1
            isPaused = false
            playButton.setImage(UIImage(named:"pause"), for: .normal)
            self.play(url: URL(string:(playList[self.index] as! String))!)
          
            
        }else{
            index = 0
            isPaused = false
            playButton.setImage(UIImage(named:"pause"), for: .normal)
             self.play(url: URL(string:(playList[self.index] as! String))!)
        }
    }
    
    func prevTrack(){
        if(index > 0){
            index = index - 1
            isPaused = false
            playButton.setImage(UIImage(named:"pause"), for: .normal)
             self.play(url: URL(string:(playList[self.index] as! String))!)
            
        }
    }
    
    func formatTimeFromSeconds(totalSeconds: Int32) -> String {
        let seconds: Int32 = totalSeconds%60
        let minutes: Int32 = (totalSeconds/60)%60
        let hours: Int32 = totalSeconds/3600
        return String(format: "%02d:%02d",minutes,seconds)
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.dismiss(animated: true) {
            self.avPlayer = nil
            self.timer?.invalidate()
        }
    }
    
    //table
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView!, numberOfRowsInSection section: Int) -> Int
    {
        return listtophit.count
    }
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        var cell : SampleTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cellplayer") as! SampleTableViewCell
        if(cell == nil)
        {
            cell = Bundle.main.loadNibNamed("cell", owner: self, options: nil)?[0] as! SampleTableViewCell;
        }
        let tonename = listtophit[indexPath.row].tonename as String //NOT NSString
        let singer = listtophit[indexPath.row].singer as String //NOT NSString
        var imgurl = listtophit[indexPath.row].singerimg as String //NOT NSString
        cell.lbtonename.text=tonename
        cell.lbsinger.text=singer
        
        
        print("img: \(imgurl)")
        
        Alamofire.request(imgurl.replacingOccurrences(of: " ", with: "%20")).response { response in
            if let data = response.data {
                let image = UIImage(data: data)
                cell.imgsinger.image = image
                cell.imgsinger.setRounded()
            } else {
                print("Data is nil. I don't know what to do :(")
            }
            if (imgurl == "")
            {
                cell.imgsinger.image = #imageLiteral(resourceName: "note.png")
            }
            
        }
        
        return cell as SampleTableViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
       // showwaiting()
        print("chon: \(indexPath.row)")
        currentAudioIndex=indexPath.row
    
        playAudio()
        
    }
    
    
    func getvalidURL(song:Song) -> String {
        var kq:String=""
        let str:String = util.convert(song: song)
        print("convert:\(str)")
        
        kq="http://45.121.26.141/w/colorring/al/"+str+".mp3"
        if (fileExists(soundUrl:kq))
        {
            return kq
        }
        
        for char in "abcdefghijklmnopqrstuvwxyz".characters {
            //print(char)
            kq="http://45.121.26.141/"+String(char)+"/colorring/al/"+str+".mp3"
            //String url="http://45.121.26.141/"+alphabet+"/colorring/al/"+path+".mp3";            //print("kqu \(kq)")
            if (fileExists(soundUrl:kq))
            {
                return kq
            }
            
            
        }
        return "notfound"
    }
    func fileExists(soundUrl : String!) -> Bool {
        var b:Bool=true
        do {
            let fileURL = NSURL(string:soundUrl)
            let soundData = NSData(contentsOf:fileURL! as URL)
            if (soundData==nil)
            {
                print("nil")
                b = false
            }
            else
            {
                print("not nil")
                b = true
            }
                  }
        catch {
            print("Error getting the audio file")
            b = false
        }
        return b
    }
    func stopwaiting() -> Void {
        MBProgressHUD.hideAllHUDs(for: self.view, animated: true);
        
    }
    func showwaiting() -> Void {
        
        let spinnerActivity = MBProgressHUD.showAdded(to: self.view, animated: true);
        
        spinnerActivity.label.text = "Loading";
        
        spinnerActivity.detailsLabel.text = "Please Wait!!";
        
        spinnerActivity.isUserInteractionEnabled = false;
        
        
    }


}
extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}


