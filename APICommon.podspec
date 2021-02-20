Pod::Spec.new do |spec|
  spec.name          = 'APICommon'
  spec.version       = '1.0.0'
  spec.license       = { :type => 'MIT', :file => 'LICENSE.md' }
  spec.homepage      = 'https://github.com/MatrixSenpai/api-common'
  spec.authors       = { 'Mason Phillips' => 'math.matrix@icloud.com' }
  spec.summary       = 'A small wrapper around UISession for interfacing with apis'
  spec.source        = { :git => 'https://github.com/MatrixSenpai/api-common.git', :tag => spec.version.to_s }
  spec.swift_version = '4.0'

  spec.ios.deployment_target  = '12.0'
  spec.osx.deployment_target  = '10.10'

  spec.default_subspecs = 'Core', 'RxExtensions'

  spec.subspec 'Core' do |subspec|
    subspec.source_files = 'Sources/core/*.swift'
  end
  
  spec.subspec 'RxExtensions' do |subspec|
    subspec.source_files = 'Sources/rx_exts/*.swift'
    
    subspec.dependency 'APICommon/Core'
    subspec.dependency 'RxSwift'
  end
end
