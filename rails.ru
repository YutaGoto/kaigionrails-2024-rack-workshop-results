require "action_controller/railtie"

class App < Rails::Application
  config.secret_key_base = "secret"
  config.logger = Logger.new($stdout)
  Rails.logger = config.logger

  routes.draw do
    root to: "apps#index"
    resources :apps, only: [:show], path: "hello"
  end
end

class AppsController < ActionController::Base
  def index
    render plain: "It works!"
  end

  def show
    render plain: "Hello, #{params[:id]}!"
  end
end

run Rails.application
