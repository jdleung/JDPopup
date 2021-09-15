
Pod::Spec.new do |spec|

  spec.name         = "JDPopup"
  spec.version      = "0.0.4"
  spec.summary      = "JDPopup is a light weight popup container"
  spec.description  = <<-DESC
  JDPopup is a light weight popup container which shows a popup view with an arrow that indicates the sender's position.
                   DESC

  spec.homepage     = "https://github.com/jdleung/JDPopup"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "jdleung" => "jdleungs@gmail.com" }
  
  spec.platform     = :ios, "9.0"
  spec.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }
  spec.ios.deployment_target = "9.0"
  spec.swift_version = "5.0"

  spec.source       = { :git => "https://github.com/jdleung/JDPopup.git", :tag => "#{spec.version}" }
  spec.source_files = "JDPopup/*.swift"
  spec.requires_arc = true
  spec.resource = "JDPopup/exit.png"
 

end
