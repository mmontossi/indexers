require 'test_helper'

class RecordTest < ActiveSupport::TestCase

  test 'indexing' do
    shop = Shop.create(name: 'Andertons')
    wait
    assert_equal 1, Shop.search('and').count

    shop.update name: "Musician's Friend"
    wait
    assert_equal 1, Shop.search('mus').count

    shop.destroy
    assert_equal 0, Shop.search('').count
  end

end
