Pod::Spec.new do |s|
  s.name                      = "Offenbach"
  s.version                   = "1.0.6"
  s.summary                   = "Offenbach"
  s.homepage                  = "https://github.com/MoveUpwards/Offenbach"
  s.license                   = { :type => "MIT", :file => "LICENSE" }
  s.author                    = { "Move Upwards" => "contact@moveupwards.com" }
  s.source                    = { :git => "https://github.com/MoveUpwards/Offenbach.git", :tag => s.version }
  s.swift_version             = '5.0'
  s.ios.deployment_target     = "10.0"
  s.osx.deployment_target     = "10.13"
  s.source_files              = "Sources/**/*"
  s.frameworks                = "Foundation"

  s.dependency 'Alamofire', '5.0.0-beta.7'
end
