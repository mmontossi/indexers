module Indexers
  module Dsl
    class Mappings < Api

      def properties(*names)
        @parent[:properties] ||= {}
        names.each do |name|
          @parent[:properties][name] = Indexers.configuration.mappings[name]
        end
      end

    end
  end
end
