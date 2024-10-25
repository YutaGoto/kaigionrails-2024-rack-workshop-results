class App
  def call(env)
    [
      200,
      { "Content-Type" => "text/plain" },
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
