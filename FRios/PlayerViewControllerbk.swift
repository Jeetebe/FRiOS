

import UIKit
import AVFoundation
import MediaPlayer
import GoogleMobileAds
import Alamofire
import DropDown


//extension UIImageView {
//    
//    func setRounded() {
//        let radius = self.frame.width / 2
//        self.layer.cornerRadius = radius
//        self.layer.masksToBounds = true
//    }
//}





class PlayerViewControllerbk: UIViewController,AVAudioPlayerDelegate, GADNativeExpressAdViewDelegate, GADVideoControllerDelegate,UITableViewDelegate  {
    
    //Choose background here. Between 1 - 7
    let selectedBackground = 1
    

  var avPlayer: AVPlayer!
    var audioPlayer:AVAudioPlayer! = nil
    var currentAudio = ""
    var currentAudioPath:URL!
    //var audioList:NSArray!
    var currentAudioIndex = 0
    var timer:Timer!
    var audioLength = 0.0
    var toggle = true
    var effectToggle = true
    var totalLengthOfAudio = ""
    var finalImage:UIImage!
    var isTableViewOnscreen = false
    var shuffleState = false
    var repeatState = false
    var shuffleArray = [Int]()
    
    var listtophit=[Song]()
    var chonInt:Int!
    var loai:Int!
    
    var currsong:Song!

    @IBOutlet weak var artistNameLabel: UILabel!

    @IBOutlet var songNameLabel : UILabel!

    @IBOutlet var progressTimerLabel : UILabel!
    @IBOutlet var playerProgressSlider : UISlider!
    @IBOutlet var totalLengthOfAudioLabel : UILabel!
    @IBOutlet var previousButton : UIButton!
    @IBOutlet var playButton : UIButton!
    @IBOutlet var nextButton : UIButton!

    @IBOutlet weak var bannerView: GADBannerView!
 
    @IBOutlet weak var lbtonecode: UILabel!

    
    @IBOutlet weak var myTable: UITableView!
    
