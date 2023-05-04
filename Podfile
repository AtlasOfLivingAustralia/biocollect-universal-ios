# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'Bio Control Hub' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Bio Control Hub
  pod 'AppAuth'
end

target 'BioCollect' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for BioCollect
  pod 'AppAuth'
end

target 'Oz Atlas' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Oz Atlas
  pod 'AppAuth'

  target 'Oz AtlasTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'Tracker' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Tracker
  pod 'AppAuth'
end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end