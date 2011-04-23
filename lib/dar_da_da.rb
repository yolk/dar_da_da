require 'dar_da_da/config'
require 'dar_da_da/role'
require 'dar_da_da/version'

module DarDaDa
  @@config = {:role_attribute => :role_name }
  mattr_accessor :config
end

if defined? ActiveRecord::Base
  require 'dar_da_da/active_record_extension'
  ActiveRecord::Base.send(:include, DarDaDa::ActiveRecordExtension)
end

if defined? ActionController::Base
  require 'dar_da_da/action_controller_extension'
  ActionController::Base.send(:include, DarDaDa::ActionControllerExtension)
end