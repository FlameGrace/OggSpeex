#
#  Be sure to run `pod spec lint OggSpeex.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "OggSpeex"
  s.version      = "0.0.2"
  s.summary      = "A voice tool with recording and playing for iOS. Use speex with ogg header to compress and uncompress voice."
  s.homepage     = "https://github.com/FlameGrace/OggSpeex"
  s.license      = "BSD"
  s.author             = { "FlameGrace" => "flamegrace@hotmail.com" }
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/FlameGrace/OggSpeex.git", :tag => "0.0.2" }
  s.source_files  = "OggSpeex", "OggSpeex/**/*.{h,m}"
  s.public_header_files = "OggSpeex/**/*.h"
  s.dependency = "DispatchTimer"
  s.xcconfig = { "LIBRARY_SEARCH_PATHS" => '"$(PODS_ROOT)/OggSpeex/OggSpeex/lib"',
  "ENABLE_BITCODE" => 'NO',
  "Preprocessor Macros" => '',
 }
end
