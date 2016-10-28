module Voltron
  module Translate
    module Generators
      class InstallGenerator < Rails::Generators::Base

        desc "Add Voltron Translate initializer"

        def inject_initializer

          voltron_initialzer_path = Rails.root.join("config", "initializers", "voltron.rb")

          unless File.exist? voltron_initialzer_path
            unless system("cd #{Rails.root.to_s} && rails generate voltron:install")
              puts "Voltron initializer does not exist. Please ensure you have the 'voltron' gem installed and run `rails g voltron:install` to create it"
              return false
            end
          end

          current_initiailzer = File.read voltron_initialzer_path

          unless current_initiailzer.match(Regexp.new(/# === Voltron Translate Configuration ===/))
            inject_into_file(voltron_initialzer_path, after: "Voltron.setup do |config|\n") do
<<-CONTENT

  # === Voltron Translate Configuration ===

  # Whether or not translation is enabled
  # config.translate.enabled = true

  # Which locales to build translation files for
  # config.translate.locales << :en

  # In what environments can translation generation occur. Recommended to keep this as development (default)
  # config.translate.build_environment << :development
CONTENT
            end
          end
        end
      end
    end
  end
end