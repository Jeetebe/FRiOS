//
//  TinhObj.swift
//  IOS8SwiftTabBarControllerTutorial
//
//  Created by MacBook on 4/30/17.
//  Copyright © 2017 Arthur Knopper. All rights reserved.
//

import Foundation
import SwiftyJSON

class Singer
{
    var name:String = ""
    var nameid:String = ""
    var imgurl:String = ""
     required init?(_tinhdau: String?, _tinhid: String?, _ngay: String?) {
        self.name = _tinhdau!
        self.nameid=_tinhid!
        self.imgurl=_ngay!
     
        
    }

    required init?(json: SwiftyJSON.JSON) {
        self.name = json["name1"].string!
        self.nameid = json["name2"].string!
        self.imgurl = json["name3"].string!
          }
    
    convenience init?(json: [String: Any]) {
        guard let _tinhdau = json["name1"] as? String,
            let _tinhid = json["name2"] as? String,
            let _ngay = json["name3"] as? String
                       else {
                return nil
        }
        
        self.init(_tinhdau:_tinhdau,_tinhid:_tinhid,_ngay:_ngay)    }
    
}
