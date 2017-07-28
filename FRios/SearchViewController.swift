//
//  ViewController.swift
//  AZSearchViewController
//
//  Created by Antonio Zaitoun on 04/01/2017.
//  Copyright © 2017 Crofis. All rights reserved.
//

import UIKit
import  Alamofire

public enum TypeOfAccordianView {
    case classic
    case formal
}

struct Section {
    var name: String!
    var items: [String]!
    var collapsed: Bool!
    
    init(name: String, items: [String], collapsed: Bool = false) {
        self.name = name
        self.items = items
        self.collapsed = collapsed
    }
}

class SearchViewController: UIViewController {
    
    //The array which will hold the data
    var resultArray:[String] = []
    var sections = [Section]()
    
    //The search controller
    var searchController:AZSearchViewController!
    
    @IBOutlet weak var myTable: UITableView!
    
    var listtophit=[Song]()

    
    
    var typeOfAccordianView: TypeOfAccordianView? = .formal

    var url:String = "http://123.30.100.126:8081/Restapi/rest/Appservice/naDNqM2wYXNkZ0mrbHp4Y3Y1N2JvbcXdlcnR50dTEyaWm=/search/bytonename?id="
    
    @IBAction func search_click(_ sender: Any) {
        searchController.show(in: self)

    }
   
    
    func close(sender:AnyObject?){
        
        searchController.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sections = [
            Section(name: "Mac", items: ["MacBook", "MacBook Air", "MacBook Pro", "iMac", "Mac Pro", "Mac mini", "Accessories", "OS X El Capitan"]),
            Section(name: "iPad", items: ["iPad Pro", "iPad Air 2", "iPad mini 4", "Accessories"]),
            Section(name: "iPhone", items: ["iPhone 6s", "iPhone 6", "iPhone SE", "Accessories"]),
        ]

        
        //init search controller
        self.searchController = AZSearchViewController()
        
        //add setup delegate and data source
        self.searchController.delegate = self as! AZSearchViewDelegate
        self.searchController.dataSource = self as! AZSearchViewDataSource
        
        /*
         preform optional customizations
         */
        
        //The search bar's placeholder text
        self.searchController.searchBarPlaceHolder = "Tìm tên bài hát"
        
        
        self.searchController.navigationBarClosure = { bar in
            //The navigation bar's background color
            bar.barTintColor = #colorLiteral(red: 0.4668119129, green: 0.2598883398, blue: 0.8212435233, alpha: 1)
            
            //The tint color of the navigation bar
            bar.tintColor = UIColor.lightGray
        }
        
        //The search bar's (text field) background color
        self.searchController.searchBarBackgroundColor = .white
        
        //The status bar's color (light or dark)
        self.searchController.statusBarStyle = .lightContent
        
        //Keyboard appearnce (dark,light or default)
        self.searchController.keyboardAppearnce = .dark
        
        //The tableview's seperator color
        self.searchController.separatorColor = .clear
        
        //Add bar button item on the navigation bar using the navigation item.
        let item = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(SearchViewController.close(sender:)))
        item.tintColor = .white
        self.searchController.navigationItem.rightBarButtonItem = item
      
        
        

        
        
    }
    
    
    ///this function is for demo purposes only
    func pushWithTitle(text: String){
        let controller = UIViewController()
        controller.title = text
        controller.view.backgroundColor = UIColor.white
        self.navigationController?.pushViewController(controller, animated: true)
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
        var cell : SampleTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cellsearch") as! SampleTableViewCell
        if(cell == nil)
        {
            cell = Bundle.main.loadNibNamed("cellsearch", owner: self, options: nil)?[0] as! SampleTableViewCell;
        }
        let tonename = listtophit[indexPath.row].tonename as String //NOT NSString
        let singer = listtophit[indexPath.row].singer as String //NOT NSString
        var imgurl = listtophit[indexPath.row].singerimg as String //NOT NSString
        cell.lbtonename.text=tonename
        cell.lbsinger.text=singer
        

     
        return cell as SampleTableViewCell
    }
    
    
    func alamofireGetSearch(str: String) {
        showwaiting()
        let todoEndpoint: String = url + str.replacingOccurrences(of: " ", with: "%20")
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
                self.myTable.reloadData()
                self.stopwaiting()
                
        }
    }
    
    
    
    
    
}


extension SearchViewController: AZSearchViewDelegate{
    
    
    func searchView(_ searchView: AZSearchViewController, didSearchForText text: String) {
        var str:String=text
        print("search:\(text)")
        alamofireGetSearch (str: str)

        searchView.dismiss(animated: false, completion: nil)
    }
    
    func searchView(_ searchView: AZSearchViewController, didTextChangeTo text: String, textLength: Int) {
        self.resultArray.removeAll()
        
        if (textLength == 3) || (textLength==6) || (textLength==9){
            //for i in 0..<arc4random_uniform(10)+1 {self.resultArray.append("\(text) \(i+1) new")}
            alamofireGetSuggestion(str: text)
        }
        
        //searchView.reloadData()
    }
    
    func searchView(_ searchView: AZSearchViewController, didSelectResultAt index: Int, text: String) {
        self.searchController.dismiss(animated: true, completion: {
            //self.pushWithTitle(text: text)
            print("chon:\(text)" )
            var str:String=text
            print("search:\(text)")
            self.alamofireGetSearch (str: str)
            
        })
    }
    
    func searchView(_ searchView: AZSearchViewController, tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension SearchViewController: AZSearchViewDataSource{
    
    func statusBarStyle() -> UIStatusBarStyle {
        return .lightContent
    }
    
    func results() -> [String] {
        return self.resultArray
    }
    
    func searchView(_ searchView: AZSearchViewController, tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: searchView.cellIdentifier)
        cell?.textLabel?.text =  self.resultArray[indexPath.row]
        cell?.imageView?.image = #imageLiteral(resourceName: "music-note-02-icon_32x32px").withRenderingMode(.alwaysTemplate)
        cell?.imageView?.tintColor = UIColor.gray
        cell?.contentView.backgroundColor = .white
        return cell!
    }
    
    func searchView(_ searchView: AZSearchViewController, tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func searchView(_ searchView: AZSearchViewController, tableView: UITableView, editActionsForRowAtIndexPath indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let remove = UITableViewRowAction(style: .destructive, title: "Remove") { action, index in
            self.resultArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            //searchView.reloadData()
        }
        
        remove.backgroundColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
        
        
        return [remove]
    }
    

    func alamofireGetSuggestion(str:String) {
        print("str: \(str)")
        let todoEndpoint: String = "http://123.30.100.126:8081/RESTfulProject/REST/V3/suggesttion?type1=" + str.lowercased().replacingOccurrences(of: " ", with: "%20")
        print("todoEndpoint: \(todoEndpoint)")
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
                self.resultArray.removeAll()
                for element in json {
                    if let todoResult = Suggestion(json: element) {
                        self.resultArray.append(todoResult.name)
                    }
                }
                print("out suggestion:\(self.resultArray.count)")
                //self.collCasi.reloadData()
                //searchView.reloadData()
                self.searchController.reloadData()
                
        }
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
            
        }
        
    }

}






