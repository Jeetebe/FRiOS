//
//  MKAccordionView.swift
//  AccrodianView
//
//  Created by Milan Kamilya on 26/06/15.
//  Copyright (c) 2015 Milan Kamilya. All rights reserved.
//

import UIKit
import Foundation

// MARK: - MKAccordionViewDelegate
@objc protocol MKAccordionViewDelegate : NSObjectProtocol {
    
    @objc optional func accordionView(_ accordionView: MKAccordionView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    @objc optional func accordionView(_ accordionView: MKAccordionView, heightForHeaderInSection section: Int) -> CGFloat
    @objc optional func accordionView(_ accordionView: MKAccordionView, heightForFooterInSection section: Int) -> CGFloat
    
    @objc optional func accordionView(_ accordionView: MKAccordionView, shouldHighlightRowAtIndexPath indexPath: IndexPath) -> Bool
    @objc optional func accordionView(_ accordionView: MKAccordionView, didHighlightRowAtIndexPath indexPath: IndexPath)
    @objc optional func accordionView(_ accordionView: MKAccordionView, didUnhighlightRowAtIndexPath indexPath: IndexPath)
    
    // Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
    @objc optional func accordionView(_ accordionView: MKAccordionView, willSelectRowAtIndexPath indexPath: IndexPath) -> IndexPath?
    @objc optional func accordionView(_ accordionView: MKAccordionView, willDeselectRowAtIndexPath indexPath: IndexPath) -> IndexPath?
    // Called after the user changes the selection.
    @objc optional func accordionView(_ accordionView: MKAccordionView, didSelectRowAtIndexPath indexPath: IndexPath)
    @objc optional func accordionView(_ accordionView: MKAccordionView, didDeselectRowAtIndexPath indexPath: IndexPath)
    
    
    @objc optional func accordionView(_ accordionView: MKAccordionView, viewForHeaderInSection section: Int, isSectionOpen sectionOpen: Bool) -> UIView?
    @objc optional func accordionView(_ accordionView: MKAccordionView, viewForFooterInSection section: Int, isSectionOpen sectionOpen: Bool) -> UIView?
}

// MARK: - MKAccordionViewDatasource
@objc protocol MKAccordionViewDatasource : NSObjectProtocol {
    
    func accordionView(_ accordionView: MKAccordionView, numberOfRowsInSection section: Int) -> Int
    
    func accordionView(_ accordionView: MKAccordionView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    
    @objc optional func numberOfSectionsInAccordionView(_ accordionView: MKAccordionView) -> Int // Default is 1 if not implemented
    
    @objc optional func accordionView(_ accordionView: MKAccordionView, titleForHeaderInSection section: Int) -> String? // fixed font style. use custom view (UILabel) if you want something different
    @objc optional func accordionView(_ accordionView: MKAccordionView, titleForFooterInSection section: Int) -> String?
    
}

// MARK: - MKAccordionView Main Definition
class MKAccordionView: UIView {
    
    var dataSource: MKAccordionViewDatasource?
    var delegate: MKAccordionViewDelegate?
    var tableView : UITableView?
    
    /// If you want to collapse other open sections when a single section get clicked, set true to isCollapsedAllWhenOneIsOpen.
    var isCollapsedAllWhenOneIsOpen : Bool? = false
    
    
    
    fileprivate var arrayOfBool : NSMutableArray?
    fileprivate var previousOpenedSection : Int? = -1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tableView = UITableView(frame: self.bounds)
        tableView?.delegate = self;
        tableView?.dataSource = self;
        tableView?.alwaysBounceVertical = true
        tableView?.backgroundColor = UIColor.clear
        
        
        self.addSubview(tableView!);
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func sectionHeaderTapped(_ recognizer: UITapGestureRecognizer) {
        print("Tapping working")
        print(recognizer.view?.tag)
        
        let indexPath : IndexPath = IndexPath(row: 0, section:(recognizer.view?.tag as Int!)!)
        if (indexPath.row == 0) {
            
            var collapsed : Bool! = (arrayOfBool?.object(at: indexPath.section) as AnyObject).boolValue
            collapsed       = !collapsed;
            
            if isCollapsedAllWhenOneIsOpen! {
                
                if previousOpenedSection != -1 {
                    //reload previous opened section animated
                    arrayOfBool?.replaceObject(at: previousOpenedSection!, with: NSNumber(value: false as Bool))

                    let range = NSMakeRange(previousOpenedSection!, 1)
                    let sectionToReload = IndexSet(integersIn: range.toRange() ?? 0..<0)
                    tableView?.reloadSections(sectionToReload, with:UITableViewRowAnimation.fade)
                    
                }
            }
            
            arrayOfBool?.replaceObject(at: indexPath.section, with: NSNumber(value: collapsed as Bool))

            
            //reload specific section animated
            let range = NSMakeRange(indexPath.section, 1)
            let sectionToReload = IndexSet(integersIn: range.toRange() ?? 0..<0)
            tableView?.reloadSections(sectionToReload, with:UITableViewRowAnimation.fade)
            
            
            if collapsed! {
                previousOpenedSection = (recognizer.view?.tag as Int!)!
            } else {
                previousOpenedSection = -1
            }
        }
        
    }
}


// MARK: - Implemention of UITableViewDelegate methods
extension MKAccordionView : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height : CGFloat! = 0.0
        
        let collapsed: Bool! = (arrayOfBool?.object(at: indexPath.section) as AnyObject).boolValue

