Pod::Spec.new do |s|
  s.name                      = "Offenbach"
  s.version                   = "2.1.0"
  s.summary                   = "Offenbach"
  s.homepage                  = "https://github.com/MoveUpwards/Offenbach"
  s.license                   = { :type => "MIT", :file => "LICENSE" }
  s.author                    = { "Move Upwards" => "contact@moveupwards.com" }
  s.source                    = { :git => "https://github.com/MoveUpwards/Offenbach.git", :tag => s.version }
  s.swift_version             = '5.2'
  s.ios.deployment_target     = "10.0"
  s.osx.deployment_target     = "10.13"
  s.source_files              = "Sources/**/*"
  s.frameworks                = "Foundation"

  s.dependency 'Alamofire', '5.1.0'
end
