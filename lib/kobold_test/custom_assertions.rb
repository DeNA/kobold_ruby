module TestHelpers::CustomAssertions
  include ComparisonHelper
  
  def assert_compare(expected, actual, options={})
    result = compare(expected, actual, options)
    if result != :match
      expected_result, actual_result = result
      flunk("Expected: #{expected_result} but got: #{actual_result}")
    end
  end
end
