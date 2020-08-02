Pod::Spec.new do |s|
  s.name             = 'NeumorphicUI'
  s.version          = '0.0.1'
  s.summary          = 'A framework built on UIKit that allows to create UIView modifiers.'
  s.homepage         = 'https://github.com/alberto093/NeumorphicUI'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Alberto Saltarelli' => 'a.saltarelli93@gmail.com' }
  s.source           = { :git => 'https://github.com/alberto093/NeumorphicUI.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.swift_versions = ['5.1', '5.2']
  s.source_files = 'Sources/NeumorphicUI/**/*.swift'
end
