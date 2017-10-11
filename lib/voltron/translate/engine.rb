module Voltron
  module Translate
    class Engine < Rails::Engine

      isolate_namespace Voltron

      initializer 'voltron.translate.initialize' do
        ::ActiveRecord::Base.send :extend, ::Voltron::Translatable
        ::String.send :include, ::Voltron::Translate
      end
    end
  end
end