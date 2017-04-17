module Voltron
  module Translate
    class Engine < Rails::Engine

      isolate_namespace Voltron

      initializer 'voltron.translate.initialize' do
        ::ActionController::Base.send :include, ::Voltron::Translate
        ::ActiveRecord::Base.send :include, ::Voltron::Translate
        ::ActiveRecord::Base.send :extend, ::Voltron::Translate
        ::ActiveRecord::Base.send :extend, ::Voltron::Translatable
        ::ActionView::Base.send :include, ::Voltron::Translate
        ::ActionMailer::Base.send :include, ::Voltron::Translate
      end
    end
  end
end