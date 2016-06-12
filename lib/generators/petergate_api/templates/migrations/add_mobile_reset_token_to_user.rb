class AddMobileResetTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :mobile_reset_token, :string, index: true
  end
end
