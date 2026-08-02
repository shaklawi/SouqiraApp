platform :ios, '16.0'

target 'Souqira' do
  use_frameworks!

  # Google Sign In
  pod 'GoogleSignIn', '~> 7.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ''
    end
  end

  frameworks_script_path = 'Pods/Target Support Files/Pods-Souqira/Pods-Souqira-frameworks.sh'
  if File.exist?(frameworks_script_path)
    frameworks_script = File.read(frameworks_script_path)
    original_snippet = <<~'SH'
      if [ -L "${source}" ]; then
        echo "Symlinked..."
        source="$(readlink "${source}")"
      fi
    SH
    patched_snippet = <<~'SH'
      if [ -L "${source}" ]; then
        echo "Symlinked..."
        source="$(readlink "${source}")"
        if [[ "$source" != /* ]]; then
          source="$(dirname "$1")/${source}"
        fi
      fi
    SH

    if frameworks_script.include?(original_snippet)
      File.write(frameworks_script_path, frameworks_script.sub(original_snippet, patched_snippet))
    end
  end
end
