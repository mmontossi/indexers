module Indices
  module Pagination

    def total_pages
      @total_pages ||= [(total_count.to_f / page_length).ceil, 1].max
    end

    def previous_page
      @previous_page ||= (current_page > 1 ? (current_page - 1) : nil)
    end

    def next_page
      @next_page ||= (current_page < total_pages ? (current_page + 1) : nil)
    end

    def first_page
      1
    end

    def last_page
      total_pages
    end

    def out_of_bounds?
      @out_of_bounds ||= (current_page > total_pages || current_page < first_page)
    end

    def total_count
      @total_count ||= (response['hits']['total'].to_i - padding)
    end

  end
end
