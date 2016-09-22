module Voltron
	module Translate
		module Generators
			class InstallGenerator < Rails::Generators::Base

				desc "Add Voltron Translate initializer"

				def inject_initializer

					voltron_initialzer_path = Rails.root.join("config", "initializers", "voltron.rb")

					if File.exist? voltron_initialzer_path

						current_initiailzer = File.read voltron_initialzer_path

						unless current_initiailzer.match(Regexp.new(/^\s# === Voltron Translate Configuration ===\n/))
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
end