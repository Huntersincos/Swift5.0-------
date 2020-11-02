//
//  DisplayLocationViewController.swift
//  VedioPlay
//
//  Created by wenze on 2020/7/31.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

enum ErrorTest:Error {
//    定义异常问问题
    case nameVisiableError
    case ageError
    case heightError
    case nameLengthError
}


@objc protocol DisplayLocationViewControllerDelegate{
    func didFinishLocationCompled(_ latitude:Double, _ longitude:Double,_ radius:Double, geoLocation:String)
}


class DisplayLocationViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate{

    @IBOutlet weak var myMapView: MKMapView!
    
    @IBOutlet weak var loactionAddreesLable: UILabel!
    
    @IBOutlet weak var loacitonBackButton: UIButton!
    
    @IBOutlet weak var pinLocationImageView: UIImageView!
     
    var locationManager:CLLocationManager!
    let identifier:String = "identifier"
    
    var isFirstUserLocation:Bool!
    var isFinishGeocodeLocation:Bool!
    var _myRegionAnnotation:QWAnnotation!
    weak var delegate:DisplayLocationViewControllerDelegate?
    
    /// 模式地址
    var address:String?

    ///纬度
    var latitude:Double?
    
    /// 经度
    var longitude:Double?

    /// 半径
    var radius:Float?
    
    /// 是否显示位置
    var isShowMessageLocation:Bool?
    
    
    
