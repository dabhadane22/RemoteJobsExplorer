require 'xcodeproj'
require 'fileutils'

project_name = 'RemoteJobsExplorer'
project_path = "#{project_name}.xcodeproj"

puts "Removing existing project if any..."
FileUtils.rm_rf(project_path)

project = Xcodeproj::Project.new(project_path)

# App Target
target = project.new_target(:application, project_name, :ios, '17.0')

target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "com.example.#{project_name}"
  config.build_settings['INFOPLIST_KEY_UIApplicationSceneManifest_Generation'] = 'YES'
  config.build_settings['INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents'] = 'YES'
  config.build_settings['INFOPLIST_KEY_UILaunchScreen_Generation'] = 'YES'
  config.build_settings['INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad'] = 'UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight'
  config.build_settings['INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone'] = 'UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight'
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['DEVELOPMENT_TEAM'] = ''
  config.build_settings['CODE_SIGN_STYLE'] = 'Automatic'
  config.build_settings['CODE_SIGN_IDENTITY'] = 'Apple Development'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '1,2' # iPhone and iPad
end

main_group = project.main_group.new_group(project_name, project_name)

puts "Adding source files to project..."
# Recursively find all Swift files in the source directory
Dir.glob("#{project_name}/**/*.swift").each do |file_path|
  relative_path = file_path.sub(%r{^#{project_name}/}, '')
  dirs = relative_path.split('/')[0...-1]
  
  current_group = main_group
  dirs.each do |dir|
    found_group = current_group.groups.find { |g| g.name == dir || g.path == dir }
    current_group = found_group || current_group.new_group(dir, dir)
  end
  
  file_name = File.basename(file_path)
  file_ref = current_group.new_reference(file_name)
  target.source_build_phase.add_file_reference(file_ref, true)
end

puts "Adding SwiftLint Run Script phase..."
swiftlint_script = <<~SCRIPT
  if which swiftlint > /dev/null; then
    swiftlint
  else
    echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
  fi
SCRIPT
phase = target.new_shell_script_build_phase("SwiftLint")
phase.shell_script = swiftlint_script

puts "Adding test target..."
# Test Target
test_target_name = "#{project_name}Tests"
test_target = project.new_target(:unit_test_bundle, test_target_name, :ios, '17.0')

test_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "com.example.#{test_target_name}"
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['TEST_HOST'] = "$(BUILT_PRODUCTS_DIR)/#{project_name}.app/#{project_name}"
  config.build_settings['BUNDLE_LOADER'] = "$(TEST_HOST)"
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
end

project.root_object.attributes['TargetAttributes'] = {
  test_target.uuid => {
    'TestTargetID' => target.uuid
  }
}

test_group = project.main_group.new_group(test_target_name, test_target_name)

puts "Adding test source files to project..."
Dir.glob("#{test_target_name}/**/*.swift").each do |file_path|
  relative_path = file_path.sub(%r{^#{test_target_name}/}, '')
  dirs = relative_path.split('/')[0...-1]

  current_group = test_group
  dirs.each do |dir|
    found_group = current_group.groups.find { |g| g.name == dir || g.path == dir }
    current_group = found_group || current_group.new_group(dir, dir)
  end

  file_name = File.basename(file_path)
  file_ref = current_group.new_reference(file_name)
  test_target.source_build_phase.add_file_reference(file_ref, true)
end

puts "Saving project..."
project.save
puts "Done!"
