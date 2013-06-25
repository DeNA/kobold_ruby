module TestHelpers::CustomAssertions

  # if options includes :message => "xxx", that is stripped out
  # of the options passed to the compare, and is then prepended
  # to the standard message emitted upon failure.
  def assert_deep_compare(expected, actual, options={})
    msg = options.delete(:message)
    result = ComparisonHelper::compare(expected, actual, options)
    if result != :match
      expected_result, actual_result = result
      flunk("#{msg}Expected: #{expected_result} but got: #{actual_result}")
    end
  end

  module_function :assert_deep_compare
end
