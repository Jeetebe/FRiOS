//
//  TinhObj.swift
//  IOS8SwiftTabBarControllerTutorial
//
//  Created by MacBook on 4/30/17.
//  Copyright © 2017 Arthur Knopper. All rights reserved.
//

import Foundation
import SwiftyJSON

class Suggestion
{
    var name:String = ""
       required init?(_tinhdau: String?) {
        self.name = _tinhdau!
      
     
        
    }

    required init?(json: SwiftyJSON.JSON) {
        self.name = json["suggestion"].string!
                }
    
    convenience init?(json: [String: Any]) {
        guard let _tinhdau = json["suggestion"] as? String
        
                       else {
                return nil
        }
        
        self.init(_tinhdau:_tinhdau)    }
    
}
