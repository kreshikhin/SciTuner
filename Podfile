target 'SciTuner'

platform :ios, 9.0

use_frameworks!

pod 'RealmSwift'

target 'SciTunerTests' do
    pod 'RealmSwift'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
