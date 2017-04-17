module Voltron
  module Translate
    module Generators
      class InstallGenerator < Rails::Generators::Base

        source_root File.expand_path("../../../templates", __FILE__)

        desc 'Add Voltron Translate initializer'

        def inject_initializer

          voltron_initialzer_path = Rails.root.join('config', 'initializers', 'voltron.rb')

          unless File.exist? voltron_initialzer_path
            unless system("cd #{Rails.root.to_s} && rails generate voltron:install")
              puts 'Voltron initializer does not exist. Please ensure you have the \'voltron\' gem installed and run `rails g voltron:install` to create it'
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

  # Which locales to build translation files for. This setting also
  # determines the global default locales used with the `translates` class method
  # For example, if this is [:en, :es, :de], calling `translates :attribute` in a model
  # Will expose the methods `attribute_en`, `attribute_es`, and `attribute_de`
  # config.translate.locales = Rails.application.config.i18n.available_locales

  # In what environments can translation generation occur. Recommended to keep this as development (default)
  # config.translate.build_environment << :development
CONTENT
            end
          end
        end

        def copy_migrations
          copy_migration 'create_voltron_translations'
        end

        protected

          def copy_migration(filename)
            if migration_exists?(Rails.root.join('db', 'migrate'), filename)
              say_status('skipped', "Migration #{filename}.rb already exists")
            else
              copy_file "db/migrate/#{filename}.rb", Rails.root.join('db', 'migrate', "#{migration_number}_#{filename}.rb")
            end
          end

          def migration_exists?(dirname, filename)
            Dir.glob("#{dirname}/[0-9]*_*.rb").grep(/\d+_#{filename}.rb$/).first
          end

          def migration_id_exists?(dirname, id)
            Dir.glob("#{dirname}/#{id}*").length > 0
          end

          def migration_number
            @migration_number ||= Time.now.strftime('%Y%m%d%H%M%S').to_i

            while migration_id_exists?(Rails.root.join('db', 'migrate'), @migration_number) do
              @migration_number += 1
            end

            @migration_number
          end
      end
    end
  end
end