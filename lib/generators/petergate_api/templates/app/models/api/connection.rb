class Api::Connection < ActiveRecord::Base
  belongs_to :user, class_name: "::User"
  before_create do
    self.token = ::ApiUser.create_token(user)
  end
end

