//
//  MyExtension.swift
//  PHAsset
//
//  Created by DayHR on 2019/4/28.
//  Copyright © 2019年 zhcx. All rights reserved.
//

import UIKit
import Photos

extension UIView{
    
    //获取视图的控制器
    public var viewController: UIViewController?{
        var next: UIResponder?
        next = self.next
        repeat{
            if (next as? UIViewController) != nil{
                return (next as? UIViewController)
            }else{
                next = next?.next
            }
        }while next != nil
        return (next as? UIViewController)
    }
    
    //位置
    public var height: CGFloat{
        get{
            return self.frame.size.height
        }
        set{
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: newValue)
        }
    }
    public var width: CGFloat{
        get{
            return self.frame.size.width
        }
        set{
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: newValue, height: self.frame.height)
        }
    }
    
    public var top: CGFloat{
        get{
            return self.frame.origin.y
        }
        set{
            self.frame = CGRect(x: self.frame.origin.x, y: newValue, width: self.frame.width, height: self.frame.height)
        }
        
    }
    public var bottom: CGFloat{
        get{
            return self.frame.origin.y + self.frame.height
        }
        set{
            let y = newValue - self.frame.height
            self.frame = CGRect(x: self.frame.origin.x, y: y, width: self.frame.width, height: self.frame.height)
        }
        
    }
    public var left: CGFloat{
        get{
            return self.frame.origin.x
        }
        set{
            self.frame = CGRect(x: newValue, y: self.frame.origin.y, width: self.frame.width, height: self.frame.height)
        }
        
    }
    public var right: CGFloat{
        get{
            return self.frame.origin.x + self.frame.width
        }
        set{
            let x = newValue - self.frame.width
            self.frame = CGRect(x: x, y: self.frame.origin.y, width: self.frame.width, height: self.frame.height)
        }
    }
}

extension PHAsset {
    
    //根据PHAsset获取原图片信息
    public func getImage(handler: ((Data)->Swift.Void)?){
        
        switch self.mediaType {
        case .video:
            print("视频")
        case .image:
            //print("图片")
            var requestID: PHImageRequestID = -2
            if requestID >= 1{
                PHCachingImageManager.default().cancelImageRequest(requestID)
            }
            let opt = PHImageRequestOptions()
            opt.deliveryMode = .opportunistic
            opt.resizeMode = .fast
            
            requestID = PHCachingImageManager.default().requestImageData(for: self, options: opt, resultHandler: { (data, str, orientation, dic) in
                if let d = data{
//                    print("原始大小:\(d.count)")
                    handler?(d)
                }
            })
            
            
//            PHImageManager.default().requestImageData(for: self, options: opt) { (dd, str, orientation, dic) in
//                if let d = dd{
//
//                    DispatchQueue.global().async {
//                        let img = UIImage.init(data: d, scale: 0.01)
//                        if let myD = img?.jpegData(compressionQuality: 0.2){
//                            DispatchQueue.main.async {
//                                let mmmg = UIImage(data: myD)
//                                self.imageView?.image = mmmg
//                            }
//                        }
//                    }
//                }
//            }
        default:
            print("不是我想要的")
        }
    }
    
    
}

typealias MBProgressHud = MBProgressHUD

extension MBProgressHud{
    class func showError(_ message: String, to view: UIView?, delay: TimeInterval = 1){
        guard let v = view else {
            return
        }
        let mb = MBProgressHUD.showAdded(to: v, animated: true)
        mb.label.text = message
        mb.mode = .text
//        mb.margin = 22 * scale375
//        mb.label.font = UIFont.boldAuto(font: 16)
        mb.removeFromSuperViewOnHide = true
        mb.hide(animated: true, afterDelay: delay)
    }
    class func showState(_ message: String, to view: UIView?){
        guard let v = view else {
            return
        }
        let mb = MBProgressHUD.showAdded(to: v, animated: true)
//        mb.margin = 22 * scale375
//        mb.label.font = UIFont.boldAuto(font: 16)
        mb.label.text = message
    }
    class func hidden(to view: UIView?){
        guard let v = view else {
            return
        }
        MBProgressHUD.hide(for: v, animated: true)
        MBProgressHud.hideAllHUDs(for: v, animated: false)
    }
}


extension UIImage{
    //图片尺寸的压缩
    func resizeImage() -> UIImage{
        let contrastWidth: CGFloat = 1280
        let width = self.size.width
        let height = self.size.height
        let scale = width / height
        var sizeChange = CGSize()
        if width <= contrastWidth && height < contrastWidth{
            //a，图片宽或者高均小于或等于1280时图片尺寸保持不变，不改变图片大小
            return self
        }else if width > contrastWidth || height > contrastWidth{
            //b,宽或者高大于1280，但是图片宽度高度比小于或等于2，则将图片宽或者高取大的等比压缩至1280
            if scale <= 2 && scale >= 1{
                let changeWidth: CGFloat = contrastWidth
                let changeHeight: CGFloat = changeWidth / scale
                sizeChange = CGSize(width: changeWidth, height: changeHeight)
            }else if scale >= 0.5 && scale <= 1{
                let changeHeight = contrastWidth
                let changeWidth = changeHeight * scale
                sizeChange = CGSize(width: changeWidth, height: changeHeight)
            }else if width > contrastWidth && height > contrastWidth {
                //c,宽以及高均大于1280，但是图片宽高比大于2时，则宽或者高取小的等比压缩至1280
                if scale > 2{//高的值比较小
                    let changeHeight = contrastWidth
                    let changeWidth = changeHeight * scale
                    sizeChange = CGSize(width: changeWidth, height: changeHeight)
                }else{//宽的值比较小
                    let changeWidth = contrastWidth
                    let changeHeight = changeWidth / scale
                    sizeChange = CGSize(width: changeWidth, height: changeHeight)
                }
            }else{ //d, 宽或者高，只有一个大于1280，并且宽高比超过2，不改变图片大小
                return self
            }
        }
        UIGraphicsBeginImageContext(sizeChange)
        self.draw(in: CGRect(x: 0, y: 0, width: sizeChange.width, height: sizeChange.height))
        let resizedImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImg!
    }
    //图片大小压缩
    func compressData()->Data{
        let data = self.jpegData(compressionQuality: 1)!
        let kb = data.count / 1024
        var size: CGFloat = 0.1
        if kb > 1500{
            size = 0.3
        }else if kb > 600 {
            size = 0.4
        }else if kb > 400{
            size = 0.5
        }else if kb > 300{
            size = 0.6
        }else if kb > 200{
            size = 0.8
        }else{
            size = 1
        }
        let endData = self.jpegData(compressionQuality: size)!
        return endData
    }
}
