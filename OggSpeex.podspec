#
#  Be sure to run `pod spec lint OggSpeex.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "OggSpeex"
  s.version      = "0.0.1"
  s.summary      = "A short description of OggSpeex."
  s.description  = <<-DESC
                      OggSpeex Tools
                   DESC

  s.author             = { "Flame Grace" => "Flame Grace" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/FlameGrace/OggSpeex.git", :tag => "0.0.1" }

  s.source_files  = "OggSpeex","OggSpeex/OggSpeex/**/*.{h,m,mm}"

  s.homepage     = "flamegrace@hotmail"
  s.license      = { :type => "BSD", :file => "LICENSE" }

  s.vendored_frameworks = 'OggSpeex/Framework/*.framework'
  s.xcconfig = { 
    'GCC_PREPROCESSOR_DEFINITIONS' => '',
    'ENABLE_BITCODE' => 'NO'
  }

  s.library = 'stdc++'

  s.dependency "DispatchTimer"

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"

end
