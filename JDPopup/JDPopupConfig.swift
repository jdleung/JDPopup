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
    public var backgoundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
    public var cornerRadius: CGFloat = 6
    public var barHeight: CGFloat = 40.0
    public var tapScreenClose = true
    public var lrSpacing: CGFloat = 10.0
    public var duration: Double = 0.2
    public var globalShadow = false
    public var shadowAlpha: CGFloat = 0.6
    public var exitBtnTintColor = UIColor.lightGray
    public var exitBtnImage = UIImage(named: "exit", in: Bundle(for: JDPopup.self), compatibleWith: nil)
}
