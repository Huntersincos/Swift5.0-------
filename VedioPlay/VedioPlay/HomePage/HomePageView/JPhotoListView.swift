//
//  JPhotoListView.swift
//  VedioPlay
//
//  Created by wenze on 2020/6/16.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
import AssetsLibrary

@objc protocol JPhotoListViewDelegate{
    //点击选中
    func photoPicker(_ picker:JPhotoListView?, didSelectAsset asset:ALAsset?)
    //取消选中
    func photoPicker(_ picker:JPhotoListView?, didDeselectAsset asset:ALAsset?)
    //超过最大选择项时
    func photoPickerDidMaximum(_ picker:JPhotoListView?)
    //低于最低选择项时
    func photoPickerDidMinimum(_ picker:JPhotoListView?)
    //选择过滤
    func photoPickerDidSelectionFilter(_ picker:JPhotoListView?);
    //选择了多类型的文件
    func photoPicker(_ picker:JPhotoListView?, didSelectUnexpectedAsset asset:ALAsset?)
    
    func presentDetailView()
    
}

class JPhotoListView: UIView,UICollectionViewDataSource,UICollectionViewDelegate {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var collectionView:UICollectionView?
    let cellIdentiferID = "AJPhotoListCollectionViewCell"
    weak var  delegate:JPhotoListViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        let layout = UICollectionViewFlowLayout.init()
        // 滚动方向相同的间距
        layout.minimumLineSpacing = 5
        // 滚动方向垂直的间距
        layout.minimumInteritemSpacing = 5
        layout.itemSize =  CGSize(width: (self.frame.size.width - 25)/4,height: (self.frame.size.height - 25)/4)
        collectionView = UICollectionView.init(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height), collectionViewLayout: layout)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.register(AJPhotoListCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentiferID)
        self.addSubview(collectionView!)
        
        //Fatal error: init(coder:) has not been implemented: file
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let layout = UICollectionViewFlowLayout.init()
        // 滚动方向相同的间距
       layout.minimumLineSpacing = 5
       // 滚动方向垂直的间距
       layout.minimumInteritemSpacing = 5
       layout.itemSize =  CGSize(width: (self.frame.size.width - 25)/4,height: (self.frame.size.height - 25)/4)
       collectionView = UICollectionView.init(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height), collectionViewLayout: layout)
       collectionView?.backgroundColor = .white
       collectionView?.delegate = self
       collectionView?.dataSource = self
       collectionView?.register(AJPhotoListCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentiferID)
       self.addSubview(collectionView!)
        
    }
   
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return JPhotoManger.shared.assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:AJPhotoListCollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentiferID, for: indexPath) as? AJPhotoListCollectionViewCell
        
        let result:ALAsset? = JPhotoManger.shared.assets.object(at: indexPath.row) as? ALAsset
        let frist:ALAsset? = JPhotoManger.shared.indexPathsForSelectedItems?.firstObject as? ALAsset
        let first_forProper:String? = frist?.value(forProperty: ALAssetPropertyType) as? String
        let result_forProper:String? = result?.value(forProperty:ALAssetPropertyType ) as? String
        if first_forProper != nil && first_forProper != nil{
            if JPhotoManger.shared.indexPathsForSelectedItems.count > 0 && first_forProper != result_forProper{
                JPhotoManger.shared.selectionFilter = NSPredicate.init(block: { (evaluatedObject:Any, _: [String : Any]?) -> Bool in
                   // Any包括 struct，enum，func）。
                   // AnyObject 只适用于 class 类型
                       return false
                   })
               }else{
                JPhotoManger.shared.selectionFilter = NSPredicate.init(block: { (evaluatedObject:Any, _: [String : Any]?) -> Bool in
                       return true
                   })
               }
        }
