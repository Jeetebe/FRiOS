//
//  Song.swift
//  BXSlider
//
//  Created by MacBook on 5/8/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import SwiftyJSON

class Song
{
    
    var tonename:String
    var toneid:String
    var tonecode:String
    var singer:String
    var prices:String
    var down:String
     var singerimg:String
    
    required init?(tonename:String,toneid:String,tonecode:String,singer:String,prices:String,down:String,singerimg:String)
    {
        self.tonename=tonename
        self.tonecode=tonecode
        self.toneid=toneid
        self.prices=prices
        self.down=down
        self.singer=singer
        self.singerimg=singerimg
    }
    
    required init?(json: SwiftyJSON.JSON) {
        self.tonename = json["tonename"].string!
        self.toneid = json["toneid"].string!
        self.tonecode = json["tonecode"].string!
         self.singer = json["singer"].string!
         self.singerimg = json["singerimg"].string!
         self.prices = json["price"].string!
        self.down = json["downtimes"].string!
        
    }
    convenience init?(json: [String: Any]) {
        guard let tonename = json["tonename"] as? String,
            let toneid = json["toneid"] as? String,
            let tonecode = json["tonecode"] as? String,
        
        
        let singer = json["singer"] as? String,
        let singerimg = json["singerimg"] as? String,
        let prices = json["price"] as? String,
        let down = json["downtimes"] as? String
            else {
                return nil
        }
        
        self.init(tonename: tonename,toneid: toneid,tonecode: tonecode,singer:singer,prices:prices,
                  down:down,singerimg:singerimg)    }

}
