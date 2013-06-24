require 'kobold'
require 'kobold/hash_helper'
require 'kobold_test/custom_assertions'
require 'ruby-debug'

class HashHelperTest < Test::Unit::TestCase
  def test_flatten_nested_hash
    nested_hash = {:api_version => 1,
                   :item => {:sku => "my_item",
                             :value => 100,
                             :product => {:app_key => "rolando",
                                          :publisher_id => 1}}}

    flattened_hash = HashHelper::flatten(nested_hash)

    expected_flattened_hash = {:api_version => 1,
                               :item_sku => "my_item",
                               :item_value => 100,
                               :item_product_app_key => "rolando",
                               :item_product_publisher_id => 1}

    TestHelpers::CustomAssertions::assert_deep_compare(expected_flattened_hash, flattened_hash)
  end

  def test_flatten_hash_with_list
    nested_hash = {:api_version => 1,
                   :items => [{:sku => "my_item",
                               :product => {:app_key => "rolando"}},
                              {:sku => "my_item2",
                               :product => {:app_key => "rolando"}}]}

    flattened_hash = HashHelper::flatten(nested_hash)

    expected_flattened_hash = {:api_version => 1,
                               "items_0_sku" => "my_item",
                               "items_0_product_app_key" => "rolando",
                               "items_1_sku" => "my_item2",
                               "items_1_product_app_key" => "rolando"}

    TestHelpers::CustomAssertions::assert_deep_compare(expected_flattened_hash, flattened_hash)
  end

  def test_preserve_existing_keys
    nested_hash = {:item_version => 1,
                   :item => {:version => 2}}

    flattened_hash = HashHelper::flatten(nested_hash)

    #Verify: The hash has an item_version and an _item_version
    #        One of these is 1, the other is 2 (we don't know which
    #        is which because hashes are unordered
    assert Set.new(flattened_hash.values) == Set.new([1, 2])
  end
end

