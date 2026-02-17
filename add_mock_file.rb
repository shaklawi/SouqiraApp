require 'xcodeproj'

project_path = 'Souqira.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the Services group
services_group = project.main_group['SouqiraApp']['Services']

# Add the MockDataService.swift file
file_ref = services_group.new_reference('MockDataService.swift')

# Add to compile sources
target = project.targets.first
target.source_build_phase.add_file_reference(file_ref)

project.save

puts "✅ Added MockDataService.swift to project"
