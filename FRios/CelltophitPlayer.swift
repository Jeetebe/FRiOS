import UIKit

class CelltophitPlayer: UITableViewCell
{
    
    @IBOutlet weak var imgsinger: UIImageView!
    
    @IBOutlet weak var lbtonename: UILabel!
    @IBOutlet weak var lbsinger: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //lbtonename.sizeToFit()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
