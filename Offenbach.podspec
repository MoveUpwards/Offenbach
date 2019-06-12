Pod::Spec.new do |s|
  s.name                      = "Offenbach"
  s.version                   = "1.0.0"
  s.summary                   = "Offenbach"
  s.homepage                  = "https://gitlab.com/moveupwards/offenbach"
  s.license                   = { :type => "MIT", :file => "LICENSE" }
  s.author                    = { "Move Upwards" => "contact@moveupwards.com" }
  s.source                    = { :git => "https://gitlab.com/moveupwards/offenbach.git", :tag => s.version }
  s.ios.deployment_target     = "10.0"
  s.tvos.deployment_target    = "10.0"
  s.watchos.deployment_target = "3.0"
  s.osx.deployment_target     = "10.12"
  s.source_files              = "Sources/**/*"
  s.frameworks                = "Foundation"

  s.dependency 'Alamofire', '~> 5.0.0-beta.6'
end
