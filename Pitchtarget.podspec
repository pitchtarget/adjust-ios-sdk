Pod::Spec.new do |s|
  s.name         = "Pitchtarget"
  s.version      = "3.0.0"
  s.summary      = "Pitchtarget Tracking SDK"
  s.homepage     = "http://pitchtarget.com"
  s.license      = { :type => 'MIT', :file => 'MIT-LICENSE' }
  s.author       = { "Pitchtarget" => "support@pitchtarget.com" }
  s.source       = { :git => "https://bitbucket.org/rocodromo/addictive-ios-sdk/adjust_ios_sdk.git", :branch => "master" }
  s.platform     = :ios, '4.3'
  s.framework    = 'SystemConfiguration'
  s.source_files = 'Adjust/*.{h,m}', 'Adjust/AIAdditions/*.{h,m}'
  s.requires_arc = true
end
