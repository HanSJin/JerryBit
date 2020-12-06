# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def network
  pod 'Alamofire', '< 5.0'
end

def utils
  pod 'JSONWebToken'
end

def rx
  pod 'RxSwift'
  pod 'RxCocoa', '5.1.0'
end

target 'JadongMaeMae' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  network
  utils
  rx
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
       
      if #{target.name} == "JSONWebToken"
        config.build_settings['SWIFT_VERSION'] = '4.2'
      end

    end
  end
end
