module TestHelpers::CustomAssertions
  def assert_deep_compare(expected, actual, options={})
    result = ComparisonHelper::compare(expected, actual, options)
    if result != :match
      expected_result, actual_result = result
      flunk("Expected: #{expected_result} but got: #{actual_result}")
    end
  end

  module_function :assert_deep_compare
end
