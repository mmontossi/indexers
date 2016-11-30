module Indexes
  module Dsl
    class Serialization < Api

      def transliterate(value)
        ActiveSupport::Inflector.transliterate value
      end

    end
  end
end
