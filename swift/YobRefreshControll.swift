//
//  YobRefreshControll.swift
//  Text
//
//  Created by Macx on 2017/4/13.
//  Copyright © 2017年 Macx. All rights reserved.
//

import UIKit
//下拉的三种状态
enum WBRefreshControllType {
    case normal
    case pull
    case refreshing
}

class WBRefreshControll: UIControl {

    var scrollView:UIScrollView?
    
    //创建三个控件
    fileprivate lazy var pullDownImageView: UIImageView = UIImageView(image: UIImage(named: "tableview_pull_refresh"))
    //  提示信息
    fileprivate lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "下拉刷新"
        label.textColor = UIColor.gray
        return label
    }()
    //  风火轮
    fileprivate lazy var indicatorView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    
    var refreshType:WBRefreshControllType = .normal
    {
        didSet{
            switch refreshType {
            case .normal:
                //print("原始")
                pullDownImageView.isHidden = false
                indicatorView.stopAnimating()
                messageLabel.text = "下拉刷新"
                UIView.animate(withDuration: 0.3, animations: { 
                    self.pullDownImageView.transform = CGAffineTransform.identity

                }, completion: { (_) in
                    if oldValue == .refreshing
                    {
                        UIView.animate(withDuration: 0.3, animations: { 
                            self.scrollView?.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
                        })
                    }
                })
                
            case .pull:
                //print("下拉")
                
                UIView.animate(withDuration: 0.3, animations: { 
                    
                    self.pullDownImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                })
                messageLabel.text = "松开刷新"
                
            case .refreshing:
                //print("正在刷新")
                indicatorView.startAnimating()
                pullDownImageView.isHidden = true
                messageLabel.text = "正在刷新"
                UIView.animate(withDuration: 0.3, animations: { 
                    
                    self.scrollView?.contentInset = UIEdgeInsetsMake(114, 0, 0, 0)
                })
                
                sendActions(for: .valueChanged)
            }
        }
    }
    
    //结束刷新
    func endRefreshing()
    {
        refreshType = .normal
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        
        refreshType = .normal
        
        //backgroundColor = UIColor.red
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI()
    {
        addSubview(pullDownImageView)
        addSubview(messageLabel)
        addSubview(indicatorView)
        pullDownImageView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: pullDownImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: pullDownImageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: -35))
        
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: messageLabel, attribute: .left, relatedBy: .equal, toItem: pullDownImageView, attribute: .right, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: indicatorView, attribute: .centerX, relatedBy: .equal, toItem: pullDownImageView, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: indicatorView, attribute: .centerY, relatedBy: .equal, toItem: pullDownImageView, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        
        if newSuperview is UIScrollView{
            
            scrollView = newSuperview as? UIScrollView
            
            self.frame = CGRect(origin: CGPoint(x:0,y:-50), size: CGSize(width: (scrollView?.bounds.size.width)!, height: 50))
            
            //kvo监听
            scrollView?.addObserver(self, forKeyPath: "contentOffset", options: .new, context:nil)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        //刚开始为-64
        let contentOffsetY = scrollView?.contentOffset.y
        
        if (scrollView?.isDragging)!
        {
            //如果是拖动状态下
            if contentOffsetY! > CGFloat(-114)
            {
                refreshType = .normal
            }else if refreshType == .normal
            {
                refreshType = .pull
            }
            
        }else
        {
            //松手
            if refreshType == .pull{
                refreshType = .refreshing
            }
            
        }
        
       // print(refreshType)

    }
    
    
}