   // let adUnitId = "ca-app-pub-3940256099942544/8897359316"
    
    
//    func setupTimer(){
//        NotificationCenter.default.addObserver(self, selector: #selector(self.didPlayToEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
//        timer = Timer(timeInterval: 0.001, target: self, selector: #selector(PlayerViewController.tick), userInfo: nil, repeats: true)
//        RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)
//    }
    
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
        print("chon: \(indexPath.row)")
        currentAudioIndex=indexPath.row
            //showwaiting()
        prepareAudio()
        playAudio()
        
    }

    
    
    let dropDown = DropDown()
    
    @IBAction func caidat_click(_ sender: Any) {
    }
       
    @IBAction func close_click(_ sender: Any) {
//        if (audioPlayer.isPlaying)
//        {
//            audioPlayer.stop()
//        }
//        
//        self.dismiss(animated: true, completion: nil)
    }


    
    override func remoteControlReceived(with event: UIEvent?) {
        if event!.type == UIEventType.remoteControl{
            switch event!.subtype{
            case UIEventSubtype.remoteControlPlay:
                play(self)
            case UIEventSubtype.remoteControlPause:
                play(self)
            case UIEventSubtype.remoteControlNextTrack:
                next(self)
            case UIEventSubtype.remoteControlPreviousTrack:
                previous(self)
            default:
                print("There is an issue with the control")
            }
        }
    }

    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    override var prefersStatusBarHidden : Bool {
        
        if isTableViewOnscreen{
            return true
        }else{
            return false
        }
    }
    
    func showwaiting() -> Void {
        
        let spinnerActivity = MBProgressHUD.showAdded(to: self.view, animated: true);
        
        spinnerActivity.label.text = "Loading";
        
        spinnerActivity.detailsLabel.text = "Please Wait!!";
        
        spinnerActivity.isUserInteractionEnabled = false;
        
        
    }
    override func viewDidLoad() {
        
//        let soundUrl = "http://45.121.26.141/w/colorring/al/601/785/0/0000/0001/399.mp3"
//         let url = NSURL(string:soundUrl)
//        player = AVPlayer(url: url! as URL)
//        player.play()
       


            //showwaiting()
//        lbtonecode.isHidden = true
//        artistNameLabel.isHidden = true
//        songNameLabel.isHidden = true
        progressTimerLabel.isHidden = true
        totalLengthOfAudioLabel.isHidden = true
        
        print("loai \(loai) ; size: \(listtophit.count)")
        
        
        
        if (loai==1)
        {
            // alamofireGetLog()
        }
        print("chon \(chonInt)")
        print("size \(listtophit.count)")
        
        currentAudioIndex=chonInt
        currsong = listtophit[chonInt]
        
        print("currsong:\(currsong.tonename)")
        setinfor()

        
        //ads
        bannerView.adSize=kGADAdSizeSmartBannerPortrait
        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
        bannerView.adUnitID = "ca-app-pub-8623108209004118/8052505184"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())

    }
    
    override func viewWillAppear(_ animated: Bool) {

        //stopwaiting()
        //super.viewDidLoad()
       //        lbtonecode.isHidden = false
//        artistNameLabel.isHidden = false
//        songNameLabel.isHidden = false
        currentAudioIndex=chonInt
        progressTimerLabel.isHidden = false
        totalLengthOfAudioLabel.isHidden = false
        
        retrieveSavedTrackNumber()
        
        assingSliderUI()

//        prepareAudio()
//        playAudio()
let soundUrl = "http://45.121.26.141/w/colorring/al/601/785/0/0000/0001/399.mp3"
        self.play(url: URL(string:soundUrl)!)
        
        //LockScreen Media control registry
        if UIApplication.shared.responds(to: #selector(UIApplication.beginReceivingRemoteControlEvents)){
            UIApplication.shared.beginReceivingRemoteControlEvents()
            UIApplication.shared.beginBackgroundTask(expirationHandler: { () -> Void in
            })
        }
       
        
        
    }
    func play(url:URL) {
        self.avPlayer = AVPlayer(playerItem: AVPlayerItem(url: url))
        if #available(iOS 10.0, *) {
            self.avPlayer.automaticallyWaitsToMinimizeStalling = false
        }
        avPlayer!.volume = 1.0
        avPlayer.play()
    }

    func stopwaiting() -> Void {
        MBProgressHUD.hideAllHUDs(for: self.view, animated: true);

    }
    func setinfor() -> Void {
        artistNameLabel.text=currsong.singer
        songNameLabel.text=currsong.tonename
        lbtonecode.text = "MS: \(currsong.tonecode)  $: \(currsong.prices)"
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //albumArtworkImageView.setRounded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK:- AVAudioPlayer Delegate's Callback method
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        if flag == true {
            
            if shuffleState == false && repeatState == false {
                // do nothing
                playButton.setImage( UIImage(named: "play"), for: UIControlState())
                return
                
            } else if shuffleState == false && repeatState == true {
                //repeat same song
                prepareAudio()
                playAudio()
                
            } else if shuffleState == true && repeatState == false {

                shuffleArray.append(currentAudioIndex)
     
                
                var randomIndex = 0
                var newIndex = false
                while newIndex == false {
                    //randomIndex =  Int(arc4random_uniform(UInt32(audioList.count)))
                    if shuffleArray.contains(randomIndex) {
                        newIndex = false
                    }else{
                        newIndex = true
                    }
                }
                currentAudioIndex = randomIndex
                prepareAudio()
                playAudio()
                
            } else if shuffleState == true && repeatState == true {
                //shuffle song endlessly
                shuffleArray.append(currentAudioIndex)
                //                if shuffleArray.count >= audioList.count {
                //                    shuffleArray.removeAll()
                //                }
                
                
                var randomIndex = 0
                var newIndex = false
                while newIndex == false {
                    //randomIndex =  Int(arc4random_uniform(UInt32(audioList.count)))
                    if shuffleArray.contains(randomIndex) {
                        newIndex = false
                    }else{
                        newIndex = true
                    }
                }
                currentAudioIndex = randomIndex
                prepareAudio()
                playAudio()
                
                
            }
            
        }
    }
    

    
    func saveCurrentTrackNumber(){
        UserDefaults.standard.set(currentAudioIndex, forKey:"currentAudioIndex")
        UserDefaults.standard.synchronize()
        
    }
    
    func retrieveSavedTrackNumber(){
        if let currentAudioIndex_ = UserDefaults.standard.object(forKey: "currentAudioIndex") as? Int{
            currentAudioIndex = currentAudioIndex_
        }else{
            currentAudioIndex = 0
        }
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
            //String url="http://45.121.26.141/"+alphabet+"/colorring/al/"+path+".mp3";
            
            
            //print("kqu \(kq)")
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
            //            try self.audioPlayer =  AVAudioPlayer(data: soundData! as Data)
            //            audioPlayer.prepareToPlay()
            //            audioPlayer.volume = 1.0
            //            audioPlayer.delegate = self
        }
        catch {
            print("Error getting the audio file")
            b = false
        }
        return b
    }

    
    func prepareAudio()
    {
        //showwaiting()
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
        
        //let soundUrl2: String = "http://45.121.26.141/w/colorring/al/601/766/0/0000/0004/932.mp3"
        //let soundUrl: String = "http://www.cuasotinhyeu.vn/sites/default/files/csty/2017/01/cau3_20170122.mp3"

        
        do {
            let fileURL = NSURL(string:soundUrl)
            print("the url = \(fileURL!)")
            //downloadFileFromURL(url: fileURL!)

            let soundData = NSData(contentsOf:fileURL! as URL)
            self.audioPlayer = try AVAudioPlayer(data: soundData! as Data)
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 1.0
            audioPlayer.delegate = self
            
            
            
        } catch {
            print("Error getting the audio file")
        }
        }
    }
    func  playAudio(){
        audioPlayer.play()
        playButton.setImage(#imageLiteral(resourceName: "ipause.png"), for: .normal)
        startTimer()
        stopwaiting()
    }
    
    func playNextAudio(){
        currentAudioIndex += 1
        if currentAudioIndex>self.listtophit.count-1{
            currentAudioIndex -= 1
            
            return
        }
        if audioPlayer.isPlaying{
            prepareAudio()
            playAudio()
        }else{
            prepareAudio()
        }
        
    }
    
    
    func playPreviousAudio(){
        currentAudioIndex -= 1
        if currentAudioIndex<0{
            currentAudioIndex += 1
            return
        }
        if audioPlayer.isPlaying{
            prepareAudio()
            playAudio()
        }else{
            prepareAudio()
        }
        
    }
    
    
    func stopAudiplayer(){
        audioPlayer.stop();
        
    }
    
    func pauseAudioPlayer(){
        audioPlayer.pause()
        
    }
    
    
    //MARK:-
    
    func startTimer(){
//        if timer == nil {
//            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(PlayerViewController.update(_:)), userInfo: nil,repeats: true)
//            timer.fire()
//        }
    }
    
    func stopTimer(){
        timer.invalidate()
        
    }
    
    
    func update(_ timer: Timer){
        if !audioPlayer.isPlaying{
            return
        }
        let time = calculateTimeFromNSTimeInterval(audioPlayer.currentTime)
        progressTimerLabel.text  = "\(time.minute):\(time.second)"
        playerProgressSlider.value = CFloat(audioPlayer.currentTime)
        UserDefaults.standard.set(playerProgressSlider.value , forKey: "playerProgressSliderValue")
        
        
    }
    
    func retrievePlayerProgressSliderValue(){
        let playerProgressSliderValue =  UserDefaults.standard.float(forKey: "playerProgressSliderValue")
        if playerProgressSliderValue != 0 {
            playerProgressSlider.value  = playerProgressSliderValue
            audioPlayer.currentTime = TimeInterval(playerProgressSliderValue)
            
            let time = calculateTimeFromNSTimeInterval(audioPlayer.currentTime)
            progressTimerLabel.text  = "\(time.minute):\(time.second)"
            playerProgressSlider.value = CFloat(audioPlayer.currentTime)
            
        }else{
            playerProgressSlider.value = 0.0
            audioPlayer.currentTime = 0.0
            progressTimerLabel.text = "00:00:00"
        }
    }
    
    func showTotalSongLength(){
        calculateSongLength()
        totalLengthOfAudioLabel.text = totalLengthOfAudio
    }
    
    
    func calculateSongLength(){
        let time = calculateTimeFromNSTimeInterval(audioLength)
        totalLengthOfAudio = "\(time.minute):\(time.second)"
    }
    
    
    //This returns song length
    func calculateTimeFromNSTimeInterval(_ duration:TimeInterval) ->(minute:String, second:String){
        // let hour_   = abs(Int(duration)/3600)
        let minute_ = abs(Int((duration/60).truncatingRemainder(dividingBy: 60)))
        let second_ = abs(Int(duration.truncatingRemainder(dividingBy: 60)))
        
        // var hour = hour_ > 9 ? "\(hour_)" : "0\(hour_)"
        let minute = minute_ > 9 ? "\(minute_)" : "0\(minute_)"
        let second = second_ > 9 ? "\(second_)" : "0\(second_)"
        return (minute,second)
    }
    
    
    
    
    
    
    func assingSliderUI () {
        let minImage = UIImage(named: "slider-track-fill")
        let maxImage = UIImage(named: "slider-track")
        let thumb = UIImage(named: "thumb")
        
        playerProgressSlider.setMinimumTrackImage(minImage, for: UIControlState())
        playerProgressSlider.setMaximumTrackImage(maxImage, for: UIControlState())
        playerProgressSlider.setThumbImage(thumb, for: UIControlState())
        
        
    }
    
    
    
    @IBAction func play(_ sender : AnyObject) {
        
        if shuffleState == true {
            shuffleArray.removeAll()
        }
        let play = UIImage(named: "iplay")
        let pause = UIImage(named: "ipause")
        if audioPlayer.isPlaying{
            pauseAudioPlayer()
            playButton.setImage(#imageLiteral(resourceName: "iplay.png"), for: .normal)
            
        }else{
            playAudio()
            //audioPlayer.isPlaying ? "\(playButton.setImage( pause, for: UIControlState()))" : "\(playButton.setImage(play , for: UIControlState()))"
            playButton.setImage(#imageLiteral(resourceName: "ipause.png"), for: .normal)
        }
    }
    
    
    
    @IBAction func next(_ sender : AnyObject) {
        playNextAudio()
    }
    
    
    @IBAction func previous(_ sender : AnyObject) {
        playPreviousAudio()
    }
    
    
    
    
    @IBAction func changeAudioLocationSlider(_ sender : UISlider) {
        audioPlayer.currentTime = TimeInterval(sender.value)
        
    }
    
    
         
    
    
    // MARK: - GADNativeExpressAdViewDelegate
    
    func nativeExpressAdViewDidReceiveAd(_ nativeExpressAdView: GADNativeExpressAdView) {
        if nativeExpressAdView.videoController.hasVideoContent() {
            print("Received an ad with a video asset.")
        } else {
            print("Received an ad without a video asset.")
        }
    }
    
    // MARK: - GADVideoControllerDelegate
    
    func videoControllerDidEndVideoPlayback(_ videoController: GADVideoController) {
        print("The video asset has completed playback.")
    }
    
    
    

    
}
