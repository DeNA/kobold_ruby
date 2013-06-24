module TestHelpers::Request
  include TestHelpers::Response

  def execute_http(http_method, path, options={})
    defaults = {:params => {},
                :expected => {},
                :headers => {},
                :browser => nil}
    options = defaults.merge(options)
    if options[:browser].nil?
      options[:browser] = Rack::Test::Session.new(Rack::MockSession.new(app || Sinatra::Application)) 
    end

    #set_headers(options[:headers])

    execute_function = options[:browser].method(http_method)
    execute_function.call(path, options[:params], options[:headers])
    response = options[:browser].last_response

    parsed_body = parse_response_body(response.status, response.body, response.headers)

    if !options[:skip_compare]
      assert_response_matches(:method => http_method, 
                              :path => path, 
                              :expected => options[:expected], 
                              :parsed_body => parsed_body,
                              :response_headers => response.headers,
                              :response_code => response.status)
    end
  end
end
