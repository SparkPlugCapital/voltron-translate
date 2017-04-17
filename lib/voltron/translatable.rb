module Voltron
  module Translatable

    def translates(*attributes)
      include InstanceMethods

      options = (attributes.extract_options!).with_indifferent_access
      locales = Array.wrap(options[:locales] || Voltron.config.translate.locales).map(&:to_s).map(&:underscore)

      attributes.each do |attribute|

        column = self.columns_hash[attribute.to_s]

        raise ::ActiveRecord::UnknownAttributeError.new(self.new, attribute) if column.nil?

        raise ::Voltron::Translate::InvalidColumnTypeError.new("Invalid type '#{column.type}' for attribute: #{attribute}. Translations only work on string and text attribute types.") unless [:string, :text].include?(column.type)

        # Override the attribute with a method that accepts a specific locale as an argument
        # If specified, will attempt to fetch that locale's translation, otherwise the default
        # locale specified for the attribute, and ultimately the current locale translation
        # If still nil, returns the value from super
        define_method :"#{attribute}" do |locale=nil|
          # +action_view/helpers/targs+ exist when this method is called from within
          # ActionView::Helpers. In other words, form helper tags. In that
          # case we want the actual value of the attribute, not whatever the locale is
          return super() if caller.any? { |l| /action_view\/helpers\/tags/.match(l) }
          try(:"#{attribute}_#{locale.to_s.underscore}") || try(:"#{attribute}_#{options[:default].to_s.underscore}") || try(:"#{attribute}_#{I18n.locale.to_s.underscore}") || super()
        end

        locales.each do |locale|

          # Define setter, i.e. - +attribute_es=+
          define_method :"#{attribute}_#{locale}=" do |val|
            attribute_will_change! "#{attribute}_#{locale}"
            instance_variable_set("@#{attribute}_#{locale}", val)
          end

          # Define getter, i.e - +attribute_es+
          # If nil, calling this method will attempt to fetch the value
          # We do this to avoid preloading the translations association records
          define_method :"#{attribute}_#{locale}" do
            if instance_variable_get("@#{attribute}_#{locale}").nil?
              instance_variable_set("@#{attribute}_#{locale}", send(:"#{attribute}_#{locale}_was"))
            end
            instance_variable_get("@#{attribute}_#{locale}")
          end

          # Define the changed? method, i.e. - +attribute_es_changed?+
          define_method :"#{attribute}_#{locale}_changed?" do
            changed.include?("#{attribute}_#{locale}")
          end

          # Define the was method, i.e. - +attribute_es_was+
          define_method :"#{attribute}_#{locale}_was" do
            translations.find_by(attribute_name: attribute, locale: locale).try(:translation)
          end

          define_method :"#{attribute}_#{locale}_will_change!" do
            attribute_will_change! "#{attribute}_#{locale}"
          end

          define_method :"#{attribute}_#{locale}?" do
            instance_variable_get("@#{attribute}_#{locale}").present?
          end

        end
      end

      # In case +translates+ was called multiple times, merge in the new attributes/locales
      # with the pre-existing ones
      all_attributes = @_translations.try(:keys) || []
      all_attributes += attributes
      all_attributes.uniq!

      all_locales = @_translations.try(:values) || []
      all_locales += locales
      all_locales.flatten!
      all_locales.uniq!

      has_many :translations, as: :resource, class_name: 'Voltron::Translation', dependent: :destroy

      before_save :build_translations

      accepts_nested_attributes_for :translations, reject_if: :all_blank, allow_destroy: true
      
      @_translations = all_attributes.map { |a| { a.to_s => all_locales } }.reduce(Hash.new, :merge)
    end

    module InstanceMethods

      # Before validation, iterate over all possible translation methods
      # and either update the corresponding translation record or build it,
      # so it can be saved when the parent record is saved
      def build_translations
        self.translations_attributes = translation_methods.map do |m, t|
          if send(:"#{m}_changed?")
            # Find the translation if it previously existed, or create new one
            translation = translations.where(attribute_name: t[:attribute], locale: t[:locale]).first || Voltron::Translation.new(attribute_name: t[:attribute], locale: t[:locale])
            # Set the translation text on our returned translation object
            translation.translation = instance_variable_get("@#{m}")
            # Return the attributes of our translation that will be assigned to self.translations_attributes
            translation.attributes
          end
        end.compact
      end

      private

        def translate_translations
          self.class.instance_variable_get('@_translations')
        end

        def translation_methods
          translate_translations.map do |attribute, locales|
            locales.map { |locale| { :"#{attribute}_#{locale}" => { attribute: attribute, locale: locale } } }
          end.flatten.reduce(Hash.new, :merge)
        end

    end
  end
end
