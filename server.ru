require "socket"
require "logger"
require "rack/rewindable_input"

class App
  def call(env)
    if env["PATH_INFO"] == "/"
      [200, {"content-type" => "text/plain"}, ["Hello World"]]
    else
      [404, {"content-type" => "text/plain"}, ["Not Found"]]
    end
  end
end

class SimpleServer
  def self.run(app, **options)
    new(app, **options).start
  end

  def initialize(app, **options)
    @app = app
    @options = options
    @logger = Logger.new($stdout)
  end

  def start
    @logger.info "SimpleServer starting....."
    server = TCPServer.new(@options[:Port].to_i)
    headers = {}

    loop do
      client = server.accept
      request_line = client.gets&.chomp

      loop do
        line = client.gets&.chomp
        puts line
        break if line.empty?
        key, value = line.split(": ")
        headers[key] = value
      end

      path = request_line.split[1]

      env = {
        Rack::REQUEST_METHOD    => "GET",
        Rack::SCRIPT_NAME       => "",
        Rack::PATH_INFO         => path,
        Rack::SERVER_NAME       => @options[:Host],
        Rack::SERVER_PORT       => @options[:Port].to_s,
        Rack::SERVER_PROTOCOL   => "HTTP/1.1",
        Rack::RACK_INPUT        => Rack::RewindableInput.new(client),
        Rack::RACK_ERRORS       => $stderr,
        Rack::QUERY_STRING      => "",
        Rack::RACK_URL_SCHEME   => "http",
      }

      status, response_headers, body = @app.call(env)
      client.puts "HTTP/1.1 #{status} #{Rack::Utils::HTTP_STATUS_CODES[status]}"
      response_headers.each do |key, value|
        client.puts "#{key}: #{value}"
      end
      client.puts
      body.each do |chunk|
        client.write(chunk)
      end

      client.close
      @logger.info "GET #{path} => #{status}"
    end
  end
end

class FormServer
  def self.run(app, **options)
    new(app, **options).start
  end

  def initialize(app, **options)
    @app = app
    @options = options
    @logger = Logger.new($stdout)
  end

  def start
    @logger.info "FormServer starting....."
    server = TCPServer.new(@options[:Port].to_i)
    loop do
      client = server.accept
      fork do
        
      end
      client.close
    end
  end
end

Rackup::Handler.register("simple_server", SimpleServer)
run App.new