    func addAnnotationWithCoordinate(_ coordinate:CLLocationCoordinate2D ,_ locationString:String)  {
    
        let newRegion:CLCircularRegion? = CLCircularRegion.init(center: coordinate, radius: 10.0, identifier: "\(coordinate.latitude), \(coordinate.longitude)")
        let myRegionAnnotation:QWAnnotation? = QWAnnotation.init(newRegion ?? CLCircularRegion.init(), "位置", locationString)
        myRegionAnnotation?.coordinate =  newRegion?.center ?? CLLocationCoordinate2DMake(0, 0)
        myRegionAnnotation?.radius  =  newRegion?.radius
        myMapView.addAnnotation(myRegionAnnotation ?? QWAnnotation.init())
        _myRegionAnnotation = myRegionAnnotation ?? QWAnnotation.init()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        self.title = "位置"
        let backBtn = UIButton.init(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        backBtn.setImage(UIImage.init(named: "backBtn.png"), for: .normal)
        backBtn.imageEdgeInsets = UIEdgeInsets.init(top: 11.5, left: 4, bottom: 11.5, right: 28)
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: backBtn)
        backBtn .addTarget(self, action: #selector(backClick), for: .touchUpInside)
        
        locationManager = CLLocationManager.init()
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        loactionAddreesLable.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        loactionAddreesLable.textColor = UIColor.darkGray
        loactionAddreesLable.font = UIFont.systemFont(ofSize: 14)
        
        myMapView.delegate = self
        myMapView.showsUserLocation = true
        
        if self.address != nil && self.latitude != nil  && self.longitude != nil {
            
            let coordinate:CLLocationCoordinate2D? = CLLocationCoordinate2DMake(self.latitude ?? 0.00, self.longitude ?? 0.00)
            addAnnotationWithCoordinate(coordinate ?? CLLocationCoordinate2DMake(0, 0), self.address ?? "")
            //标注范围的机构体
            let regionMap:MKCoordinateRegion = MKCoordinateRegion.init(center: coordinate ?? CLLocationCoordinate2DMake(0, 0), latitudinalMeters: 500, longitudinalMeters: 500)
            myMapView.setRegion(regionMap, animated: false)
            self.loactionAddreesLable.text = self.address
            self.pinLocationImageView.isHidden =  true
            
        }else{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "发送", style: .plain, target: self, action: #selector(sendLocation))
            self.loactionAddreesLable.text = "加载中..."
            
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.isShowMessageLocation == false{
            self.myMapView.setCenter(self.myMapView.userLocation.coordinate, animated: true)
        }
        
    }
    
    func reverseGeocodeLocation() {
        let centerLatitude = self.myMapView.centerCoordinate.latitude
        let centerLongitude = self.myMapView.centerCoordinate.longitude
        // 地理信息编码 CLGeocoder
        let geocoder = CLGeocoder.init()
        let location = CLLocation.init(latitude: centerLatitude, longitude: centerLongitude)
        if(_myRegionAnnotation != nil){
            self.myMapView.removeAnnotation(_myRegionAnnotation)
        }
        geocoder.reverseGeocodeLocation(location) { (placemarks:[CLPlacemark]?, error:Error?) in
            if placemarks?.count != 0{
                let placemark:CLPlacemark = placemarks?[(placemarks?.count ?? 1) - 1] ?? CLPlacemark.init()
                let geoLocations:NSMutableString? = NSMutableString.init()
                // CLPlacemark:地标信息编码
                if placemark.locality?.count != 0 {
                    geoLocations?.append(placemark.locality ?? "")
                }
                
                if  placemark.subLocality?.count != 0 {
                    geoLocations?.append(placemark.subLocality ?? "")
                }
                
                if placemark.thoroughfare?.count != 0{
                    geoLocations?.append(placemark.thoroughfare ?? "")
                }
                
                if placemark.subThoroughfare?.count != 0{
                    geoLocations?.append(placemark.subThoroughfare ?? "")
                }
                self.loactionAddreesLable.text = geoLocations as String?
                self.longitude = centerLongitude
                self.latitude = centerLatitude
                self.radius =  10.0
                self.address = geoLocations as String?
            }
            
            self.isFirstUserLocation = true
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    
    @IBAction func backToMyPlaceBtn(_ sender: Any) {
        // 地图偏移中心
        myMapView.setCenter(self.myMapView.userLocation.coordinate, animated: true)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        do {
            let userLocation = try locations[0]
            if self.isFirstUserLocation == nil && self.isShowMessageLocation == nil && userLocation.coordinate.longitude > 0{
                let region:MKCoordinateRegion = MKCoordinateRegion.init(center: userLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                /// myMapView.setRegion(region, animated: true) 经纬度不对了 ?????
                myMapView.setRegion(region, animated: false)
                self.isFirstUserLocation = true
                reverseGeocodeLocation()
            }
        } catch{
           switch error {
           case ErrorTest.ageError:print("1"); break
           case ErrorTest.nameLengthError:print("2"); break
           case ErrorTest.nameVisiableError:print("3"); break
           case ErrorTest.heightError:print("4"); break
           default:break
         }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        if self.isShowMessageLocation == nil && self.isFirstUserLocation == nil && userLocation.coordinate.longitude > 0 {
            
            let region:MKCoordinateRegion = MKCoordinateRegion.init(center: userLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            myMapView.setRegion(region, animated: false)
            self.isFirstUserLocation = true
            reverseGeocodeLocation()
            
        }
    }
    
    
    /// 地图区域将要改变
    /// - Parameters:
    ///   - mapView: <#mapView description#>
    ///   - animated: <#animated description#>
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if self.isShowMessageLocation == false{
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.loactionAddreesLable.text = "加载中...."
        }
    }
    
    
    
    /// 区域已经改变
    /// - Parameters:
    ///   - mapView: <#mapView description#>
    ///   - animated: <#animated description#>
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if (isFinishGeocodeLocation == false){
           return
        }
        
        if isShowMessageLocation == false{
            reverseGeocodeLocation()
            
            UIView.animate(withDuration: 0.5, animations: {
                
               self.pinLocationImageView.center = CGPoint(x: self.pinLocationImageView.center.x, y: self.pinLocationImageView.center.y)
                
                
            }) { (finshed:Bool) in
                UIView.animate(withDuration: 0.5) {
                    self.pinLocationImageView.center = CGPoint(x: self.pinLocationImageView.center.x, y: self.pinLocationImageView.center.y + 20)
                }
            }
            
        }
        
    }
    
    
    
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        
    }
    
    
    
    
    /// 添加大头症
    /// - Parameters:
    ///   - mapView: <#mapView description#>
    ///   - annotation: <#annotation description#>
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation .isKind(of: QWAnnotation.self){
            var pinView:MKAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if pinView == nil{
                pinView = MKAnnotationView.init(annotation: annotation, reuseIdentifier: identifier)
                pinView?.image = UIImage.init(named: "msg-location-place")
                
            }
            return pinView
            
        }
        
        return nil
    }
    
    
    @objc func backClick()
    {
        navigationController?.popViewController(animated: true)
        
    }
    
    @objc func sendLocation(){
        navigationController?.popViewController(animated: true)
        self.delegate?.didFinishLocationCompled(self.latitude ?? 0.0, self.longitude ?? 0.0, 10.0, geoLocation: self.address ?? "")
        
    }
    
    deinit {
        self.myMapView = nil
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
