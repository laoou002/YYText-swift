#
#  Be sure to run `pod spec lint YYText-swift.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/

Pod::Spec.new do |s|
  s.name         = "YYText-swift" # 项目名称
  s.version      = "1.0.5"        # 版本号, 即标签号
  s.swift_versions      = "5.0"
  s.summary      = "致敬YYText的作者，YYText的Swift版本" # 项目简介

  s.homepage     = "https://github.com/laoou002/YYText-swift" # 你的主页
  s.source       = { :git => "https://github.com/laoou002/YYText-swift.git", :tag => "#{s.version}" }#你的仓库地址，不能用SSH地址
  s.source_files  = 'YYText-swift/YYText/*.swift', 'YYText-swift/YYText/*/*.swift'
  s.platform     = :ios, "13.0" #平台及支持的最低版本
  s.frameworks   = "UIKit", "Foundation" #支持的框架
  s.requires_arc = true
  s.license      = { :type => 'MIT', :file => 'LICENSE' } # 开源证书
  # User
  s.author             = { "ouyongheng" => "976187247@qq.com" } # 作者信息

end
