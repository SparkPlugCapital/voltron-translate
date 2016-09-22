require "voltron"

module Voltron
  module Translate
    class Railtie < Rails::Railtie
      initializer "voltron.translate.initialize" do
        ::ActionController::Base.send :include, ::Voltron::Translate
        ::ActiveRecord::Base.send :include, ::Voltron::Translate
        ::ActionView::Base.send :include, ::Voltron::Translate
      end
    end
  end
end