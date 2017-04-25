require 'securerandom'

module PetergateApi
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.expand_path("../templates", __FILE__)
      class_option :orm

      desc "Sets up rails project for Petergate API"
      def self.next_migration_number(path)
        sleep 1
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end

      def add_to_gemfile
        gem "apipie-rails"
        gem "jwt"
      end

      def insert_into_user_model
        inject_into_file "app/models/user.rb", after: /^class\sUser < ActiveRecord::Base/ do
          <<-'RUBY'

  has_many :api_connections, class_name: "::Api::Connection"
  
  def set_mobile_reset_token!
    begin
      self.mobile_reset_token = Base64.strict_encode64(Devise.friendly_token + self.email).strip
    end while self.class.find_by(mobile_reset_token: self.mobile_reset_token).present?
    self.save
    self.mobile_reset_token
  end
 
          RUBY
        end
      end

      def copy_app
        run "cp -rf #{self.class.source_root}/app/ app/"
      end

      def copy_lib
        run "cp -rf #{self.class.source_root}/lib/ lib/"
      end

      def copy_initializers
        run "cp -rf #{self.class.source_root}/initializers config/"
      end

      def create_migrations
        Dir["#{self.class.source_root}/migrations/*.rb"].sort.each do |filepath|
          name = File.basename(filepath)
          migration_template "migrations/#{name}", "db/migrate/#{name}"
        end
      end
    end
  end
end
