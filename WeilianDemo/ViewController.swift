//
//  ViewController.swift
//  WeilianDemo
//
//  Created by 刘明 on 15/7/9.
//  Copyright (c) 2015年 刘明. All rights reserved.
//

import UIKit

let APIKey = "0fafdbd451558a1f2c1ca20377a7be91"
let cellIdentifier = "cellIdentifier"
let annotationIndetifier = "annotationIndetifier"

let kDefaultLocationZoomLevel: CGFloat = 16.1
let kDefaultControlMargin: CGFloat = 22
let kDefaultCalloutViewMargin: CGFloat = -8
let kDefaultZoomSize: CGFloat = 48
let kDefaultMargin: CGFloat = 10

class ViewController: UIViewController, MAMapViewDelegate, AMapSearchDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CustomAnnotationDelegate, UIScrollViewDelegate {
    
    var _mapView: MAMapView?
    var _search: AMapSearchAPI?
    
    var _currentLocation: CLLocation?
    var _locationButton: UIButton?
    var _searchTextField: UITextField?
    var _zoomoutButton: UIButton?
    var _zoominButton: UIButton?
    var _cancleButton: UIButton?
    var _confirmButton: UIButton?
    var _statiumLabel: UILabel?
    weak var _statiumView: UIView?
    weak var _closeButton: UIButton?
    
    var _isSearchTxfShowing: Bool = false
    var _isStatiumViewShowing: Bool = false
    
    var _tableView: UITableView?
    var _pois: [AMapPOI]?
    var _tips: [AMapTip]?
    
    var _annotations: NSMutableArray?
    
    var _destinationPoint: MAPointAnnotation?
    var _pathPolylines: NSArray?
    
    private var _statiumName: String?
    var statiumName: String? {
        get {
            return self._statiumName
        }
        set {
            self._statiumName = newValue
            self._statiumLabel?.text = self._statiumName
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initMapView()
        self.initSearch()
        self.initAttributes()
        self.initSearchBar()
        self.initZoomButtons()
        self.initControls()
        self.initStatiumInfoView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initMapView() {
        MAMapServices.sharedServices().apiKey = APIKey
        _mapView = MAMapView(frame: CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)))
        _mapView!.delegate = self
        _mapView!.showsCompass = false
        _mapView!.showsScale = false
        
        self.view.addSubview(_mapView!)
        
        _mapView!.showsUserLocation = true
        // 设置跟随定位模式，将定位点设置成地图中心点
        _mapView!.userTrackingMode = MAUserTrackingModeFollow
        _mapView!.setZoomLevel(CGFloat(15), animated: true)
    }
    
    func initSearch() {
        _search = AMapSearchAPI(searchKey: APIKey, delegate: self)
    }
    
    func initTipsRequest(keywords: String, city: String) {
        if _search == nil {
            return
        }
        // 构造 AMapInputTips 对象
        var tipsRequest = AMapInputTipsSearchRequest()
        tipsRequest.searchType = AMapSearchType.InputTips
        tipsRequest.keywords = keywords
        tipsRequest.city = [city]
        
        _search!.AMapInputTipsSearch(tipsRequest)
    }
    
    func initAttributes() {
        _annotations = NSMutableArray()
        _pois = []
        _tips = []
        _pathPolylines = []
    }
    
    func initTableView(searchFrame: CGRect) {
        var tableHeight = CGRectGetHeight(self.view.bounds) * 0.7
        
        _tableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Plain)
        _tableView!.delegate = self
        _tableView!.dataSource = self
        _tableView!.userInteractionEnabled = true

