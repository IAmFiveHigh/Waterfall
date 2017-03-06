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
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(WaterCell.self, forCellWithReuseIdentifier: cellIdentifier)
        view.addSubview(collectionView)
    }
    
    fileprivate func loadData() {

        DispatchQueue.global().async {
            
            guard let url = URL(string: self.picturesSource) else { return  }
            
            do {
                
                let data = try Data(contentsOf: url)
                
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
                    
                } catch  {
                    
                    print(error)
                }
            }catch {
                
                print(error)
            }
            
        }
        
        
    }

}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! WaterCell
        
        cell.loadContent(with: dataArray[indexPath.row].imageURL)
        return cell
    }
    
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
        
        imageView.sd_setImage(with: URL(string: url))
    }
}

struct PictureModel {
    
    var imageURL: String
    var imageWidth: Double
    var imageHeigth: Double
}
