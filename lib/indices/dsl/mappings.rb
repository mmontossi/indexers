module Indices
  module Dsl
    class Mappings < Api

      def properties(*names)
        @parent[:properties] ||= {}
        names.each do |name|
          @parent[:properties][name] = Indices.configuration.mappings[name]
        end
      end

    end
  end
end
