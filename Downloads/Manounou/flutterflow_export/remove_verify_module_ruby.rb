#!/usr/bin/env ruby

# Script Ruby pour supprimer définitivement la phase VerifyModule
# Utilise la gem xcodeproj pour modifier le projet Xcode

require 'xcodeproj'

project_path = ARGV[0] || 'ios/Pods/Pods.xcodeproj'

unless File.exist?(project_path)
  puts "❌ Fichier projet non trouvé: #{project_path}"
  puts "💡 Usage: ruby remove_verify_module_ruby.rb [chemin_vers_projet.xcodeproj]"
  exit 1
end

puts "🔧 Ouverture du projet Xcode: #{project_path}"

begin
  project = Xcodeproj::Project.open(project_path)
  
  removed_count = 0
  
  project.targets.each do |target|
    next unless target.name == 'sqflite_darwin'
    
    puts "📁 Target trouvé: #{target.name}"
    
    # Chercher les phases shell script qui contiennent modules-verifier
    phases_to_remove = []
    
    target.build_phases.each do |phase|
      if phase.is_a?(Xcodeproj::Project::Object::PBXShellScriptBuildPhase)
        script = phase.shell_script || ''
        if script.include?('modules-verifier') || script.include?('VerifyModule')
          phases_to_remove << phase
          puts "   ✅ Phase trouvée: #{phase.name || 'Run Script'}"
        end
      end
    end
    
    # Supprimer les phases trouvées
    phases_to_remove.each do |phase|
      target.build_phases.delete(phase)
      removed_count += 1
      puts "   ✅ Phase supprimée"
    end
    
    # Forcer aussi les settings
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_MODULE_VERIFIER'] = 'NO'
      config.build_settings['CLANG_ENABLE_MODULE_DEBUGGING'] = 'NO'
    end
    puts "   ✅ Settings mis à jour"
  end
  
  if removed_count > 0
    project.save
    puts ""
    puts "✅ #{removed_count} phase(s) VerifyModule supprimée(s)"
    puts "✅ Projet sauvegardé"
  else
    puts ""
    puts "ℹ️  Aucune phase VerifyModule trouvée pour sqflite_darwin"
    puts "   (Elle a peut-être déjà été supprimée)"
  end
  
rescue LoadError => e
  puts "❌ Erreur: Gem xcodeproj non installée"
  puts "💡 Installez-la avec: gem install xcodeproj"
  puts "   Ou utilisez: sudo gem install xcodeproj"
  exit 1
rescue => e
  puts "❌ Erreur: #{e.message}"
  puts "   #{e.backtrace.first}"
  exit 1
end

