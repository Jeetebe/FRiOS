//
//  BXSlideCell.swift
//  Pods
//
//  Created by Haizhen Lee on 16/4/19.
//
//

import Foundation
// Build for target uimodel
import UIKit


//-BXSlideCell(m=BXSlide):cc
//_[e0]:i
//title[hor15,b40,h36]:

class BXSlideCell : UICollectionViewCell{
  let imageView = UIImageView(frame:CGRect.zero)
  let titleLabel = UILabel(frame:CGRect.zero)
  let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  var item:BXSlide?
  func bind<T:BXSlide>(_ item:T,to slider:BXSlider<T>){
    self.item = item
    imageView.image = nil // 避免重用时出现老的图片
    //         imageView.kf_setImageWithURL(item._)
    if let image = item.bx_image{
      imageView.image = image
    }else{
      if let url = item.bx_imageURL{
        if let loader = slider.loadImageBlock{
         loader(url,imageView)
        }else{
         load(url as URL, toImageView: imageView)
        }
      }
    }
  }
  
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  var allOutlets :[UIView]{
    return [imageView,titleLabel,activityIndicator]
  }
  var allUIImageViewOutlets :[UIImageView]{
    return [imageView]
  }
  var allUILabelOutlets :[UILabel]{
    return [titleLabel]
  }
  
  func commonInit(){
    for childView in allOutlets{
      contentView.addSubview(childView)
      childView.translatesAutoresizingMaskIntoConstraints = false
    }
    installConstaints()
    setupAttrs()
    
  }
  
  func installConstaints(){
    imageView.pac_edge(0, left: 0, bottom: 0, right: 0)
    
    titleLabel.pa_height.eq(36).install()
    titleLabel.pa_bottom.eq(40).install()
    titleLabel.pac_horizontal(15)
    
    activityIndicator.pac_center()
    
  }
  
  func setupAttrs(){
    titleLabel.isHidden = true
    activityIndicator.isHidden = true
    activityIndicator.hidesWhenStopped = true
  }
  
  func load(_ imageURL:URL,toImageView imageView:UIImageView){
      activityIndicator.startAnimating()
      let loadTask =  URLSession.shared.dataTask(with: imageURL, completionHandler: { (data, resp, error) -> Void in
        if let data = data{
          let image = UIImage(data: data)
          DispatchQueue.main.async{
            imageView.image = image
            self.activityIndicator.stopAnimating()
          }
        }
      }) 
      loadTask.resume()
  }
}
