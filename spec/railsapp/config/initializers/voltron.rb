Voltron.setup do |config|

  # === Voltron Translate Configuration ===

  # Whether or not translation is enabled
  # config.translate.enabled = true

  # Which locales to build translation files for
  config.translate.locales = Rails.application.config.i18n.available_locales

  # In what environments can translation generation occur. Recommended to keep this as development (default)
  # config.translate.build_environment << :development

  # === Voltron Base Configuration ===

  # Whether to enable debug output in the browser console and terminal window
  # config.debug = false

  # The base url of the site. Used by various voltron-* gems to correctly build urls
  # config.base_url = "http://localhost:3000"

  # What logger calls to Voltron.log should use
  # config.logger = Logger.new(Rails.root.join("log", "voltron.log"))

end