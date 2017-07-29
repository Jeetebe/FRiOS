//
//  FirstViewController.swift
//  FRios
//
//  Created by MacBook on 7/12/17.
//  Copyright © 2017 MacBook. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Alamofire
import BXSlider
import Social


extension UIImageView {
    
    func setRounded() {
        let radius = self.frame.width / 2
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}
class FirstViewController: UIViewController ,UICollectionViewDelegate, UICollectionViewDataSource,GADNativeExpressAdViewDelegate, GADVideoControllerDelegate {
    
    let adUnitId = "ca-app-pub-8623108209004118/6575771983"
    
    let link:String="Nhạc chờ Funring  http://itunes.apple.com/app/id1265447339"
    
    
    @IBOutlet weak var varH: NSLayoutConstraint!
     @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var myTable: UITableView!

    fileprivate let sectionTitles = ["Configurations", "Item Size", "Interitem Spacing"]
    fileprivate let configurationTitles = ["Automatic sliding","Infinite"]
    fileprivate var imageNames = ["1.jpg","2.jpg","3.jpg","4.jpg","5.jpg"]
    //fileprivate var imageNames = [String]()

    
    var list=[AlbumObj]()
    var listslide=[AlbumObj]()
     var listtophit=[Song]()
    
    @IBOutlet weak var nativeExpressAdView: GADNativeExpressAdView!
    @IBOutlet weak var collv: UICollectionView!
    
   
    @IBAction func share(_ sender : AnyObject) {
        
        print("share click")
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
            let controller = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            
            controller?.setInitialText(link)
            //controller.addImage(captureScreen())
            self.present(controller!, animated:true, completion:nil)
        }
            
        else {
            print("no Facebook account found on device")
            var alert = UIAlertView(title: "Thông báo", message: "Bạn chưa đăng nhập facebook", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }

        

  
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        alamofireGetTophit()
        alamofireGetAlbum()
       alamofireGetSlide()
      
      
        
        //admod
        nativeExpressAdView.adUnitID = adUnitId
        nativeExpressAdView.rootViewController = self
        nativeExpressAdView.delegate = self as GADNativeExpressAdViewDelegate
        
        // The video options object can be used to control the initial mute state of video assets.
        // By default, they start muted.
        let videoOptions = GADVideoOptions()
        videoOptions.startMuted = true
        nativeExpressAdView.setAdOptions([videoOptions])
        
        // Set this UIViewController as the video controller delegate, so it will be notified of events
        // in the video lifecycle.
        nativeExpressAdView.videoController.delegate = self as GADVideoControllerDelegate
        
        let request = GADRequest()
        //request.testDevices = [kGADSimulatorID]
        nativeExpressAdView.load(request)  //test
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    //collv 
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if indexPath.row%2 == 0
    {
    cell.backgroundColor = UIColor.gray
    }
    else
    {
    cell.backgroundColor = UIColor.brown
    }
    
}
func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
}
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    return list.count
    //return 5
}

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell:ImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
    
    let imgurl = list[indexPath.row].imgurl 
    Alamofire.request(imgurl).response { response in
        if let data = response.data {
            let image = UIImage(data: data)
            cell.imageView.image = image
        } else {
            print("Data is nil. I don't know what to do :(")
        }
    }
    return cell
}
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
    
    return 4
}

func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
    
    return 4
}
func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let cell = collectionView.cellForItem(at: indexPath as IndexPath) {
        let id=list[indexPath.row].nameid
        showplayer(id: id)
    } else {
        // Error indexPath is not on screen: this should never happen.
    }
}
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        
        
            let s=(screenWidth-10)/3
            
            
            let cellSize = CGSize(width:s , height:s)
            return cellSize
        
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
        var cell : SampleTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell") as! SampleTableViewCell
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
    
    
    func alamofireGetTophit() {
        let todoEndpoint: String = "http://123.30.100.126:8081/Restapi/rest/Appservice/gettophit?id=tophit"
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
                for element in json {
                    if let todoResult = Song(json: element) {
                            self.listtophit.append(todoResult)
                    }
                }
                print("out listtophit:\(self.listtophit.count)")
                self.myTable.reloadData()
                
        }
    }
    func alamofireGetSlide() {
        let todoEndpoint: String = "http://123.30.100.126:8081/Restapi/rest/Appservice/getalbum/slide"
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
                self.imageNames.removeAll()
                for element in json {
                    if let todoResult = AlbumObj(json: element) {
                        self.listslide.append(todoResult)
                        self.imageNames.append(todoResult.imgurl)
                    }
                }
                print("out:\(self.listslide.count)")
                let slides = self.imageNames.flatMap{ URL(string: $0)}.map{ BXSimpleSlide(imageURL: $0) }
                let slider = BXSlider<BXSimpleSlide>()
                slider.onTapBXSlideHandler = { slide in
                    NSLog("onTapSlide \(slide.imageURL)")
                    //let slide = (String) slide.imageURL
                    let id:String=self.getalbumid(str: (slide.imageURL?.absoluteString)!)
                    print("id=\(id)")
                    self.showplayer(id:id)
                }
                slider.autoSlide = false
                
                slider.updateSlides(slides)
                let widthV = self.view.frame.width
                let width = self.sliderView.frame.width
                let he = width * 0.45
                
                
                self.sliderView.addSubview(slider)
                self.varH.constant=he
                slider.frame = CGRect(x: 0, y: 0, width: Int(widthV-20), height: Int(he))
        }
    }
    func  getalbumid(str:String) -> String {
        
        if let i = listslide.index(where: { $0.imgurl == str }) {
            return listslide[i].nameid
        }
        
        
        return ""
    }

    func alamofireGetAlbum() {
        let todoEndpoint: String = "http://123.30.100.126:8081/Restapi/rest/Appservice/getalbum/albumchonloc"
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
                
                for element in json {
                    if let todoResult = AlbumObj(json: element) {
                        self.list.append(todoResult)
                    }
                }
                print("out listalbum:\(self.list.count)")
                self.collv.reloadData()
                
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        print("click")
        //if segue.identifier == "segplay"
       //showwaiting()

        
        if let indexPath = self.myTable.indexPathForSelectedRow {
            print("row \(indexPath)")
            
            
            let editTaskVC = segue.destination as! PlayerViewController
            editTaskVC.chonInt = indexPath.row
            editTaskVC.listtophit=self.listtophit
            editTaskVC.loai=0
            editTaskVC.albumid="tophit"
            
                    }
        
    }
    func showplayer(id:String) -> Void {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let editTaskVC = storyBoard.instantiateViewController(withIdentifier: "player") as! PlayerViewController
        editTaskVC.chonInt = 0
        //editTaskVC.listtophit=self.listtophit
        editTaskVC.loai=1
        editTaskVC.albumid=id
        self.present(editTaskVC, animated:true, completion:nil)
    }
    

    
    
    

}
