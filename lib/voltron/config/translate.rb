module Voltron
  class Config

    def translate
      @translate ||= Translate.new
    end

    class Translate

      attr_accessor :build_environment, :enabled, :locales

      def initialize
        @build_environment ||= [:development]
        @enabled ||= true
        @locales ||= I18n.available_locales
      end

      def enabled?
        enabled == true
      end

      def buildable?
        Array.wrap(build_environment).map(&:to_s).include?(Rails.env.to_s)
      end
    end
  end
end