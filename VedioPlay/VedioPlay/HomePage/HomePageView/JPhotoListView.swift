//
//  JPhotoListView.swift
//  VedioPlay
//
//  Created by wenze on 2020/6/16.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
import AssetsLibrary

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
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return JPhotoManger.shared.assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentiferID, for: indexPath)
        let result:ALAsset? = JPhotoManger.shared.assets.object(at: indexPath.row) as? ALAsset
        let frist:ALAsset? = JPhotoManger.shared.indexPathsForSelectedItems?.firstObject as? ALAsset
        let first_forProper:String? = frist?.value(forProperty: ALAssetPropertyType) as? String
        let result_forProper:String? = result?.value(forProperty:ALAssetPropertyType ) as? String
        if JPhotoManger.shared.indexPathsForSelectedItems.count > 0 && first_forProper != result_forProper{
           JPhotoManger.shared.selectionFilter = NSPredicate.init(block: { (evaluatedObject:Any, [String : Any]?) -> Bool in
            // Any包括 struct，enum，func）。
            // AnyObject 只适用于 class 类型
                return false
            })
        }else{
            JPhotoManger.shared.selectionFilter = NSPredicate.init(block: { (evaluatedObject:Any, [String : Any]?) -> Bool in
                return true
            })
        }
        
        let isSelected:Bool  = JPhotoManger.shared.indexPathsForSelectedItems.contains(result!)
        
        return cell
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
