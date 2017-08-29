class ApplicationController < ActionController::Base
  include Auth0Helper
  protect_from_forgery with: :exception
end
