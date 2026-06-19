require 'xcodeproj'
project_path = 'macos/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# Check if already added
unless target.build_phases.any? { |p| p.class == Xcodeproj::Project::Object::PBXShellScriptBuildPhase && p.name == 'Remove FinderInfo' }
  phase = project.new(Xcodeproj::Project::Object::PBXShellScriptBuildPhase)
  phase.name = 'Remove FinderInfo'
  phase.shell_script = 'xattr -cr "${TARGET_BUILD_DIR}/${WRAPPER_NAME}" || true'
  target.build_phases << phase
  project.save
  puts "Added Remove FinderInfo phase"
else
  puts "Phase already exists"
end
