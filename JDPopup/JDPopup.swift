//
//  JDPopupView.swift
//  JDPopup
//
//  Created by jdleung on 2021/9/7.
//

import UIKit
import Foundation

fileprivate enum JDPopupArrowDirection {
    case up
    case down
}

extension JDPopup: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let touchView = touch.view else {
            return true
        }
        
        let touchViewNames = ["UITableViewCellContentView", "UICollectionView", "UICollectionViewCell", "UITableView", "UITableViewCell" ]
        
        if touchViewNames.firstIndex(of: NSStringFromClass(touchView.classForCoder)) != nil {
            return false
        }

        guard let spView = touchView.superview?.superview else {
            return true
        }
        
        if touchViewNames.firstIndex(of: NSStringFromClass(spView.classForCoder)) != nil {
            return false
        }
        
        return true
    }
}


@objc
public class JDPopup: UIView {
    
    public typealias ViewAdapter = (_ subview: UIView) -> Void
    
    public var config = JDPopupConfig()
    
    fileprivate var isPortrait = false
    fileprivate var popView: UIView!
    fileprivate var barTitle = ""
    fileprivate var contentView: UIView!
    fileprivate var arrowPoint: CGPoint?
    fileprivate var arrowDirection: JDPopupArrowDirection = .up
    fileprivate var barViewAdapter: ViewAdapter? //((_ barView: UIView) -> Void)?
    fileprivate var contentViewAdapter: ViewAdapter? // ((_ contentView: UIView) -> Void)?
    
