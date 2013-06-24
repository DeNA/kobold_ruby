module TestHelpers::Request
  include TestHelpers::Response

  def execute_http(http_method, action, options={})
    @parsed_body = nil
    @request.flash.keys.each {|k| @request.flash.delete(k)}
    defaults = {:params => {},
                :expected => {},
                :headers => {}}
    options = defaults.merge(options)

    set_headers(options[:headers])

    execute_function = method(http_method)
    execute_function.call(action, options[:params])

    parsed_body = parse_response_body(@response.code.to_i, @response.body, @response.headers)

    if !options[:skip_compare]
      assert_response_matches(:method => http_method,
                              :path => nil,
                              :expected => options[:expected],
                              :parsed_body => parsed_body,
                              :response_headers => @response.headers,
                              :response_code => @response.code.to_i,
                              :response_flash => @request.flash)
    end
    return parsed_body
  end

  def set_headers(headers)
    headers.each do |key, value|
      @request.env[key] = value
    end
  end
end
