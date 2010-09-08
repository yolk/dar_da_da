require 'rubygems'
require 'rspec'

require 'active_support'
require 'active_record'
require 'action_controller'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'dar_da_da'

# Spec::Runner.configure do |config|
#   
# end

ActiveRecord::Base.logger = Logger.new('/tmp/dar_da_da.log')
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => '/tmp/dar_da_da.sqlite')
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :users, :force => true do |table|
    table.string :name
    table.string :role_name
  end
end


# Purely useful for test cases...
class User < ActiveRecord::Base
  define_roles do
    role :admin do
      based_on :author
      is_allowed_to :cancel_account
    end
    
    role :author do
      based_on :user
      is_allowed_to :write_acticles
    end
    
    role :user, :default => true do
      is_allowed_to :read_acticles
    end
  end
end

class ApplicationController < ActionController::Base
  
  define_access_control User
  
  private
  
  def current_user
    User.first
  end
  
end
