platform :ios, '18.2'

target 'KotlinSwiftVideoCall' do
  use_frameworks! :linkage => :static
  
  pod 'GoogleWebRTC'
  pod 'Starscream', '~> 4.0.4'  # Spesifik bir versiyon belirttik

  post_install do |installer|
    installer.generated_projects.each do |project|
      project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['ENABLE_BITCODE'] = 'NO'
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '18.2'
          config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
          config.build_settings['ENABLE_APP_SANDBOX'] = 'NO'
          
          # Privacy bundle hatası için
          config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
          config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
        end
      end
    end
  end

  target 'KotlinSwiftVideoCallTests' do
    inherit! :search_paths
  end

  target 'KotlinSwiftVideoCallUITests' do
  end
end
