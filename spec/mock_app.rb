# frozen_string_literal: true

require 'rack'

class MockApp
  attr_accessor :cookie_count, :response_mimetype, :verbose, :streaming_response
  attr_reader :last_environ

  def initialize
    @cookie_count = 3
    @response_mimetype = 'text/plain'
    @verbose = false
    @streaming_response = false
  end

  def call(environ)
    @last_environ = environ

    response = Rack::Response.new
    if @streaming_response
      response_body = StreamingResponse.new
    else # Enumerated response
      response.write('Hello World ☃!')
      response_body = response.body
    end
    response.set_header('Content-Type', @response_mimetype)

    cookies = [
      %w[CUSTOMER WILE_E_COYOTE],
      %w[PART_NUMBER ROCKET_LAUNCHER_0002],
      %w[LOT_NUMBER 42]
    ]

    @cookie_count.times do |i|
      response.set_cookie(cookies[i][0], cookies[i][1])
    end

    environ['rack.errors'].puts 'application debug #1' if @verbose

    response.finish
    [response.status, response.headers, response_body]
  end

  private

  class StreamingResponse
    def call(stream)
      'Streamed Hello World ☃!'.chars do |char|
        stream << char
      end
    ensure
      stream.close
    end
  end
end
