//
//  SampleTableViewCell.swift
//  Sample1
//
//  Created by TheAppGuruz-New-6 on 04/02/15.
//  Copyright (c) 2015 TheAppGuruz-New-6. All rights reserved.
//

import UIKit

class SampleTableViewCell: UITableViewCell
{

    @IBOutlet weak var imgsinger: UIImageView!
   
    @IBOutlet weak var lbtonename: UILabel!
    @IBOutlet weak var lbsinger: UILabel!
   

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      //lbtonename.sizeToFit()
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

}
