require 'voltron'

module Voltron
  module Translate
    class Railtie < Rails::Railtie
      initializer 'voltron.translate.initialize' do
        ::ActionController::Base.send :include, ::Voltron::Translate
        ::ActiveRecord::Base.send :include, ::Voltron::Translate
        ::ActiveRecord::Base.send :extend, ::Voltron::Translate
        ::ActionView::Base.send :include, ::Voltron::Translate
        ::ActionMailer::Base.send :include, ::Voltron::Translate
      end
    end
  end
end