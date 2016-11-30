Indexes.define :other, class_name: 'Shop' do

  mappings do
    properties :name
  end

  serialization do |record|
    name record.name
  end

  search do |*args|
    options = args.extract_options!
    term = args.first
    query do
      if term.present?
        match do
          name do
            query term
            type 'phrase_prefix'
          end
        end
      else
        match_all
      end
    end
  end

end
