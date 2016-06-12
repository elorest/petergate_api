class Api::BaseController < ActionController::Base

  def current_user
    @user ||= begin
                if (@connection = Api::Connection.find_by(token: request.headers["Authorization"])).present?
                  @user = @connection.user
                else
                  nil 
                end
              end
  end

  def current_city
    @current_city ||= current_user.try(:city)
  end

  helper_method :current_user, :current_city
end
