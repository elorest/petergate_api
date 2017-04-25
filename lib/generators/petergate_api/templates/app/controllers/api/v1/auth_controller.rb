class Api::V1::AuthController < Api::BaseController
  access all: {except: [:destroy]}, user: :all 

  api :POST, '/v1/auth', "Login:\n\nLogs user in and creates auth token.\nReturned token should be included in Header as (Authorization: 'a29192kj3j2k39etc'})"
  param :email, String, desc: "email", required: true
  param :password, String, desc: "password", required: true
  example "
  {
    'id': 10,
    'auth_token': 'exampletokenofrandomness',
    'email': 'example@example.com'
  }"
  def create
    if params[:email] && (@user = User.find_by_email(params[:email])) && @user.valid_password?(auth_params[:password])
      connection = @user.api_connections.create
      render json: {id: @user.id, auth_token: connection.token, email: @user.email}.to_json, status: :ok
    else
      render status: :unauthorized, nothing: true
    end
  end

  api :DELETE, "/v1/auth", "Logout"
  def destroy
    @connection.destroy 
    render status: :ok, json: {message: "connection destroyed"}
  end

  api :POST, "/v1/forgot_password"
  param :email, String, required: true
  def forgot_password
    user = User.find_by_email(params[:email])
    user.set_mobile_reset_token!
    render json: {note: "this token is provided for test purposes", token: user.mobile_reset_token}
  end

  api :POST, "/v1/change_password"
  # TODO: allow authorized user with a valid session to change password. 'token' should not be a required field in this case
  param :token, String, desc: "Token will be sent by email when forgot password is called. (for beta purposes it will also be returned by /forgot_password.)", required: true
  param :password, String, required: true
  param :password_confirmation, String, required: true
  def change_password 
    user = User.find_by(mobile_reset_token: params[:token])
    if user && user.update(password: params[:password], password_confirmation: params[:password_confirmation], mobile_reset_token: nil)
      render status: :ok, json: {message: "Password Changed"}
    else
      render json: {error: "Incorrect token or missmatched password"}, status: :unprocessable_entity
    end
  end

  private
  def auth_params
    params.permit(:email, :password, :password_confirmation)
  end
end

