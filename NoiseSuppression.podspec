Pod::Spec.new do |s|
  s.name = "NoiseSuppression"

  s.version = '0.0.1'

  s.source = {
    :git => "https://github.com/BeeModule/NoiseSuppression.git",
    :tag => s.version,
    :submodules => true
  }

  s.license = 'Apache License 2.0'
  s.summary = 'OpenIM SDK for Swift.'
  s.homepage = 'https://github.com/BeeModule/NoiseSuppression'
  s.description = 'NoiseSuppression.'
  s.social_media_url = ''
  s.authors  = { 'Snow' => 'jangsky215@gmail.com' }
  s.documentation_url = 'https://github.com/BeeModule/NoiseSuppression'
  s.requires_arc = true
  
  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.0'
  # s.watchos.deployment_target = '3.0'
  # s.tvos.deployment_target = '10.0'

  s.source_files = s.osx.source_files = [
    'NoiseSuppression/Source/*.{h,c,m,mm,swift}',
  ]
  
  s.pod_target_xcconfig = {
    'ARCHS[sdk=iphoneos*]' => 'arm64',
  }
  
end
