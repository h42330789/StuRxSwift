# Uncomment the next line to define a global platform for your projecte
install! 'cocoapods', :warn_for_unused_master_specs_repo => false
#source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '13.0'

target 'StuRxSwift' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for StuRxSwift
  # MVVM架構
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxDataSources'
  pod 'Reusable'
  pod 'RxFeedback'
  pod 'SnapKit'
  pod 'Alamofire'
  pod 'SwiftyJSON'
  pod 'Result'
  pod 'Moya/RxSwift'
  pod 'ObjectMapper'
#  pod 'Moya-ObjectMapper/RxSwift'
  
  
  pod 'LookinServer', :configurations => ['Debug']
  

  target 'StuRxSwiftTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'StuRxSwiftUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if Gem::Version.new('13.0') > Gem::Version.new(config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'])
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
  end
end
