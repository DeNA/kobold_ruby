require 'json'

module TestHelpers::Response
  include TestHelpers::CustomAssertions
  include ComparisonHelper
  include RDouble

  class HttpResponseStub < RDouble::StubObject
  end

  def self.create_response_stub(options)
    defaults = {:code => 200,
                :body => ""}
    options = defaults.merge(options)
    return HttpResponseStub.new(options)
  end

  def create_response_stub(options)
    self.create_response_stub(options)
  end

  def parse_json_body(response_body)
    begin
      parsed_body = JSON.parse(response_body)
      parsed_body = HashHelper::symbolize_keys(parsed_body)
    rescue JSON::ParserError => e
      parsed_body = nil
    end
    return parsed_body
  end

  def parse_response_body(response_code, response_body, response_headers)
    content_type = response_headers["Content-Type"]
    if response_code.to_i == 302
      parsed_body = nil
    elsif content_type.nil?
      parsed_body = nil
    elsif content_type.match('/json')
      parsed_body = parse_json_body(response_body)
    elsif content_type.match('/html')
      parsed_body = nil
    elsif content_type.match('/csv')
      headers_present = content_type.match("header=present")
      parsed_body = CSV.parse(response_body, :headers => headers_present).map {|row| row.to_hash}
    elsif content_type.match('/xml')
      begin
        parsed_body = Hash.from_xml(response_body)
      rescue REXML::ParseException => e
        parsed_body = nil
      end
    else
      parsed_body = {:body => response_body}
    end
    return parsed_body
  end

  def assert_response_matches(options)
    #options
      #method
      #path
      #expected 
      #parsed_body and/or response_body
      #response_headers 
      #response_code 
      #response_flash (Optional, Rails only)
    
    if !options.key?(:parsed_body)
      options[:parsed_body] = parse_response_body(options[:response_code], options[:response_body], options[:response_headers])
    end

    response_code = options[:response_code]
    response_headers = options[:response_headers]

    #Flash is a Rails-only construct
    response_flash = options[:response_flash]

    expected_response = {}

    expected = options[:expected]
    if expected.key?(:code)
      expected_response[:code] = expected[:code]
    end
    actual_response = {:code => response_code}

    if expected.key?(:headers)
      expected_response[:headers] = expected[:headers]
      actual_response[:headers] = {}
      expected[:headers].keys.each do |key|
        actual_response[:headers][key] = response_headers[key]
      end
    end

    if options[:response_code] == 302 || expected[:redirect]
      if !expected.key?(:redirect)
        expected[:redirect] = :missing
      end

      expected_response[:redirect] = expected[:redirect]
      if expected[:redirect].kind_of?(Hash)
        parsed_url = URI(response_headers["Location"]) 
        url = "#{parsed_url.scheme}://#{parsed_url.host}#{parsed_url.path}"
        query_string = Hash[CGI.parse(parsed_url.query).symbolize_keys.map {|k, v| [k, v[0]]}]
        actual_response[:redirect] = {:url => url,
                                      :params => query_string}
      elsif
        actual_response[:redirect] = response_headers["Location"]
      end
    end

    if expected.key?(:flash) || (!response_flash.nil? && !response_flash.empty?)
      expected_response[:flash] = expected[:flash]
      actual_response[:flash] = response_flash
    end


    if expected.key?(:payload)
      expected_response[:payload] = expected[:payload]
    end

    if options[:parsed_body]
      actual_response[:payload] = options[:parsed_body]
    end

    type_compare = {}
    if expected[:compare].is_a?(Symbol)
      type_compare[:hash] = expected[:compare]
      type_compare[:list] = expected[:compare]
      type_compare[:ordered] = expected[:ordered]
    elsif expected[:compare].is_a?(Hash)
      type_compare = expected[:compare]
    end
      
    result = compare(expected_response, actual_response, type_compare)
    if result != :match
      expected_values, actual_values = result
      flunk("#{options[:http_method]} to #{options[:path]} should return #{expected_response} but returned #{actual_response}\n\n expected: \n#{expected_values} \nactual: \n#{actual_values}")
    end
  end
end
