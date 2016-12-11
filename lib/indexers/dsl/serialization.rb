module Indexers
  module Dsl
    class Serialization < Api
      include Traitable

      def extract(record, *names)
        names.each do |name|
          send name, record.send(name)
        end
      end

      def transliterate(value)
        ActiveSupport::Inflector.transliterate value
      end

    end
  end
end