        _mapView!.addSubview(_tableView!)
    }
    
    func initSearchBar() {
        _searchTextField = UITextField()
        _searchTextField!.frame = CGRectMake(kDefaultControlMargin, kDefaultControlMargin + 5, CGRectGetWidth(self.view.bounds) - 88, 40)
        _searchTextField!.backgroundColor = UIColor.whiteColor()
        _searchTextField!.placeholder = "搜索"
        _searchTextField!.font = UIFont.systemFontOfSize(16)
        _searchTextField!.textColor = UIColor.lightGrayColor()
        _searchTextField!.returnKeyType = UIReturnKeyType.Search
        _searchTextField!.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin |
            UIViewAutoresizing.FlexibleBottomMargin
        
        var searchButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        searchButton.frame = CGRectMake(5, 5, 40, 30)
        searchButton.backgroundColor = UIColor.clearColor()
        searchButton.tintColor = UIColor.darkGrayColor()
        searchButton.setImage(UIImage(named: "search"), forState: .Normal)
        searchButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        
        var closeButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        closeButton.frame = CGRectMake(CGRectGetWidth(_searchTextField!.frame)-30, 7.5, 25, 25)
        closeButton.backgroundColor = UIColor.clearColor()
        closeButton.tintColor = UIColor.darkGrayColor()
        closeButton.setImage(UIImage(named: "close"), forState: .Normal)
        closeButton.addTarget(self, action: "closeAction", forControlEvents: .TouchUpInside)
        _closeButton = closeButton
        
        _searchTextField!.leftView = searchButton
        _searchTextField!.leftView?.userInteractionEnabled = false
        _searchTextField!.leftViewMode = UITextFieldViewMode.Always
        _searchTextField!.rightView = closeButton
        _searchTextField!.rightView?.userInteractionEnabled = true
        _searchTextField!.rightViewMode = UITextFieldViewMode.Always
        _searchTextField!.layer.borderWidth = 0.5
        _searchTextField!.layer.borderColor = UIColor.whiteColor().CGColor
        _searchTextField!.clipsToBounds = true
        _searchTextField!.delegate = self
        _searchTextField!.autocorrectionType = UITextAutocorrectionType.No
        _searchTextField!.layer.shadowColor = UIColor.grayColor().CGColor
        _searchTextField!.layer.shadowOpacity = 1.0
        _searchTextField!.layer.shadowOffset = CGSizeMake(1.0, 1.0)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldDidChange:",
            name: UITextFieldTextDidChangeNotification, object: _searchTextField)
        
        _mapView!.addSubview(_searchTextField!)
        
        self.initTableView(_searchTextField!.frame)
    }
    
    func initZoomButtons() {
        _zoominButton = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        _zoominButton!.frame = CGRectMake(CGRectGetMaxX(_searchTextField!.frame) + 10, kDefaultControlMargin, kDefaultZoomSize, kDefaultZoomSize)
        _zoominButton!.backgroundColor = UIColor.clearColor()
        _zoominButton!.tintColor = UIColor.darkGrayColor()
        _zoominButton!.setImage(UIImage(named: "zoomin"), forState: .Normal)
        _zoominButton!.addTarget(self, action: "zoomIn", forControlEvents: .TouchUpInside)
        _zoominButton!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin |
            UIViewAutoresizing.FlexibleBottomMargin
        
        _zoomoutButton = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        _zoomoutButton!.frame = CGRectMake(CGRectGetMinX(_zoominButton!.frame), CGRectGetMaxY(_zoominButton!.frame), kDefaultZoomSize, kDefaultZoomSize)
        _zoomoutButton!.backgroundColor = UIColor.clearColor()
        _zoomoutButton!.tintColor = UIColor.darkGrayColor()
        _zoomoutButton!.setImage(UIImage(named: "zoomout"), forState: .Normal)
        _zoomoutButton!.addTarget(self, action: "zoomOut", forControlEvents: .TouchUpInside)
        
        _mapView!.addSubview(_zoomoutButton!)
        _mapView!.addSubview(_zoominButton!)
    }
    
    func initControls() {
        _locationButton = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        _locationButton!.frame = CGRectMake(CGRectGetMidX(_zoominButton!.frame) - 20, CGRectGetHeight(_mapView!.bounds) - 50, 40, 40)
        _locationButton!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin |
            UIViewAutoresizing.FlexibleTopMargin
        _locationButton!.backgroundColor = UIColor.whiteColor()
        _locationButton!.layer.cornerRadius = 5
        _locationButton!.tintColor = UIColor.darkGrayColor()
        _locationButton!.addTarget(self, action: "locateAction", forControlEvents: .TouchUpInside)
        _locationButton!.setImage(UIImage(named: "location_no"), forState: .Normal)
        
        _mapView!.addSubview(_locationButton!)
    }
    
    // MARK: - Helpers
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if scrollView.isKindOfClass(UITableView.self) {
            hideKeyboard()
        }
    }
    
    func closeAction() {
        _searchTextField!.text = ""
        hideSearchResult()
        hideKeyboard()
        hideStatiumView()
        //清空
        if _annotations!.count > 0 {
            _mapView!.removeAnnotations(NSArray(array: _annotations!) as [AnyObject])
            _annotations!.removeAllObjects()
        }
        if _destinationPoint != nil {
            _mapView!.removeAnnotation(_destinationPoint)
            _destinationPoint = nil
            
            if _pathPolylines != nil {
                _mapView!.removeOverlays(_pathPolylines! as [AnyObject])
                _pathPolylines = nil
            }
        }
    }
    
    func zoomIn() {
        _mapView!.setZoomLevel(_mapView!.zoomLevel + 1, animated: true)
    }
    
    func zoomOut() {
        _mapView!.setZoomLevel(_mapView!.zoomLevel - 1, animated: true)
    }
    
    func handleSwipe(sender: UISwipeGestureRecognizer) {
        if sender.direction == UISwipeGestureRecognizerDirection.Down
            || sender.direction == UISwipeGestureRecognizerDirection.Up {
                self.hideKeyboard()
        }
    }
    
    func showSearchResult() {
        UIView.animateWithDuration(0.2,
            animations: { () -> Void in
                self._tableView!.frame = CGRectMake(CGRectGetMinX(self._searchTextField!.frame),
                    CGRectGetMaxY(self._searchTextField!.frame),
                    CGRectGetWidth(self._searchTextField!.bounds),
                    CGRectGetHeight(self.view.bounds) * 0.7)
            }) { (completed: Bool) -> Void in
                if completed {
                    self._isSearchTxfShowing = true
                }
        }
    }
    
    func hideSearchResult() {
        UIView.animateWithDuration(0.2,
            animations: { () -> Void in
                self._tableView!.frame = CGRectMake(CGRectGetMinX(self._searchTextField!.frame),
                    CGRectGetMaxY(self._searchTextField!.frame),
                    CGRectGetWidth(self._searchTextField!.bounds), 0)
            }) { (completed: Bool) -> Void in
                if completed {
                    self._isSearchTxfShowing = false
                }
        }
    }
    
    func hideKeyboard() {
        if _searchTextField!.isFirstResponder() {
            _searchTextField!.resignFirstResponder()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        println("search")
        if textField.text == "" {
            return true
        }
        self.searchAction(textField.text)
        self.hideKeyboard()
        self.hideSearchResult()
        
        return true
    }
    
    func textFieldDidChange(noti: NSNotification) {
        if count(_searchTextField!.text) > 0 {
            
            self.initTipsRequest(_searchTextField!.text, city: "上海")
            
            if !_isSearchTxfShowing {
                self.showSearchResult()
            }
        }
        
        if count(_searchTextField!.text) == 0 || _searchTextField!.text == "" {
            if _isSearchTxfShowing {
                self.hideSearchResult()
            }
        }
    }

    func offsetToContainsRect(innerRect: CGRect, inRect outerRect: CGRect) -> CGSize {
        let nudgeRight = fmaxf(Float(0), Float(CGRectGetMinX(outerRect) - (CGRectGetMinX(innerRect))))
        let nudgeLeft = fminf(Float(0), Float(CGRectGetMaxX(outerRect) - (CGRectGetMaxX(innerRect))))
        let nudgeTop = fmaxf(Float(0), Float(CGRectGetMinY(outerRect) - (CGRectGetMinY(innerRect))))
        let nudgeBottom = fminf(Float(0), Float(CGRectGetMaxY(outerRect) - (CGRectGetMaxY(innerRect))))
        
        return CGSizeMake(CGFloat((nudgeLeft != Float(0)) ? nudgeLeft : nudgeRight),
            CGFloat((nudgeTop != Float(0)) ? nudgeTop : nudgeBottom))
    }
    
    func searchAction(keywords: String) {
        if _currentLocation == nil || _search == nil {
            println("search failed")
            return
        }
        
        var request: AMapPlaceSearchRequest = AMapPlaceSearchRequest()
        request.searchType = AMapSearchType.PlaceKeyword
        
        request.keywords = keywords
        request.city = ["shanghai"]
        request.requireExtension = true
        request.offset = 1
        
        _search!.AMapPlaceSearch(request)
    }
    
    func locateAction() {
        if _mapView!.userTrackingMode != MAUserTrackingModeFollow {
            _mapView!.setUserTrackingMode(MAUserTrackingModeFollow, animated: true)
            _mapView!.setZoomLevel(CGFloat(kDefaultLocationZoomLevel), animated: true)
        }
    }
    
    func reGeoAction() {
        if _currentLocation != nil {
            var request = AMapReGeocodeSearchRequest()
            request.location = AMapGeoPoint.locationWithLatitude(CGFloat(_currentLocation!.coordinate.latitude),
                longitude: CGFloat(_currentLocation!.coordinate.longitude))
            _search!.AMapReGoecodeSearch(request)
        }
    }
    
    func addAnnotation(poi: AMapPOI) {
        // 为 poi 点添加标注
        var annotation: MAPointAnnotation = MAPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(Double(poi.location.latitude),
        Double(poi.location.longitude))
        annotation.title = poi.name
        annotation.subtitle = poi.address
        
        _mapView!.addAnnotation(annotation)
        
        _annotations!.addObject(annotation)
    }
    
    func setDestinationPoint(coor: CLLocationCoordinate2D) {
        if _destinationPoint != nil {
            _mapView!.removeAnnotation(_destinationPoint)
            _destinationPoint = nil
            
            if _pathPolylines != nil {
                _mapView!.removeOverlays(_pathPolylines! as [AnyObject])
                _pathPolylines = nil
            }
        }
        
        _destinationPoint = MAPointAnnotation()
        _destinationPoint!.coordinate = coor
        
        if !_isStatiumViewShowing {
            self.hideKeyboard()
            self.showStatiumView()
        }
    }
    
    func pathAction() {
        if _destinationPoint == nil || _currentLocation == nil || _search == nil {
            println("path search failed")
            return
        }
        
        var request = AMapNavigationSearchRequest()
        
        // 设置为步行路径规划
        request.searchType = AMapSearchType.NaviWalking
        
        request.origin = AMapGeoPoint.locationWithLatitude(CGFloat(_currentLocation!.coordinate.latitude),
            longitude: CGFloat(_currentLocation!.coordinate.longitude))
        request.destination = AMapGeoPoint.locationWithLatitude(CGFloat(_destinationPoint!.coordinate.latitude),
            longitude: CGFloat(_destinationPoint!.coordinate.longitude))
        
        _search!.AMapNavigationSearch(request)
    }
    
    func polylinesForPath(path: AMapPath?) -> NSArray? {
        if path == nil || path?.steps.count == 0 {
            return nil
        }
        
        var polylines: NSMutableArray = NSMutableArray()
        
        (path!.steps as NSArray).enumerateObjectsUsingBlock ({ step, idx, stop in
            
            var count: UInt = 0
            var s = step as? AMapStep
            if s == nil {
                return
            }

            var coordinates = Handler.coordinatesForString(s!.polyline, coordinateCount: &count, parseToken: ";")
            
            var polyline = MAPolyline(coordinates: coordinates, count: count) as MAPolyline
            polylines.addObject(polyline)
            
            free(coordinates)
        })
        
        return polylines
    }
    
    // MARK: - AMapSearchDelegate
    
    func onInputTipsSearchDone(request: AMapInputTipsSearchRequest!, response: AMapInputTipsSearchResponse!) {
        if response.tips == nil {
            return
        }
        _tips = []
        // 处理搜索结果
        for tip in response.tips {
            _tips!.append(tip as! AMapTip)
        }
        _tableView!.reloadData()
    }
    
    func searchRequest(request: AnyObject!, didFailWithError error: NSError!) {
        println("request :\(request), error :\(error)")
    }
    
    // 逆地理编码查询回调
    func onReGeocodeSearchDone(request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        println("response :\(response)")
        
        if response.regeocode != nil {
            var title = response.regeocode.addressComponent.city as NSString
            if title.length == 0 {
                title = response.regeocode.addressComponent.province as NSString
            }
            
            _mapView!.userLocation.title = title as String
            _mapView!.userLocation.subtitle = response.regeocode.formattedAddress
        }
    }
    
    func onPlaceSearchDone(request: AMapPlaceSearchRequest!, response: AMapPlaceSearchResponse!) {
        println("request :\(request)")
        println("response :\(response)")
        
        //清空标注
        _mapView!.removeAnnotations(NSArray(array: _annotations!) as [AnyObject])
        _annotations!.removeAllObjects()

        if response.pois == nil {
            return
        }
        
        if response.pois.count > 0 {
            _pois = response.pois as? [AMapPOI]
            
            for var i = 0; i < _pois!.count; i++ {
                
                let poi = _pois![i]
                self.addAnnotation(poi)
                
                if i == 0 {
                    let coor = CLLocationCoordinate2DMake(Double(poi.location.latitude),
                        Double(poi.location.longitude))
                    _mapView!.centerCoordinate = coor
                    
                    self.statiumName = poi.name
                    self.setDestinationPoint(coor)
                    self.showStatiumView()
                }
            }
            _mapView!.showAnnotations((_annotations! as [AnyObject]), animated: true)
            _mapView!.setZoomLevel(CGFloat(kDefaultLocationZoomLevel), animated: true)
        }
    }
    
    func onNavigationSearchDone(request: AMapNavigationSearchRequest!, response: AMapNavigationSearchResponse!) {
        println("request :\(request)")
        println("response :\(response)")
        
        if response.count > 0 {
            if _pathPolylines != nil {
                _mapView!.removeOverlays(_pathPolylines! as [AnyObject])
                _pathPolylines = nil
            }
            
            // 只显示第一条
            _pathPolylines = self.polylinesForPath(response.route.paths[0] as? AMapPath)
            _mapView!.addOverlays(_pathPolylines! as [AnyObject])
            
            _mapView!.showAnnotations([_destinationPoint!, _mapView!.userLocation], animated: true)
        }
    }
    
    // MARK: - MAMapViewDelegate
    
    func mapView(mapView: MAMapView!, viewForOverlay overlay: MAOverlay!) -> MAOverlayView! {
        if overlay.isKindOfClass(MAPolyline.self) {
            var polylineView = MAPolylineView(polyline: overlay as! MAPolyline)
            
            polylineView.lineWidth = 5
            polylineView.strokeColor = UIColor.magentaColor()
            
            return polylineView
        }
        return nil
    }
    
    func mapView(mapView: MAMapView!, viewForAnnotation annotation: MAAnnotation!) -> MAAnnotationView! {
        if annotation.isKindOfClass(MAPointAnnotation.self) {
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(annotationIndetifier) as? CustomAnnotationView
            if annotationView == nil {
                annotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: annotationIndetifier)
            }
            annotationView!.image = UIImage(named: "flag")
            annotationView!.canShowCallout = false
            annotationView!.centerOffset = CGPointMake(0, -18)
            annotationView!.delegate = self
            return annotationView
        }
        return nil
    }
    
    func mapView(mapView: MAMapView!, didChangeUserTrackingMode mode: MAUserTrackingMode, animated: Bool) {
        // 修改定位按钮状态
        if mode == MAUserTrackingModeNone {
            _locationButton?.setImage(UIImage(named: "location_no"), forState: UIControlState.Normal)
        } else {
            _locationButton?.setImage(UIImage(named: "location_yes"), forState: UIControlState.Normal)
        }
    }
    
    func mapView(mapView: MAMapView!, didUpdateUserLocation userLocation: MAUserLocation!, updatingLocation: Bool) {
        if userLocation.location != nil {
            _currentLocation = userLocation.location.copy() as? CLLocation
        }
    }
    
    func mapView(mapView: MAMapView!, didSelectAnnotationView view: MAAnnotationView!) {
        // 选中定位 annotation 的时候进行逆地理编码查询
        if view.annotation.isKindOfClass(MAUserLocation.self) {
            self.reGeoAction()
        }
        
        // 调整自定义 callout 的位置, 使其可以完全显示
        if view.isKindOfClass(CustomAnnotationView.self) {
            var cusView = view as! CustomAnnotationView
            var frame = cusView.convertRect(cusView.calloutView!.frame, toView: _mapView!)
            
            // 给弹出框添加 edgeInset 边界
            frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(kDefaultCalloutViewMargin, kDefaultCalloutViewMargin, kDefaultCalloutViewMargin, kDefaultCalloutViewMargin))
            
            // 计算弹出框相对 mapView 的偏移量, 用于调整视图
            if !CGRectContainsRect(_mapView!.frame, frame) {
                var offset = self.offsetToContainsRect(frame, inRect: _mapView!.frame)
                
                var theCenter = _mapView!.center
                theCenter = CGPointMake(theCenter.x - offset.width, theCenter.y - offset.height)
                
                var coordinate = _mapView!.convertPoint(theCenter, toCoordinateFromView: _mapView!)
                
                _mapView!.setCenterCoordinate(coordinate, animated: true)
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellIdentifier)
        }
        
        var tip: AMapTip = _tips![indexPath.row]
        
        cell!.textLabel!.text = tip.name
        cell!.detailTextLabel!.text = tip.district
        
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _tips!.count
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var tip: AMapTip = _tips![indexPath.row]
        
        _searchTextField!.text = tip.name
        
        self.searchAction(tip.name)
        self.hideKeyboard()
        self.hideSearchResult()
    }
    
    // MARK: - CustomStatiumInfoView
    
    func initStatiumInfoView() {
        var statiumView = UIView()
        statiumView.frame = CGRectMake(kDefaultControlMargin, CGRectGetHeight(self.view.bounds), CGRectGetWidth(_searchTextField!.frame), 110)
        statiumView.backgroundColor = UIColor.whiteColor()
        statiumView.layer.shadowColor = UIColor.grayColor().CGColor
        statiumView.layer.shadowOpacity = 1.0
        statiumView.layer.shadowOffset = CGSizeMake(1.0, 1.0)
        _mapView!.addSubview(statiumView)
        
        _cancleButton = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        _cancleButton!.frame = CGRectMake(0, 0, kDefaultZoomSize, kDefaultZoomSize)
        _cancleButton!.backgroundColor = UIColor.clearColor()
        _cancleButton!.tintColor = UIColor.darkGrayColor()
        _cancleButton!.setImage(UIImage(named: "cancle"), forState: .Normal)
        _cancleButton!.addTarget(self, action: "cancleAction", forControlEvents: .TouchUpInside)
        _cancleButton!.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin |
            UIViewAutoresizing.FlexibleBottomMargin
        statiumView.addSubview(_cancleButton!)
        
        _confirmButton = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        _confirmButton!.frame = CGRectMake(CGRectGetWidth(statiumView.frame) - kDefaultZoomSize * 2,
            0, kDefaultZoomSize * 2, kDefaultZoomSize)
        _confirmButton!.setTitle("查看路线", forState: .Normal)
        _confirmButton!.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        _confirmButton!.addTarget(self, action: "confirmAction", forControlEvents: .TouchUpInside)
        _confirmButton!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin |
            UIViewAutoresizing.FlexibleBottomMargin
        _confirmButton!.setBackgroundImage(UIButton.imageWithColor(UIColor.whiteColor()),
            forState: .Normal)
        _confirmButton!.setBackgroundImage(UIButton.imageWithColor(UIColor(red: 135/255,
            green: 206/255, blue: 250/255, alpha: 0.5)), forState: .Highlighted)
        _confirmButton!.layer.cornerRadius = 5
        _confirmButton!.clipsToBounds = true
        statiumView.addSubview(_confirmButton!)
        
        var seperateline = UIView()
        seperateline.frame = CGRectMake(0, 50, CGRectGetWidth(statiumView.frame), 0.5)
        seperateline.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.8)
        statiumView.addSubview(seperateline)
        
        _statiumLabel = UILabel()
        _statiumLabel!.frame = CGRectMake(kDefaultMargin, CGRectGetMaxY(seperateline.frame) + 5, CGRectGetWidth(seperateline.frame) - 2 *  kDefaultMargin, 50)
        _statiumLabel!.numberOfLines = 2
        _statiumLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping
        _statiumLabel!.textColor = UIColor.darkGrayColor()
        _statiumLabel!.font = UIFont.systemFontOfSize(16)
        _statiumLabel!.text = self._statiumName
        statiumView.addSubview(_statiumLabel!)
        
        _statiumView = statiumView
    }
    
    func cancleAction() {
        self.hideStatiumView()
    }
    
    func confirmAction() {
        self.pathAction()
    }
    
    func showStatiumView() {
        UIView.animateWithDuration(0.2,
            animations: { () -> Void in
                self._statiumView!.frame = CGRectMake(kDefaultControlMargin, CGRectGetHeight(self.view.bounds) - 120, CGRectGetWidth(self._searchTextField!.frame), 110)
            }) { (completed: Bool) -> Void in
                if completed {
                    self._isStatiumViewShowing = true
                }
        }
    }
    
    func hideStatiumView() {
        UIView.animateWithDuration(0.2,
            animations: { () -> Void in
                self._statiumView!.frame = CGRectMake(kDefaultControlMargin, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self._searchTextField!.frame), 110)
            }) { (completed: Bool) -> Void in
                if completed {
                    self._isStatiumViewShowing = false
                }
        }
    }
}

