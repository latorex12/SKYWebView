//
// Created by 梁天 on 2018/1/9.
// Copyright (c) 2018 com.lator. All rights reserved.
//

import UIKit

protocol SKYWebViewControllerUIConfigDelegate {
    /// 是否显示加载HUD
    var showLoading : Bool {get set}
    /// 是否显示进度条
    var showProgress : Bool {get set}
    /// 默认标题
    var fixedTitle : String? {get set}
    /// 返回按钮图片,可空，默认为返回文字
    var backBarButtonImage : UIImage? {get set}
    /// 关闭按钮图片，可空，默认为关闭文字
    var closeBarButtonImage : UIImage? {get set}
    /// 进度条颜色
    var progressTintColor : UIColor? {get set}
    /// 进度条背景色
    var trackTintColor : UIColor? {get set}
}

struct SKYWebViewControllerUIConfig : SKYWebViewControllerUIConfigDelegate {
    var showLoading: Bool = false
    var showProgress: Bool = true
    var fixedTitle: String?
    var backBarButtonImage: UIImage?
    var closeBarButtonImage: UIImage?
    var progressTintColor: UIColor?
    var trackTintColor: UIColor?
}
