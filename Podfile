target 'SciTuner'

platform :ios, 9.0

use_frameworks!

pod 'RealmSwift'
#pod 'MLPNeuralNet', '~> 1.0'

target 'SciTunerTests' do
    pod 'RealmSwift'
end

target 'SciTunerUITests' do
    pod 'RealmSwift'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
      config.build_settings['CLANG_ENABLE_CODE_COVERAGE'] = 'NO'
    end
  end
end
