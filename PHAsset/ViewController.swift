//
//  ViewController.swift
//  PHAsset
//
//  Created by DayHR on 2019/4/28.
//  Copyright © 2019年 zhcx. All rights reserved.
//

import UIKit
import Photos

let ScreenWidth     = UIScreen.main.bounds.width //屏幕宽度
let ScreenHeight    = UIScreen.main.bounds.height //屏幕高度
let scale375        = ScreenWidth / 375.0//由于是横屏

class ViewController: UIViewController {

    private var phAssetArray = [PHAsset]()
    
    
    private var myCollectionView: UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadCollectionView()
        
        self.authorizedGetPHAssts()
        
        
     
    }

    //授权
    private func authorizedGetPHAssts(){
        //notDetermined 未弹框
        //denied 拒绝授权
        //authorized 授权的
        //restricted 限制
        let status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (sts) in
                if sts == .authorized{//点的同意
                    DispatchQueue.main.async {
                        self.getAllPHAsset()
                    }
                }else{
                    print("我是拒绝的")
                }
            }
        case .authorized:
            self.getAllPHAsset()
        case .denied:
            print("并没有授权,请前往设置打开相册功能")
        case .restricted:
            print("访问相册失败")
        }
    }
    
    //获取所有资源
    private func getAllPHAsset(){
        
        var phAssetArray = [PHAsset]()
        let assets = PHAsset.fetchAssets(with: .image, options: PHFetchOptions())
        assets.enumerateObjects { (asset, index, stop) in
            phAssetArray.append(asset)
        }
        self.phAssetArray = phAssetArray
        
    
        self.myCollectionView?.reloadData()
        
    }

   
    
    private func loadCollectionView(){
        
        let space: CGFloat = 2//间距
        let lineCount: CGFloat = 5//每行
        let leftSpace: CGFloat = 0
        
        let CellWidth = (self.view.width - (lineCount - 1) * space - leftSpace * 2) / lineCount
        
        //---UICollectionView---
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: CellWidth, height: CellWidth)
        layout.minimumLineSpacing = space //上下之间的间隔
        layout.minimumInteritemSpacing = 0 //左右之间间隔
        layout.headerReferenceSize = CGSize(width: 0, height: 0) //头部间距
        layout.footerReferenceSize = CGSize(width: 0, height: 0) //尾部间距
        layout.sectionInset.left = leftSpace//开始的距离
        layout.sectionInset.right = leftSpace//结束的距离
        
        let rect = CGRect(x: 0, y: 0, width: self.view.width, height: self.view.height)
        myCollectionView = UICollectionView(frame: rect, collectionViewLayout: layout)
        myCollectionView?.backgroundColor = UIColor.white
        myCollectionView?.delegate = self
        myCollectionView?.dataSource = self
        myCollectionView?.isPagingEnabled = false
        myCollectionView?.showsVerticalScrollIndicator = true
        myCollectionView?.showsHorizontalScrollIndicator = false
        myCollectionView?.alwaysBounceVertical = true
        self.view.addSubview(myCollectionView!)
        
        myCollectionView?.register(myCollectionCell.self, forCellWithReuseIdentifier: "myCollectionCell")
        
    }
    
}


extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.phAssetArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCollectionCell", for: indexPath) as! myCollectionCell
        cell.data = self.phAssetArray[indexPath.row]
 
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    
    
    
    
}

class myCollectionCell: UICollectionViewCell{
    
   
    public var data: PHAsset!{
        didSet{
            if data == nil{
                return
            }
            let size = CGSize(width: self.frame.width * 2, height: self.frame.height * 2)
            
            PHCachingImageManager().requestImage(for: data, targetSize: size, contentMode: .aspectFill, options: nil) { (image, info) in
                self.imageView?.image = image
            }
        }
    }
    
    
    public var imageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.width, height: self.height))
        imageView?.contentMode = .scaleAspectFill
        imageView?.layer.masksToBounds = true
        self.addSubview(imageView!)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
