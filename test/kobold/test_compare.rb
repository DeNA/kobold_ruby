require 'ruby-debug'
require 'ruby_misc_helpers'
require 'test-unit'

class UnorderedListCompareTest < Test::Unit::TestCase
  def test_reordered_lists_are_equal
    result = ComparisonHelper::compare([1, 2, 3], [3, 2, 1], :ordered => false)   
    assert_equal(:match, result)
  end

  def test_lists_with_different_members_are_not_equal
    result = ComparisonHelper::compare([1, 2, 3], [3, 4, 1], :ordered => false)   
    assert_equal([['_', 2, '_'], ['_', 4, '_']], result)
  end

  def test_repeated_members
    result = ComparisonHelper::compare([2, 2], [2, 2], :ordered => false)
    assert_equal(:match, result)
  end

  def test_repeated_members_compared_with_shorter_list
    result = ComparisonHelper::compare([2, 2], [2], :ordered => false)
    assert_equal([['_', 2], ['_']], result)
  end

  def test_repeated_members_compared_with_longer_list
    result = ComparisonHelper::compare([2, 2], [2, 2, 2], :ordered => false)
    assert_equal([['_', '_'], ['_', '_', 2]], result)
  end
end

class OrderedListCompareTest < Test::Unit::TestCase
  def test_same_lists_are_equal
    result = ComparisonHelper::compare([1, 2, 3], [1, 2, 3], :ordered => true)
    assert_equal(:match, result)
  end

  def test_different_lists_are_not_equal
    result = ComparisonHelper::compare([1, 2, 3], [1, 4, 3], :ordered => true)
    assert_equal([['_', 2, '_'], ['_', 4, '_']], result)
  end
end

class AllKeysHashCompareTest < Test::Unit::TestCase
  def test_empty_hashes_are_equal
    result = ComparisonHelper::compare({}, {})
    assert_equal(:match, result)
  end

  def test_identical_hashes_are_equal
    result = ComparisonHelper::compare({:a => 1}, {:a => 1})
    assert_equal(:match, result)
  end

  def test_unequal_hashes
    result = ComparisonHelper::compare({:a => 1}, {:a => 2})
    assert_equal([{:a => 1}, {:a => 2}], result)
  end

  def test_dontcares
    result = ComparisonHelper::compare({:a => :dontcare}, {:a => "some_complicated_value"})
    assert_equal(:match, result)
  end

  def test_equivalent_nested_hashes
    expected = {:a => {:b => "string"}}
    actual = {:a => {:b => "string"}}
    result = ComparisonHelper::compare(expected, actual)
    assert_equal(:match, result)
  end
end

