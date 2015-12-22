//
//  CustomCalloutView.swift
//  WeilianDemo
//
//  Created by 刘明 on 15/7/13.
//  Copyright (c) 2015年 刘明. All rights reserved.
//

import UIKit

protocol CustomCalloutDelegate {
    func childPathAction()
}

class CustomCalloutView: UIView {
    
    let kArrorHeight: CGFloat = 10
    
    let kPortraitMargin: CGFloat = 5
    let kPortraitWidth: CGFloat = 40
    let kPortraitHeight: CGFloat = 50
    
    let kTitleWidth: CGFloat = 200
    let kTitleHeight: CGFloat = 20
    
    var portraitView: UIImageView?
    var subtitleLabel: UILabel?
    var titleLabel: UILabel?
    var pathButton: UIButton?
    
    var delegate: CustomCalloutDelegate?
    
    private var _image: UIImage?
    var image: UIImage? {
        get {
            return self._image
        }
        set {
            self._image = newValue
            self.portraitView?.image = self._image
        }
    }
    private var _title: String?
    var title: String? {
        get {
            return self._title
        }
        set {
            self._title = newValue
            self.titleLabel?.text = self._title
        }
    }
    private var _subtitle: String?
    var subtitle: String? {
        get {
            return self._subtitle
        }
        set {
            self._subtitle = newValue
            self.subtitleLabel?.text = self._subtitle
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        self.initSubViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubViews() {
        // title
        self.titleLabel = UILabel()
        self.titleLabel!.frame = CGRectMake(kPortraitMargin, kPortraitMargin, kTitleWidth, kTitleHeight)
        self.titleLabel!.font = UIFont.systemFontOfSize(14)
        self.titleLabel!.textColor = UIColor.whiteColor()
        self.titleLabel!.text = self._title
        self.addSubview(self.titleLabel!)
        
        self.subtitleLabel = UILabel()
        self.subtitleLabel!.frame = CGRectMake(kPortraitMargin, kPortraitMargin * 2 + kTitleHeight, kTitleWidth, kTitleHeight)
        self.subtitleLabel!.font = UIFont.systemFontOfSize(12)
        self.subtitleLabel!.textColor = UIColor.lightGrayColor()
        self.subtitleLabel!.text = self._subtitle
        self.addSubview(self.subtitleLabel!)
        
        // buttom
        self.pathButton = UIButton(type: UIButtonType.Custom)
        self.pathButton!.frame = CGRectMake(kTitleWidth, kPortraitMargin,
            kPortraitWidth, kPortraitHeight)
        self.pathButton!.backgroundColor = UIColor.clearColor()
        self.pathButton!.addTarget(self, action: "lookPath", forControlEvents: .TouchUpInside)
        self.pathButton!.setTitle("查看线路", forState: .Normal)
        self.pathButton!.titleLabel?.lineBreakMode = .ByWordWrapping
        self.pathButton!.titleLabel?.numberOfLines = 2
        self.pathButton!.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.pathButton!.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        self.pathButton!.titleLabel?.font = UIFont.systemFontOfSize(12)
//        self.addSubview(self.pathButton!)
    }
    
    // MARK: - action
    
    func lookPath() {
        self.delegate?.childPathAction()
    }

    // MARK: - draw rect
    
    override func drawRect(rect: CGRect) {
        self.drawInContext(UIGraphicsGetCurrentContext()!)
        
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowOffset = CGSizeMake(0.0, 0.0)
    }
    
    func drawInContext(context: CGContextRef) {
        CGContextSetLineWidth(context, 2.0)
        CGContextSetFillColorWithColor(context, UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.8).CGColor)
        self.getDrawPath(context)
        CGContextFillPath(context)
    }
    
    func getDrawPath(context: CGContextRef) {
        let rrect = self.bounds
        let radius: CGFloat = 6.0
        
        let minx = CGRectGetMinX(rrect)
        let midx = CGRectGetMidX(rrect)
        let maxx = CGRectGetMaxX(rrect)
        
        let miny = CGRectGetMinY(rrect)
        let maxy = CGRectGetMaxY(rrect) - kArrorHeight
        
        CGContextMoveToPoint(context, midx+kArrorHeight, maxy)
        CGContextAddLineToPoint(context, midx, maxy+kArrorHeight)
        CGContextAddLineToPoint(context, midx-kArrorHeight, maxy)
        
        CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius)
        CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius)
        CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius)
        CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius)
        CGContextClosePath(context)
    }
}
