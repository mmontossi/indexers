module Indexes
  module Dsl
    class Serializer < Api

      def set(object, *names)
        names.each do |name|
          send name, object.send(name)
        end
      end

      def transliterate(value)
        ActiveSupport::Inflector.transliterate value
      end

    end
  end
end