        if collapsed! {
            if (delegate?.responds(to: #selector(MKAccordionViewDelegate.accordionView(_:heightForRowAtIndexPath:))))! {
                height = delegate?.accordionView!(self, heightForRowAtIndexPath: indexPath)
            }
        }
        
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height : CGFloat! = 0.0
        if (delegate?.responds(to: #selector(MKAccordionViewDelegate.accordionView(_:heightForHeaderInSection:))))! {
           height = delegate?.accordionView!(self, heightForHeaderInSection: section)
        }
        return height

    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var height : CGFloat! = 0.0
        if (delegate?.responds(to: #selector(MKAccordionViewDelegate.accordionView(_:heightForFooterInSection:))))! {
            height = delegate?.accordionView!(self, heightForFooterInSection: section)
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        
        var selection : Bool! = true
        if (delegate?.responds(to: #selector(MKAccordionViewDelegate.accordionView(_:shouldHighlightRowAtIndexPath:))))!{
            selection = delegate?.accordionView!(self, shouldHighlightRowAtIndexPath: indexPath)
        }
        
        return selection
    }
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if (delegate?.responds(to: #selector(MKAccordionViewDelegate.accordionView(_:didHighlightRowAtIndexPath:))))!{
            delegate?.accordionView!(self, didHighlightRowAtIndexPath: indexPath)
        }
    }
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if (delegate?.responds(to: #selector(MKAccordionViewDelegate.accordionView(_:didUnhighlightRowAtIndexPath:))))!{
            delegate?.accordionView!(self, didUnhighlightRowAtIndexPath: indexPath)
        }
    }
    
    // Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        var indexPathSelection: IndexPath? = indexPath
        if (delegate?.responds(to: #selector(MKAccordionViewDelegate.accordionView(_:willSelectRowAtIndexPath:))))!{
            indexPathSelection = delegate?.accordionView!(self, willSelectRowAtIndexPath: indexPath)
        }
        return indexPathSelection;
    }
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        var indexPathSelection: IndexPath? = indexPath
        if (delegate?.responds(to: #selector(MKAccordionViewDelegate.accordionView(_:willDeselectRowAtIndexPath:))))!{
            indexPathSelection = delegate?.accordionView!(self, willDeselectRowAtIndexPath: indexPath)
        }
        return indexPathSelection;
    }
    // Called after the user changes the selection.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (delegate?.responds(to: #selector(MKAccordionViewDelegate.accordionView(_:didSelectRowAtIndexPath:))))!{
            delegate?.accordionView!(self, didSelectRowAtIndexPath: indexPath)
        }
        print("accordionView:didSelectRowAtIndexPath: Section::\(indexPath.section) Row::\(indexPath.row)")
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if (delegate?.responds(to: #selector(MKAccordionViewDelegate.accordionView(_:didDeselectRowAtIndexPath:))))!{
            delegate?.accordionView!(self, didDeselectRowAtIndexPath: indexPath)
        }
        print("accordionView:didDeselectRowAtIndexPath: Section::\(indexPath.section) Row::\(indexPath.row)")

    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var view : UIView! = nil
        if (delegate?.responds(to: #selector(MKAccordionViewDelegate.accordionView(_:viewForHeaderInSection:isSectionOpen:))))! {
            
            let collapsed: Bool! = (arrayOfBool?.object(at: section) as AnyObject).boolValue
            
            view = delegate?.accordionView!(self, viewForHeaderInSection: section, isSectionOpen: collapsed)
            view.tag = section;
            
            // tab recognizer
            let headerTapped = UITapGestureRecognizer (target: self, action:#selector(MKAccordionView.sectionHeaderTapped(_:)))
            view .addGestureRecognizer(headerTapped)
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        var view : UIView! = nil
        if (delegate?.responds(to: #selector(MKAccordionViewDelegate.accordionView(_:viewForFooterInSection:isSectionOpen:))))! {
            
            let collapsed: Bool! = false
            view = delegate?.accordionView!(self, viewForFooterInSection: section, isSectionOpen: collapsed)
            
        }
        
        return view
    }
}

// MARK: - Implemention of UITableViewDataSource methods
extension MKAccordionView : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var no : Int! = 0
        
        let collapsed: Bool! = (arrayOfBool?.object(at: section) as AnyObject).boolValue

        if collapsed! {
        
            if (dataSource?.responds(to: #selector(MKAccordionViewDatasource.accordionView(_:numberOfRowsInSection:))))! {
                no = dataSource?.accordionView(self, numberOfRowsInSection: section)
            }
        }
        
        return no
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = nil
        if (dataSource?.responds(to: #selector(MKAccordionViewDatasource.accordionView(_:cellForRowAtIndexPath:))))! {
            cell = (dataSource?.accordionView(self, cellForRowAtIndexPath: indexPath))!
        }
        
        return cell!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var numberOfSections : Int! = 1
        if (dataSource?.responds(to: #selector(MKAccordionViewDatasource.numberOfSectionsInAccordionView(_:))))! {
            numberOfSections = dataSource?.numberOfSectionsInAccordionView!(self)
            
            if arrayOfBool == nil {
                arrayOfBool = NSMutableArray()
                let sections : Int! = numberOfSections - 1
                for _ in 0...sections {
                    arrayOfBool?.add(NSNumber(value: false as Bool))
                }
            }
            
        }
        return numberOfSections;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var title : String! = nil
        
        if (dataSource?.responds(to: #selector(MKAccordionViewDatasource.accordionView(_:titleForHeaderInSection:))))! {
            title = dataSource?.accordionView!(self, titleForHeaderInSection: section)
        }
        
        return title
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        var title : String! = nil
        
        if (dataSource?.responds(to: #selector(MKAccordionViewDatasource.accordionView(_:titleForFooterInSection:))))! {
            title = dataSource?.accordionView!(self, titleForFooterInSection: section)
        }
        
        return title
    }
    
}


