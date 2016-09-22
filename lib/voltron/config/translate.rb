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
        @locales ||= [:en]
      end

      def enabled?
        enabled == true
      end

      def buildable?
        [build_environment].flatten.map(&:to_s).include?(Rails.env.to_s)
      end
    end
  end
end