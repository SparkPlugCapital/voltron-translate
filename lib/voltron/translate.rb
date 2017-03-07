require 'voltron'
require 'voltron/translate/version'
require 'voltron/config/translate'
require 'digest'
require 'csv'
require 'google_hash'

module Voltron
  module Translate

    def __(text, locale = I18n.locale, **args)
      return (text % args) unless Voltron.config.translate.enabled?

      begin
        raise 'Locale can only contain the characters A-Z, and _' unless locale.to_s =~ /^[A-Z_]+$/i

        # If app is running in one of the environments where translations can be created
        if Voltron.config.translate.buildable?
          Voltron.config.translate.locales.each { |locale| translator(locale).write text }
        end

        # Translate the text and return it
        translator(locale).translate text, **args
      rescue => e
        # If any errors occurred, log the error and just return the default interpolated text
        Voltron.log e.message.to_s + " (Original Translation Text: #{text})", 'Translate', :light_red
        text % args
      end
    end

    def translator(locale = I18n.locale)
      @translators ||= {}
      @translators[locale.to_s] ||= Translation.new(locale)
    end

    class Translation

      attr_accessor :locale

      def initialize(locale)
        @locale = locale.to_s
      end

      def translate(text, **args)
        phrase(text, args) % args
      end

      def destroy
        File.unlink(path) if File.exists?(path)
        reload
      end

      def path
        @path ||= Rails.root.join('config', 'locales', "#{locale}.csv")
      end

      def write(text)
        # If the full list of translations does not contain the given text content, add it
        unless full_list.has_key?(text)
          CSV.open(path, 'a', force_quotes: true) { |f| f.puts [text, text] }
          Voltron.log "Added translation for text '#{text}' (Locale: #{locale})", 'Translate', :light_blue
        end
      end

      # Almost the same as full_list, but does not include translations whose from/to are identical,
      # since that would just be unnecessarily inflating the size of the hash
      def list
        reload if has_been_modified?
        @@list ||= begin
          hsh = ::GoogleHashDenseRubyToRuby.new
          data.each { |k,v| hsh[k] = v unless k == v }
          hsh
        end
      end

      # A google hash object representing the translation file, where the key is the original text,
      # and the value is the translated text
      def full_list
        reload if has_been_modified?
        @@full_list ||= begin
          hsh = ::GoogleHashDenseRubyToRuby.new
          data.each { |k,v| hsh[k] = v }
          hsh
        end
      end

      # The last time (in microseconds) the translation file was updated
      def last_modified
        Rails.cache.fetch("translations/data/modified/#{locale}") { modified }
      end

      private

        # The hash representation of the csv contents. Cannot be a google hash since google hash
        # objects cannot be stored in the cache. This data is reloaded anytime the csv file is modified
        def data
          Rails.cache.fetch("translations/data/#{locale}/#{modified}") do
            hsh = {}
            if File.exists?(path)
              CSV.foreach(path, force_quotes: true) do |row|
                hsh[row[0]] = row[1]
              end
            end
            hsh
          end
        end

        def phrase(text, args)
          key = phrase_key(text, args)
          Rails.cache.fetch(key) { list[text] || text }
        end

        def modified
          if File.exists? path
            File.mtime(path).strftime('%s%6N')
          else
            Time.now.strftime('%s%6N')
          end
        end

        # Reset the list and full list objects, so they are forced to load the new data
        def reload
          @@list = nil
          @@full_list = nil
        end

        def has_been_modified?
          is_modified = last_modified != modified

          if is_modified
            # Update last modified timestamp
            Rails.cache.write("translations/data/modified/#{locale}", modified)
          end

          is_modified
        end

        def phrase_key(text, args)
          key = Digest::SHA256.hexdigest text + args.map { |k,v| "#{k}#{v}" }.join
          "translations/phrase/#{key}/#{locale}/#{modified}"
        end
    end
  end
end

require 'voltron/translate/railtie' if defined?(Rails)