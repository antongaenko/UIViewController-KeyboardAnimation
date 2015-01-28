Pod::Spec.new do |s|
  s.name     = 'UIViewController+KeyboardAnimation'
  s.version  = '1.2'
  s.ios.deployment_target   = '6.0'
  s.license  = { :type => 'MIT', :file => 'LICENSE' }
  s.summary  = 'Showing/dismissing keyboard animation in simple view controller category.'
  s.homepage = 'https://github.com/Just-/UIViewController-KeyboardAnimation'
  s.author   = { 'Anton Gaenko' => 'antony.gaenko@gmail.com' }
  s.social_media_url = 'https://twitter.com/Anton_Gaenko'
  s.requires_arc = true
  s.source   = {
    :git => 'https://github.com/Just-/UIViewController-KeyboardAnimation.git',
    :branch => 'master',
    :tag => s.version.to_s
  }
  s.source_files = '*.{h,m}'
  s.public_header_files = '*.h'
end
