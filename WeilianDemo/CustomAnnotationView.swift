//
//  CustomAnnotationView.swift
//  WeilianDemo
//
//  Created by 刘明 on 15/7/13.
//  Copyright (c) 2015年 刘明. All rights reserved.
//

import UIKit

protocol CustomAnnotationDelegate {
    func pathAction()
    func setDestinationPoint(coor: CLLocationCoordinate2D)
}

class CustomAnnotationView: MAAnnotationView, CustomCalloutDelegate {
    
    let kCalloutWidth: CGFloat = 200.0
    let kCalloutHeight: CGFloat = 70.0
    
    private(set) internal var calloutView: CustomCalloutView?
    
    var delegate: CustomAnnotationDelegate?
    
    // MARK: - Override
    override func setSelected(selected: Bool, animated: Bool) {
        if self.selected == selected {
            return
        }
        
        if selected {
            if self.calloutView == nil {
                self.calloutView = CustomCalloutView(frame: CGRectMake(0, 0, kCalloutWidth, kCalloutHeight))
                self.calloutView!.center = CGPointMake(CGRectGetWidth(self.bounds) / 2 + self.calloutOffset.x,
                    -CGRectGetHeight(self.calloutView!.bounds) / 2 + self.calloutOffset.y)
            }
            self.calloutView!.image = UIImage(named: "building")!
            self.calloutView!.title = self.annotation.title!()
            self.calloutView!.subtitle = self.annotation.subtitle!()
            self.calloutView!.delegate = self
            /*
            self.addSubview(self.calloutView!)
            */
        } else {
            if self.calloutView != nil {
                self.calloutView!.removeFromSuperview()
            }
        }
        
        super.setSelected(selected, animated: animated)
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        var inside = super.pointInside(point, withEvent: event) as Bool
        
        if !inside && self.selected {
            inside = self.calloutView!.pointInside(self.convertPoint(point, toView: self.calloutView!), withEvent: event)
        }
        
        if inside {
            // 设置目的地点
            self.delegate?.setDestinationPoint(self.annotation.coordinate)
        }
        
        return inside
    }
    
    func childPathAction() {
        self.delegate?.pathAction()
    }
}
