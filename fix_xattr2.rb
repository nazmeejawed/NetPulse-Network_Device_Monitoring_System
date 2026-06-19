require 'xcodeproj'
project_path = 'macos/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

phase = target.build_phases.find { |p| p.class == Xcodeproj::Project::Object::PBXShellScriptBuildPhase && p.name == 'Remove FinderInfo' }
if phase
  phase.shell_script = 'find "${TARGET_BUILD_DIR}/${WRAPPER_NAME}" -exec xattr -c {} \;'
  project.save
  puts "Updated script"
end
