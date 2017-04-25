require 'jwt'

class ApiUser
  JWT_SECRET = "$ecr3t_tok3n!"

  def initialize(token)
    @jwt = JWT.decode(token, JWT_SECRET, true, {algorithm: 'HS256'}).first
    @jwt.each do |k, v|
      v = v.map(&:to_sym) if v.is_a?(Array)
      define_singleton_method(k){v}
    end
  end

  def method_missing(sym, *args, &block)
    @user ||= (User.find(id) || User.first)
    return @user.send(sym, *args, &block)
  end

  def self.create_token(user)
    payload = {id: user.id, name: user.name, roles: user.roles, email: user.email}
    JWT.encode(payload, JWT_SECRET, 'HS256')
  end
end
