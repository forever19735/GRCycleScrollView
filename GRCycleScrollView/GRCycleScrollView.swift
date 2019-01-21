//
//  GRCycleScrollView.swift
//  GRCycleScrollView
//
//  Created by john.lin on 2019/1/21.
//  Copyright © 2019年 john.lin. All rights reserved.
//

import UIKit
import Kingfisher

protocol GRCycleScrollViewDelegate: class {
    func cycleViewDidSelectedIndex(_ index: Int)
}

class GRCycleScrollView: UIView {
    weak var delegate: GRCycleScrollViewDelegate?
    
    enum MarqueeViewDirection {
        case None, Left, Right
    }
    
    fileprivate var scrollView: UIScrollView?
    
    fileprivate var pageControl: UIPageControl?
    
    fileprivate var timer: Timer?
    
    fileprivate var currentImageView: UIImageView?
    
    fileprivate var otherImageView: UIImageView?
    
    fileprivate var currentIndex = 0
    
    fileprivate var nextIndex = 1
    
    fileprivate var currentDirection: MarqueeViewDirection = .None
    
    var duration: TimeInterval = 3.0
    
    var coverImage: UIImage? = nil
    
    var placeHolderImage: UIImage? = nil
    
    var imagePaths: Array<String> = [] {
        didSet {
            if imagePaths.count > 1 {
                scrollView?.isScrollEnabled = true
                startTimer()
            } else {
                scrollView?.isScrollEnabled = false
                stopTimer()
            }
            loadImage(imageView: self.currentImageView!, index: 0)
            setupPage()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupScrollView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func scroll() {
        self.scrollView?.setContentOffset(CGPoint(x: self.scrollView!.bounds.size.width * 2, y: 0), animated: true)
    }
    
    @objc fileprivate func imageTaped(_ tap: UITapGestureRecognizer) {
        delegate?.cycleViewDidSelectedIndex(currentIndex)
    }
}

extension GRCycleScrollView {
    fileprivate func setupImage() {
        self.currentImageView = createImage(index: 0)
        self.otherImageView = createImage(index: 1)
        
        self.scrollView?.addSubview(currentImageView!)
        self.scrollView?.addSubview(otherImageView!)
        
        self.currentImageView?.frame = CGRect(x: self.bounds.size.width, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        self.loadImage(imageView: self.currentImageView!, index: 0)
    }
    
    fileprivate func setupPage() {
        if pageControl != nil {
            pageControl?.removeFromSuperview()
        }
        
        if imagePaths.count <= 1 {
            return
        }
        self.pageControl = UIPageControl(frame: CGRect(x: 0, y: self.bounds.size.height - 30, width: self.bounds.size.width, height: 30))
        self.addSubview(self.pageControl!)
        
        self.pageControl?.numberOfPages = self.imagePaths.count
        self.pageControl?.currentPage = 0
        self.pageControl?.hidesForSinglePage = true
    }
    
    fileprivate func setupScrollView() {
        self.scrollView = UIScrollView(frame: self.bounds)
        self.scrollView?.contentSize = CGSize(width: self.bounds.size.width * 3, height: self.bounds.size.height)
        self.scrollView?.contentOffset = CGPoint(x: self.bounds.size.width, y: 0)
        self.scrollView?.isPagingEnabled = true
        self.scrollView?.bounces = false
        self.scrollView?.scrollsToTop = false
        self.scrollView?.showsVerticalScrollIndicator = false
        self.scrollView?.showsHorizontalScrollIndicator = false
        self.scrollView?.delegate = self
        self.addSubview(self.scrollView!)
        
        setupImage()
        setupPage()
        reloadImage()
        
        if self.pageControl?.numberOfPages == 1 {
            self.scrollView?.contentSize = CGSize(width: self.bounds.size.width, height: self.bounds.size.height)
            self.scrollView?.contentOffset = CGPoint.zero
            self.currentImageView?.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        }
    }
    
    fileprivate func createImage(index: Int) -> UIImageView {
        let image = UIImageView()
        image.isUserInteractionEnabled = true
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.frame = CGRect(x: scrollView!.frame.size.width * CGFloat(index), y: 0, width: scrollView!.frame.size.width, height: scrollView!.frame.size.height)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTaped(_:)))
        self.addGestureRecognizer(tap)
        
        return image
    }
    
    fileprivate func reloadImage() {
        self.currentDirection = .None
        //取得當前位置
        let index = self.scrollView!.contentOffset.x / self.scrollView!.bounds.size.width
        if index == 1 { return }
        self.currentIndex = self.nextIndex
        self.pageControl!.currentPage = self.currentIndex
        
        self.currentImageView?.frame = CGRect(x: self.scrollView!.bounds.size.width, y: 0, width: self.scrollView!.bounds.size.width, height: self.scrollView!.bounds.size.height)
        self.currentImageView!.image = self.otherImageView!.image
        self.scrollView?.contentOffset = CGPoint(x: self.scrollView!.bounds.size.width, y: 0)
    }
    
    fileprivate func loadImage(imageView: UIImageView, index: Int) {
        if imagePaths.count == 0 {
            imageView.image = coverImage
        } else {
            let imgPath = imagePaths[index]
            
            if imgPath.hasPrefix("http") {
                let url = URL(string: imgPath)
                imageView.kf.setImage(with: url, placeholder: placeHolderImage)
            } else {
                if let image = UIImage(named: imgPath) {
                    imageView.image = image
                } else {
                    imageView.image = UIImage.init(contentsOfFile: imgPath)
                }
            }
        }
    }
}
extension GRCycleScrollView {
    func startTimer() {
        if imagePaths.count <= 1 { return }
        
        stopTimer()
        timer = Timer.scheduledTimer(timeInterval: self.duration, target: self, selector: #selector(scroll), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

extension GRCycleScrollView: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopTimer()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        startTimer()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.reloadImage()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.currentDirection = .None
        self.reloadImage()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.currentDirection = scrollView.contentOffset.x > scrollView.bounds.size.width ? .Left : .Right
        if self.imagePaths.count == 0 { return }
        if self.currentDirection == .Right {
            self.otherImageView!.frame = CGRect(x: 0, y: 0, width: scrollView.bounds.size.width, height: scrollView.bounds.size.height)
            self.nextIndex = self.currentIndex - 1
            if self.nextIndex < 0 {
                self.nextIndex = self.imagePaths.count - 1
            }
        } else if self.currentDirection == .Left {
            self.otherImageView?.frame = CGRect(x: self.currentImageView!.frame.maxX, y: 0, width: scrollView.bounds.size.width, height: scrollView.bounds.size.height)
            self.nextIndex = (self.currentIndex + 1) % self.imagePaths.count
        }
        
        self.loadImage(imageView: self.otherImageView!, index: self.nextIndex)
    }
}
