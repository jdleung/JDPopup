//
//  JDPopupConfig.swift
//  JDPopup
//
//  Created by jdleung on 2021/9/7.
//

import UIKit

public class JDPopupConfig: NSObject {
    
    public var customWidth: CGFloat?
    
    public var customHeight: CGFloat?
    
    public var arrowWidth: CGFloat = 10.0
    
    public var arrowHeight: CGFloat = 10.0
    
    public var barTitleColor = UIColor.darkGray
    
    public var contentBgColor = UIColor.white
    
    public var borderColor = UIColor.lightGray
    
    public var borderWidth: CGFloat = 1.0
    
    /// pop view background color
    public var bgColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
    
    public var cornerRadius: CGFloat = 6.0
    
    public var barHeight: CGFloat = 40.0
    
    /// tap screen to close to pupup view
    public var tapScreenClose = true
    
    /// left and right spacing
    public var lrSpacing: CGFloat = 10.0
    
    /// top and bottom spacing
    public var tbSpacing: CGFloat = 10.0
    
    /// animation duration
    public var duration: Double = 0.2
    
    /// mask layer background color alpha
    public var shadowAlpha: CGFloat = 0.3
    
    /// exit button
    public var exitBtnTintColor = UIColor.lightGray
    
    public var exitBtnImage = UIImage(named: "exit", in: Bundle(for: JDPopup.self), compatibleWith: nil)
}
