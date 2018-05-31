# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'HumanityHospice' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!
  # Pods for HumanityHospice
pod 'Firebase/Core'
pod 'Firebase/Database'
pod 'Firebase/Auth'
pod 'Firebase/Storage'
pod 'RealmSwift'
pod 'DZNEmptyDataSet'
pod 'SnapKit', '~> 4.0'
pod 'ImagePicker'
# pod 'Lightbox'
# pod 'Hue'
# pod 'Imaginary'
pod 'Serrata'

  target 'HumanityHospiceTests' do
    inherit! :search_paths
  end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.1'
        end
    end
end
end
