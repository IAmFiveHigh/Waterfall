//
//  ViewController.swift
//  Waterfall
//
//  Created by 我是五高你敢信 on 2017/3/6.
//  Copyright © 2017年 我是五高你敢信. All rights reserved.
//

import UIKit
import CHTCollectionViewWaterfallLayout
import SDWebImage

class ViewController: UIViewController {

    fileprivate var collectionView: UICollectionView!
    
    fileprivate var dataArray = [PictureModel]()
    
    fileprivate let picturesSource = "http://www.duitang.com/album/1733789/masn/p/0/50/"
    
    fileprivate let cellIdentifier = "WaterfallCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        loadData()
    }
    
    fileprivate func setupUI() {
        
        let layout = CHTCollectionViewWaterfallLayout()
        
        layout.columnCount = 3
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.minimumColumnSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(WaterCell.self, forCellWithReuseIdentifier: cellIdentifier)
        view.addSubview(collectionView)
        
}
    
    fileprivate func loadData() {

        DispatchQueue.global().async {
            
            //MD5加密
            let md5String = self.picturesSource.md5()
            let filePath = NSHomeDirectory() + "/Documents/" + md5String
            
            var data: Data
            
            //判断本地是否有保存数据
            let manager = FileManager.default
            if manager.fileExists(atPath: filePath) {
                //从本地文件调用data
                do {
                    
                    data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                    self.optionData(data: data)
                }catch {
                    
                    print(error)
                }
                
            }else {
                
                //从网络请求data
                guard let url = URL(string: self.picturesSource) else { return  }
                
                do {

                    data = try Data(contentsOf: url)
                    
                    self.writeData(data: data, to: filePath)
                    self.optionData(data: data)
                }catch {
                    
                    print(error)
                }
            }
            
        }
    }
    
    //MARK: 写入本地文件保存数据
    fileprivate func writeData(data: Data, to filePath: String) {
        
        do {
            try data.write(to: URL(fileURLWithPath: filePath))
        } catch  {
            print(error)
        }
    }
    
    //MARK: 处理数据存入dataArry 刷新collectionView
    fileprivate func optionData(data: Data) {
        
        do {
            let dict = try JSONSerialization.jsonObject(with: data, options: [.allowFragments,.mutableLeaves]) as! [String: Any]
            
            let subData = dict["data"] as! [String: Any]
            let blogs = subData["blogs"] as! [[String: Any]]
            for object in blogs {
                
                let isrc = object["isrc"] as! String
                let iwd = object["iwd"] as! NSNumber.FloatLiteralType
                let iht = object["iht"] as! NSNumber.FloatLiteralType
                
                let model = PictureModel(imageURL: isrc, imageWidth: iwd, imageHeigth: iht)
                self.dataArray.append(model)
            }
            
            DispatchQueue.main.async {
                
                self.collectionView.reloadData()
            }
            
        }catch {
            
            print(error)
            
        }
    }

}

//MARK: collectionView协议方法 CHTCollectionView协议方法
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! WaterCell
        
        cell.loadContent(with: dataArray[indexPath.row].imageURL)
        return cell
    }
    
    //返回每个cell的size CHTCollectionView的协议方法
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAt indexPath: IndexPath!) -> CGSize {
        
        let model = dataArray[indexPath.row]
        return CGSize(width: CGFloat(model.imageWidth), height: CGFloat(model.imageHeigth))
    }
    
}

class WaterCell: UICollectionViewCell {
    
    private let imageView: UIImageView
    
    override init(frame: CGRect) {
        
        imageView = UIImageView(frame: CGRect.zero)
        
        super.init(frame: frame)
        
        imageView.frame = contentView.bounds
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        contentView.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func loadContent(with url: String) {
        
        imageView.alpha = 0
        contentView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        
        imageView.sd_setImage(with: URL(string: url), completed: {[weak self] image, error, type, url in
            
            self?.imageView.image = image
            UIView.animate(withDuration: 0.5, animations: {
                
                self?.imageView.alpha = 1
                self?.contentView.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        })
    }
}

struct PictureModel {
    
    var imageURL: String
    var imageWidth: Double
    var imageHeigth: Double
}
