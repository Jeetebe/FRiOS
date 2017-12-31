//
//  BXSlider.swift
//

import UIKit
import PinAuto

#if DEBUG
private let debug = false
#else
private let debug = false
#endif

open class BXSlider<T:BXSlide>: UIView, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
  open fileprivate(set) var slides:[T] = []
  fileprivate var loopSlides: [T] = []
  open let pageControl = UIPageControl()
  fileprivate let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
  open var scrollView:UICollectionView{
    return collectionView
  }
  open var imageScaleMode: UIViewContentMode = .scaleAspectFill
  open var autoSlide = true
  open var onTapBXSlideHandler: ( (T) -> Void)?
  open var loadImageBlock:( (_ URL:URL,_ imageView:UIImageView) -> Void  )?
  
  // 重新注册 bxSlideCellIdentifier 的 Cell 之后便可以使用 此 Block 来 configure 自定义的 各 Cell
  open var configureCellBlock: ( (_ cell:UICollectionViewCell,_ indexPath:IndexPath) -> Void )?
  
  fileprivate let flowlayout = UICollectionViewFlowLayout()
  var isFirstStart = true
  open var loopEnabled = true
  
  public convenience init(){
    self.init(frame: CGRect(x: 0, y: 0, width: 320, height: 120))
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.frame = frame
    commonInit()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  open override func awakeFromNib() {
    super.awakeFromNib()
    commonInit()
  }
  
  func commonInit(){
    addSubview(scrollView)
    addSubview(pageControl)
    
    installConstraints()
    setupAttrs()
   
    collectionView.register(BXSlideCell.self, forCellWithReuseIdentifier: bxSlideCellIdentifier)
    
    flowlayout.minimumLineSpacing = 0
    flowlayout.minimumInteritemSpacing = 0
    flowlayout.sectionInset = UIEdgeInsets.zero
    flowlayout.scrollDirection = .horizontal
    
    collectionView.collectionViewLayout = flowlayout
    collectionView.dataSource = self
    collectionView.delegate = self
    
  }
  
  func installConstraints(){
    scrollView.pac_edge()
    
    pageControl.pac_horizontal(15)
    pageControl.pa_bottom.eq(15).install()
    pageControl.pa_height.eq(20).install()
  }
  
  func setupAttrs(){
    scrollView.clipsToBounds = true
    scrollView.alwaysBounceHorizontal = false
    scrollView.alwaysBounceVertical = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.bounces = false
    scrollView.bouncesZoom = false
    scrollView.isPagingEnabled = true
    pageControl.currentPageIndicatorTintColor = UIColor.white
    pageControl.pageIndicatorTintColor = UIColor(white: 0.5, alpha: 0.8)
    pageControl.clipsToBounds = true
  }
  
  open override func layoutSubviews() {
    super.layoutSubviews()
    // 需要在 Layout 中确定 itemSize
    let itemSize = bounds.size
    flowlayout.itemSize = itemSize
    if loopEnabled && !loopSlides.isEmpty {
      let indexPath = IndexPath(row: 1, section: 0)
      collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }
  }
  
  
  func onPageChanged(){
  }
  
  open func updateSlides(_ rawSlides:[T]){
    slides.removeAll()
    if !rawSlides.isEmpty{
      self.slides.append(contentsOf: rawSlides)
    }
    loopSlides.removeAll()
    loopSlides.append(contentsOf: rawSlides)
    
    if let first = rawSlides.first{
      loopSlides.insert(first, at: 0)
    }
    if let last = rawSlides.last{
      loopSlides.append(last)
    }
    
    pageControl.numberOfPages =  rawSlides.count
    pageControl.currentPage = 0
    collectionView.reloadData()
    if loopEnabled && !loopSlides.isEmpty{
      let indexPath = IndexPath(row: 1, section: 0)
      collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }
    if autoSlide{
      if let first = slides.first{
        fireTimerAfterDeplay(first.bx_duration)
      }
    }

  }
  
  func updatePageControl(){
    guard  let index = currentPageIndexPath else {
      return
    }
    if debug { NSLog("currentIndexPath: \(index.to_s)") }
    if loopEnabled{
      if index.item == 0 {
        pageControl.currentPage = slides.count - 1
      }else if index.item == loopSlides.count - 1 {
        pageControl.currentPage = 0
      }else{
        pageControl.currentPage = index.item - 1
      }
    }else{
      pageControl.currentPage = index.item
    }
  }
  
  
  open func slideAtCurrentPage() -> T?{
    if let index = currentPageIndexPath {
      return itemAtIndexPath(index)
    }
    return nil
  }
  
  var currentPageIndexPath:IndexPath?{
    let bounds = collectionView.bounds
    return collectionView.indexPathForItem(at: CGPoint(x: bounds.midX, y: bounds.midY))
  }
  
  
  // MARK: Auto Turn Page
  
  var timer:Timer?
  
  open override func willMove(toWindow newWindow: UIWindow?) {
    super.willMove(toWindow: newWindow)
    if newWindow == nil{
      // remove from window
      removeTimer()
    }else{
      addTimerIfNeeded()
    }
  }
  
  func onAutoTurnPageTimerFired(){
    autoTurnPage()
  }
  
  //  BXSlider:UICollectionViewDataSource{
  open func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  fileprivate var numberOfItems:Int {
    if loopEnabled{
       return loopSlides.count
    }else{
      return slides.count
    }
  }
  
  open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return numberOfItems
  }
  
  open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: bxSlideCellIdentifier, for: indexPath)
    let item = itemAtIndexPath(indexPath)
    if let slideCell = cell as? BXSlideCell{
      slideCell.bind(item, to: self)
      slideCell.imageView.contentMode = imageScaleMode
    }
    configureCellBlock?(cell,indexPath)
    return cell
  }
  
  // UICollectionViewDelegateFlowLayout
  
  open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let item = itemAtIndexPath(indexPath)
    onTapBXSlideHandler?(item)
  }
 
  // UIScrollViewDelegate
  open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//    if debug { NSLog("\(#function)") }
    removeTimer()
  }

  
  open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    if debug { NSLog("\(#function)") }
      addTimerIfNeeded()
    handleSlideToFirstAndLastSlide()
      updatePageControl()
  }
  
  open func scrollViewDidScroll(_ scrollView: UIScrollView) {
//    if debug { NSLog("\(#function)") }
  }
  
  func handleSlideToFirstAndLastSlide(){
    if !loopEnabled{
      return
    }
    guard let currentIndexPath = currentPageIndexPath else{
      return
    }
    if debug { NSLog("[\(self.loopSlides.count)] currentIndexPath: \(currentIndexPath.to_s)") }
    let index = currentIndexPath.item
    if index == self.loopSlides.count - 1 {
      if debug { NSLog("loopToFirst") }
      let indexPath = IndexPath(item: 1, section: 0)
      collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
      pageControl.currentPage = 0
    }else if index == 0{
      if debug { NSLog("loopToLast") }
      let indexPath = IndexPath(item: self.loopSlides.count - 1, section: 0)
      collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
      pageControl.currentPage = pageControl.numberOfPages - 1
    }
  }
  
}

