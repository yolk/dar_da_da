require 'dar_da_da/config'
require 'dar_da_da/role'
require 'dar_da_da/version'

module DarDaDa
  @@config = {:role_attribute => :role_name }
  mattr_accessor :config
end

require 'dar_da_da/active_record_extension'

ActiveSupport.on_load(:active_record) do
  include DarDaDa::ActiveRecordExtension
end

require 'dar_da_da/action_controller_extension'

ActiveSupport.on_load(:action_controller) do
  include DarDaDa::ActionControllerExtension
end