    fileprivate lazy var tapGesture : UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onBackgroudViewTapped(gesture:)))
        gesture.delegate = self
        return gesture
    }()
    
    
    convenience public init(sender: UIButton, barTitle: String = "", barViewAdapter: ViewAdapter? = nil, contentViewAdapter: ViewAdapter?) {
        self.init(frame: UIScreen.main.bounds)

        let ap = CGPoint(x: sender.center.x - config.lrSpacing, y: sender.center.y)
        self.setDefault(ap, barTitle: barTitle, barViewAdapter: barViewAdapter, contentViewAdapter: contentViewAdapter)
    }
    
    
    convenience public init(event: UIEvent, barTitle: String = "", barViewAdapter: ViewAdapter? = nil, contentViewAdapter: ViewAdapter?) {
        self.init(frame: UIScreen.main.bounds)
        
        guard let sender = event.allTouches?.first?.view!, let superView = sender.superview else {
            return
        }
        let senderRect = superView.convert(sender.frame, to: self)
        
        let ap = CGPoint(x: senderRect.origin.x + senderRect.width/2 - config.lrSpacing, y: senderRect.origin.y + senderRect.height/2)
        self.setDefault(ap, barTitle: barTitle, barViewAdapter: barViewAdapter, contentViewAdapter: contentViewAdapter)
    }
    
    
    fileprivate func setDefault(_ ap: CGPoint, barTitle: String = "", barViewAdapter: ViewAdapter? = nil, contentViewAdapter: ViewAdapter?) {
        self.arrowPoint = ap
        self.barTitle = barTitle
        self.barViewAdapter = barViewAdapter
        self.contentViewAdapter = contentViewAdapter
        self.isPortrait = UIApplication.shared.statusBarOrientation.isPortrait
        
        if self.arrowPoint!.y > UIScreen.main.bounds.height/2 {
            self.arrowPoint!.y -= config.arrowHeight
            self.arrowDirection = .down
        } else {
            self.arrowPoint!.y += config.arrowHeight
            self.arrowDirection = .up
        }
        
        NotificationCenter.default.addObserver(self, selector:#selector(orientationChanged(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc
    fileprivate func orientationChanged(_ notification: NSNotification) {
        if isPortrait != UIApplication.shared.statusBarOrientation.isPortrait {
            self.dismiss()
        }
    }
        
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func present() {
        
        if self.arrowPoint == nil || self.contentViewAdapter == nil { return }

        UIApplication.shared.keyWindow?.addSubview(self)
        
        if config.tapScreenClose {
            self.addGestureRecognizer(self.tapGesture)
        }
        
        self.setPopView()
        self.setContentView()
        self.setBarView()
        self.showUp()
        
    }
    
    fileprivate func setPopView() {
        var safeAreaInset = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            safeAreaInset = UIApplication.shared.keyWindow?.safeAreaInsets ?? UIEdgeInsets.zero
        }
        
        var px = self.config.lrSpacing
        var py = self.arrowPoint!.y
        var pw = UIScreen.main.bounds.width - self.config.lrSpacing * 2
        var ph = UIScreen.main.bounds.height - self.arrowPoint!.y - safeAreaInset.bottom
    
        if self.arrowDirection == .down {
            py = safeAreaInset.top
            ph = self.arrowPoint!.y - py
        }
        
        // custom height must be less than available height
        if let ch = config.customHeight, ch < ph {
            ph = ch
            if self.arrowDirection == .down {
                py = self.arrowPoint!.y - ph
            }
        }
        
        if let cw = config.customWidth, cw < pw {
            pw = cw
            px = self.arrowPoint!.x - pw/2 + config.lrSpacing
            if px < config.lrSpacing {
                px = config.lrSpacing
            } else if px + pw > UIScreen.main.bounds.width - config.lrSpacing {
                px = UIScreen.main.bounds.width - config.lrSpacing - pw
            }
            self.arrowPoint!.x -= px - config.lrSpacing
        }
        
        popView = UIView(frame: CGRect(x: px, y: py, width: pw, height: ph))
        self.addSubview(popView!)
        
        self.drawBackgroundLayerWithArrowPoint(self.arrowPoint!)
        self.setAnchorPoint()
    }
    
    fileprivate func setContentView() {
        var contentY: CGFloat = config.arrowHeight + config.barHeight + config.borderWidth/2
        var contentH: CGFloat = self.popView.frame.height - contentY - config.borderWidth/2
        if self.arrowDirection == .down {
            contentY = config.borderWidth/2
            contentH = self.popView.frame.height - contentY - config.arrowHeight - config.barHeight - config.borderWidth
        }
        
        contentView = UIView(frame: CGRect(x: config.borderWidth/2, y: contentY, width: self.popView.frame.width - config.borderWidth, height: contentH))
        contentView.backgroundColor = config.contentBgColor
        self.popView.addSubview(contentView)
              
        let maskLayer = CAShapeLayer()
        let corners: UIRectCorner = self.arrowDirection == .up ? [.bottomLeft, .bottomRight] : [.topLeft, .topRight]
        maskLayer.path = UIBezierPath(roundedRect: contentView.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: config.cornerRadius, height: config.cornerRadius)).cgPath
        contentView.layer.mask = maskLayer
        
        if let sva = contentViewAdapter {
            sva(contentView)
        }
    }
    
    fileprivate func setBarView() {
        var y: CGFloat = config.arrowHeight + config.borderWidth/2
        if self.arrowDirection == .down {
            y = self.popView.frame.height - config.arrowHeight - config.barHeight - config.borderWidth/2
        }
        let barView = UIView(frame: CGRect(x: config.borderWidth/2, y: y, width: self.popView.frame.width - config.borderWidth, height: config.barHeight))
        barView.backgroundColor = .clear
        self.popView.addSubview(barView)
        
        let xbtn = UIButton(frame: CGRect(x: barView.frame.width - 35, y: config.barHeight/2 - 15, width: 30, height: 30))
        xbtn.setImage(config.exitBtnImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        xbtn.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        xbtn.tintColor = config.exitBtnTintColor
        barView.addSubview(xbtn)
        
        if let bva = barViewAdapter {
            bva(barView)
            
        } else {
            let titleLabel = UILabel(frame: CGRect(x: 10, y: 5, width: barView.frame.width - 45, height: 30))
            titleLabel.textColor = config.barTitleColor
            titleLabel.font = UIFont.systemFont(ofSize: 17)
            titleLabel.text = barTitle
            barView.addSubview(titleLabel)
        }
    }
    
    @objc
    fileprivate func onBackgroudViewTapped(gesture : UIGestureRecognizer) {
        self.dismiss()
    }
    
    @objc
    fileprivate func dismiss() {
        self.popView.transform = CGAffineTransform(scaleX: 1, y: 1)
        UIView.animate(withDuration: self.config.duration, animations: {
            self.backgroundColor = .clear
            self.popView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }, completion: {_ in
            self.popView.removeFromSuperview()
            self.removeFromSuperview()
        })
    }
    
    fileprivate func showUp() {
        let bgColor = UIColor.lightGray.withAlphaComponent(0.4)
        self.popView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: self.config.duration, animations: {
            self.backgroundColor = bgColor
            self.popView.alpha = 1
            self.popView.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }
    
    public func toggleContentView(_ contentAdapter: ((_ contentView: UIView) -> Void)?) {
        guard let cva = contentAdapter else {
            return
        }
        for sv in contentView.subviews {
            sv.removeFromSuperview()
        }
        cva(contentView)
    }
    
    fileprivate func setAnchorPoint() {
        
        let ay: CGFloat = arrowDirection == .up ? 0 : 1
        let anchorPoint = CGPoint(x: self.arrowPoint!.x / popView.frame.size.width, y: ay)
        
        var newPoint = CGPoint(x: popView.bounds.size.width * anchorPoint.x,
                               y: popView.bounds.size.height * anchorPoint.y)


        var oldPoint = CGPoint(x: popView.bounds.size.width * popView.layer.anchorPoint.x,
                               y: popView.bounds.size.height * popView.layer.anchorPoint.y)

        newPoint = newPoint.applying(popView.transform)
        oldPoint = oldPoint.applying(popView.transform)

        var position = popView.layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x

        position.y -= oldPoint.y
        position.y += newPoint.y

        popView?.layer.position = position
        popView?.layer.anchorPoint = anchorPoint
    }
    
    fileprivate func drawBackgroundLayerWithArrowPoint(_ arrowPoint: CGPoint) {
        let bgLayer = CAShapeLayer()
        bgLayer.path = getBackgroundPath(arrowPoint: arrowPoint).cgPath
        bgLayer.fillColor = config.backgoundColor.cgColor
        bgLayer.strokeColor = config.borderColor.cgColor
        bgLayer.lineWidth = config.borderWidth
        bgLayer.cornerRadius = config.cornerRadius
        self.popView.layer.insertSublayer(bgLayer, at: 0)
    }
    
    func getBackgroundPath(arrowPoint: CGPoint) -> UIBezierPath {
        
        let pw = self.popView.frame.size.width
        let ph = self.popView.frame.size.height
        let radius: CGFloat = config.cornerRadius
        
        let path: UIBezierPath = UIBezierPath()
        path.lineJoinStyle = .round
        path.lineCapStyle = .round
        
        if self.arrowDirection == .up {
            if arrowPoint.x >= pw - config.arrowWidth/2 {
                path.move(to: CGPoint(x: pw - config.arrowWidth * 3, y: config.arrowHeight))
                path.addLine(to: CGPoint(x: arrowPoint.x, y: 0))
                path.addLine(to: CGPoint(x: pw, y: config.arrowHeight))
                
            } else {
                if arrowPoint.x < config.arrowWidth/2 {
                    path.move(to: CGPoint(x: 0, y: config.arrowHeight))
                    path.addLine(to: CGPoint(x: arrowPoint.x, y: 0))
                    path.addLine(to: CGPoint(x: config.arrowWidth * 3, y: config.arrowHeight))
                    path.addLine(to: CGPoint(x: pw - radius, y: config.arrowHeight))
                    
                } else {
                    path.move(to: CGPoint(x: arrowPoint.x - config.arrowWidth, y: config.arrowHeight))
                    path.addLine(to: CGPoint(x: arrowPoint.x, y: 0))
                    path.addLine(to: CGPoint(x: arrowPoint.x + config.arrowWidth, y: config.arrowHeight))
                    path.addLine(to: CGPoint(x:pw - radius, y: config.arrowHeight))
                }
                
                path.addArc(withCenter: CGPoint(x: pw - radius, y: config.arrowHeight + radius),
                            radius: radius,
                            startAngle: .pi / 2 * 3,
                            endAngle: 0,
                            clockwise: true)
            }
            
            path.addLine(to: CGPoint(x: pw, y: ph - radius))
            path.addArc(withCenter: CGPoint(x: pw - radius, y: ph - radius),
                        radius: radius,
                        startAngle: 0,
                        endAngle: .pi / 2,
                        clockwise: true)
            path.addLine(to: CGPoint(x: radius, y: ph))
            path.addArc(withCenter: CGPoint(x: radius, y: ph - radius),
                        radius: radius,
                        startAngle: .pi / 2,
                        endAngle: .pi,
                        clockwise: true)
            
            if arrowPoint.x < config.arrowWidth/2  {
                path.addLine(to: CGPoint(x: 0, y: config.arrowWidth * 3))
                
            } else {
                path.addLine(to: CGPoint(x: 0, y: config.arrowHeight + radius))
                path.addArc(withCenter: CGPoint(x: radius, y: config.arrowHeight + radius),
                            radius: radius,
                            startAngle: .pi,
                            endAngle: .pi / 2 * 3,
                            clockwise: true)
            }
            path.close()

        } else {
            if arrowPoint.x >= pw - config.arrowWidth/2 {
                path.move(to: CGPoint(x: pw - config.arrowWidth * 3, y: ph - config.arrowHeight))
                path.addLine(to: CGPoint(x: arrowPoint.x, y: ph))
                path.addLine(to: CGPoint(x: pw, y: ph - config.arrowHeight))
                
            } else {
                if arrowPoint.x < config.arrowWidth/2 {
                    path.move(to: CGPoint(x: 0, y: ph - config.arrowHeight))
                    path.addLine(to: CGPoint(x: arrowPoint.x, y: ph))
                    path.addLine(to: CGPoint(x: config.arrowWidth * 3, y: ph - config.arrowHeight))
                    path.addLine(to: CGPoint(x: pw - radius, y: ph - config.arrowHeight))
                    
                } else {
                    path.move(to: CGPoint(x: arrowPoint.x - config.arrowWidth, y: ph - config.arrowHeight))
                    path.addLine(to: CGPoint(x: arrowPoint.x, y: ph))
                    path.addLine(to: CGPoint(x: arrowPoint.x + config.arrowWidth, y: ph - config.arrowHeight))
                    path.addLine(to: CGPoint(x: pw - radius, y: ph - config.arrowHeight))
                }
                
                path.addArc(withCenter: CGPoint(x: pw - radius, y: ph - config.arrowHeight - radius),
                            radius: radius,
                            startAngle: .pi / 2,
                            endAngle: 0,
                            clockwise: false)
            }
                        
            path.addLine(to: CGPoint(x: pw, y: radius))
            path.addArc(withCenter: CGPoint(x: pw - radius, y: radius),
                        radius: radius,
                        startAngle: 0,
                        endAngle: .pi / 2 * 3,
                        clockwise: false)
            path.addLine(to: CGPoint(x: radius, y: 0))
            path.addArc(withCenter: CGPoint(x: radius, y: radius),
                        radius: radius,
                        startAngle: .pi / 2 * 3,
                        endAngle: .pi,
                        clockwise: false)
            
            if arrowPoint.x < config.arrowWidth/2  {
                path.addLine(to: CGPoint(x: 0, y: ph - config.arrowHeight*3))
                
            } else {
                path.addLine(to: CGPoint(x: 0, y: ph - config.arrowHeight - radius))
                path.addArc(withCenter: CGPoint(x: radius, y: ph - config.arrowHeight - radius),
                            radius: radius,
                            startAngle: .pi,
                            endAngle: .pi / 2,
                            clockwise: false)
            }
            
            path.close()
        }
        return path
    }
    
}