extension IndexPath{
  var to_s:String{
    return "[\(section),\(item)]"
  }
}

public let bxSlideCellIdentifier = "slideCell"

extension BXSlider{
  
  public func itemAtIndexPath(_ indexPath:IndexPath) -> T{
    if loopEnabled{
      return loopSlides[indexPath.item]
    }else{
      return slides[indexPath.item]
    }
  }
  
}

// MARK: Slide Load Support
extension BXSlider{

  
}

//MARK: Auto Turn Page Support

extension BXSlider{
  func addTimerIfNeeded(){
    if !autoSlide{
      return
    }
    if let slide = slideAtCurrentPage(){
      addTimer(slide)
    }
  }
  
  func addTimer(_ nextSlide:T){
    if !autoSlide{
      return
    }
    let duration = max(1,nextSlide.bx_duration)
    fireTimerAfterDeplay(duration)
  }
  
  func fireTimerAfterDeplay(_ deplay:TimeInterval){
    timer?.invalidate()
    timer = Timer.scheduledTimer(timeInterval: deplay, target: self, selector: #selector(onAutoTurnPageTimerFired), userInfo: nil, repeats: false)
  }
  
  func removeTimer(){
    timer?.invalidate()
    timer = nil
  }
  
  func nextCycleIndexPathOf(_ indexPath:IndexPath) -> IndexPath{
    let index = (indexPath.item + 1) % numberOfItems
    return IndexPath(item: index, section: 0)
  }
  
  func nextCycleItemOfIndexPath(_ indexPath:IndexPath) -> T?{
    guard let indexPath = currentPageIndexPath else{
      return nil
    }
    let nextIndexPath =  nextCycleIndexPathOf(indexPath)
    return itemAtIndexPath(nextIndexPath)
  }
  
  func autoTurnPage(){
    guard let indexPath =  currentPageIndexPath else{
      if autoSlide{ // 当前可能界面还没显示出来 .
        fireTimerAfterDeplay(2)
      }
      return
    }
    if slides.count < 2{
      return
    }
    let nextIndexPath = nextCycleIndexPathOf(indexPath)
    if debug { NSLog("nextIndexPath: \(nextIndexPath)") }
    if autoSlide{
     let nextSlide = itemAtIndexPath(nextIndexPath)
      addTimer(nextSlide)
    }
    self.collectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
    self.pageControl.currentPage = nextIndexPath.item
    onPageChanged()
  }
  
}
