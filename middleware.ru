require "rack/runtime"
require "rack/auth/basic"

use Rack::Runtime
use Rack::Auth::Basic do |username, password|
  username == "admin" && password == "admin"
end

class App
  def call(env)
    [
      200,
      { "content-type" => "text/plain" },
      ["hello"]
    ]
  end
end

class Middleware
  def initialize(app, name)
    @app = app
    @name = name
  end

  def call(env)
    status, headers, body = @app.call(env)
    headers["hello"] = @name
    [status, headers, body]
  end
end

use Middleware, "rails"
run App.new
