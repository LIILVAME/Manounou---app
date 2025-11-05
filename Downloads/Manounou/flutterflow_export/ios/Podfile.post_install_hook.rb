# Hook post_install pour supprimer définitivement VerifyModule
# Ce fichier est source par le Podfile

def remove_verify_module_permanently(installer)
  installer.pods_project.targets.each do |target|
    next unless target.name == 'sqflite_darwin'
    
    # Supprimer toutes les phases shell script contenant modules-verifier
    phases_to_delete = []
    target.build_phases.each do |phase|
      if phase.is_a?(Xcodeproj::Project::Object::PBXShellScriptBuildPhase)
        script = phase.shell_script || ''
        if script.include?('modules-verifier') || script.include?('VerifyModule') || script.include?('/usr/bin/modules-verifier')
          phases_to_delete << phase
        end
      end
    end
    
    phases_to_delete.each do |phase|
      target.build_phases.delete(phase)
      puts "✅ Phase VerifyModule supprimée pour #{target.name}"
    end
    
    # Forcer les settings pour empêcher la recréation
    target.build_configurations.each do |config|
      config.build_settings['DEFINES_MODULE'] = 'NO'
      config.build_settings['ENABLE_MODULE_VERIFIER'] = 'NO'
      config.build_settings['CLANG_ENABLE_MODULES'] = 'NO'
      config.build_settings['CLANG_MODULES_AUTOLINK'] = 'NO'
      config.build_settings['CLANG_ENABLE_MODULE_DEBUGGING'] = 'NO'
    end
  end
  
  installer.pods_project.save
end

