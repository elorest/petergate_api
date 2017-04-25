require 'api_user'

class Api::BaseController < ActionController::Base
  def current_user
    @user ||= begin
                if request.headers["Authorization"] 
                  # you might want to check redis or memcache to for cache invalidation
                  ::ApiUser.new(request.headers["Authorization"])
                else
                  nil
                end
              end
  end

  helper_method :current_user
end
