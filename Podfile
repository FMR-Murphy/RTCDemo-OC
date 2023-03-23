# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

# 火山引擎源
source 'https://github.com/volcengine/volcengine-specs.git'
source 'https://cdn.cocoapods.org/'

inhibit_all_warnings!

def LocalPods()
  # Local Pods
  pod 'FDeviceAuthorityManager', :path => 'dev-pods/FDeviceAuthorityManager', :inhibit_all_warnings => false
end

target 'RTCDemo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  LocalPods()
  
#  pod 'YYKit', '1.0.9'
  pod 'Masonry', '1.1.0'
  pod 'ReactiveObjC', '3.1.1'
  pod 'PromisesObjC', '2.0.0'
  pod 'IQKeyboardManager', '6.5.11'
  pod 'YYModel', '1.0.4'
  #火山引擎
  pod 'VolcEngineRTC', '3.45.602'
  
  
end

post_install do |installer|
  puts 'Determining pod project minimal deployment target'
  
#  pods_project = installer.pods_project
  deployment_target_key = 'IPHONEOS_DEPLOYMENT_TARGET'
#  deployment_targets = pods_project.build_configurations.map{ |config| config.build_settings[deployment_target_key] }
#  minimal_deployment_target = deployment_targets.min_by{ |version| Gem::Version.new(version) }
#
#  puts 'Minimal deployment target is ' + minimal_deployment_target
#  puts 'Setting each pod deployment target to ' + minimal_deployment_target
  
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings[deployment_target_key] = '12.0'
    end
  end

end
