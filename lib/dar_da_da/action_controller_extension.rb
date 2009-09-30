module DarDaDa
  module ActionControllerExtension
    def self.included(base)
      base.extend(ClassMethods)
      unless defined?(ActionController::ForbiddenError)
        base.class_eval "class ::ActionController::ForbiddenError < ::ActionController::ActionControllerError;end"
      end
    end
    
    module ClassMethods      
      def define_access_control(user_class, user_method_name = :current_user)
        user_class.dar_dar_da.all_rights.each do |right|
          self.class_eval("
            private
            
            def check_if_#{user_class.name.downcase}_is_allowed_to_#{right}
              raise ActionController::ForbiddenError.new unless #{user_method_name}.allowed_to_#{right}?
            end
          ")
          
          self.class_eval("
            def self.require_right(right, options={})
              before_filter :\"check_if_#{user_class.name.downcase}_is_allowed_to_#\{right}\", options
            end
          ")
        end
      end
    end
  end
end