//        if JPhotoManger.shared.indexPathsForSelectedItems.count > 0 && first_forProper != result_forProper{
//           JPhotoManger.shared.selectionFilter = NSPredicate.init(block: { (evaluatedObject:Any, [String : Any]?) -> Bool in
//            // Any包括 struct，enum，func）。
//            // AnyObject 只适用于 class 类型
//                return false
//            })
//        }else{
//            JPhotoManger.shared.selectionFilter = NSPredicate.init(block: { (evaluatedObject:Any, [String : Any]?) -> Bool in
//                return true
//            })
//        }
        var isSelected:Bool  = false
        if result != nil && JPhotoManger.shared.indexPathsForSelectedItems != nil {
        // ! 注意为空的情况
           isSelected  = JPhotoManger.shared.indexPathsForSelectedItems.contains(result!)
        }
        cell?.bind(JPhotoManger.shared.assets[indexPath.row] as? ALAsset, JPhotoManger.shared.selectionFilter, isSelected: isSelected)
        
        return cell!
        
        
    }
    
//    func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
//
//    }
    
    
    // 设置上下左右间距 swift 5.0似乎没有这个方法了
   func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
      
       return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
   }
//
//    - (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//        CGFloat wh = (collectionView.bounds.size.width - 25)/4.0;
//        return CGSizeMake(wh, wh);
//    }
    // 每个cell的高度
    func collectionView(collectionView: UICollectionView,layout collectionViewLayout :UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize {
        let wh = collectionView.bounds.size.width - 25
        return CGSize(width: wh, height: wh)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell:AJPhotoListCollectionViewCell?  = self.collectionView?.cellForItem(at: indexPath) as? AJPhotoListCollectionViewCell
        let  asset:ALAsset?  = JPhotoManger.shared.assets[indexPath.row] as?ALAsset
       //超出最大限制
       
        if JPhotoManger.shared.indexPathsForSelectedItems.count >= JPhotoManger.shared.maximumNumberOfSelection && JPhotoManger.shared.indexPathsForSelectedItems.contains(asset!) == false {
            delegate?.photoPickerDidMaximum(self)
            return
        }
        
        // 取消选择
        if JPhotoManger.shared.indexPathsForSelectedItems.contains(asset!){
            JPhotoManger.shared.indexPathsForSelectedItems .remove(asset!)
            cell?.is_Selected(false)
            delegate?.photoPicker(self, didDeselectAsset: asset!)
            if JPhotoManger.shared.indexPathsForSelectedItems.count == 0 {
                self.collectionView?.reloadData()
            }
            return
        }
        
        // 过滤器
        let selectable:Bool? = JPhotoManger.shared.selectionFilter.evaluate(with: asset)
        if selectable == false {
            delegate?.photoPickerDidSelectionFilter(self)
            return
        }
        
        // 选中
        let result:ALAsset? = JPhotoManger.shared.indexPathsForSelectedItems?.firstObject as? ALAsset
        let first_forProper:String? = asset?.value(forProperty: ALAssetPropertyType) as? String
        let result_forProper:String? = result?.value(forProperty:ALAssetPropertyType ) as? String
        if JPhotoManger.shared.indexPathsForSelectedItems.count == 0 || first_forProper == result_forProper  {
            JPhotoManger.shared.indexPathsForSelectedItems.add(asset!)
            cell?.is_Selected(true)
            let first:ALAsset? = JPhotoManger.shared.indexPathsForSelectedItems?.firstObject as? ALAsset
            let indexPathFirst :String? = first?.value(forProperty: ALAssetPropertyType) as? String
            if indexPathFirst == ALAssetTypePhoto{
                JPhotoManger.shared.maximumNumberOfSelection = 9
            }else{
                JPhotoManger.shared.maximumNumberOfSelection = 1
            }
            delegate?.photoPicker(self, didSelectAsset: asset)
            if JPhotoManger.shared.indexPathsForSelectedItems.count == 1{
                self.collectionView?.reloadData()
            }
        }else{
            delegate?.photoPicker(self, didSelectUnexpectedAsset: asset)
            
        }
        
        
    }
    
    func detail() {
        delegate?.presentDetailView()
    }
    
    func reloadCollectionView() {
        self.collectionView?.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
//    required init?(coder: NSCoder) {
//         //Fatal error: init(coder:) has not been implemented: file
//        super.init(coder:coder)
//        fatalError("init(coder:) has not been implemented")
//    }
    
}
