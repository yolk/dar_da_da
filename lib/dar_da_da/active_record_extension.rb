module DarDaDa
  module ActiveRecordExtension
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def dar_da_da(options={}, &block)
        self.dar_da_da_config ||= DarDaDa::Config.new(options)
        dar_da_da_config.reopen(&block)
        dar_da_da_decorate
        dar_da_da_config
      end
      
      def dar_da_da_config=(config)
        write_inheritable_attribute(:dar_da_da_config, config)
      end
      
      def dar_da_da_config
        read_inheritable_attribute(:dar_da_da_config)
      end
      
      private
      
      def dar_da_da_decorate
        include(DarDaDa::ActiveRecordExtension::InstanceMethods)
        
        dar_da_da_config.each do |name, role|
          self.class_eval("
            def is_#{name}?
              role == :#{name}
            end
          ")
        end
        dar_da_da_config.all_rights.each do |right|
          self.class_eval("
            def allowed_to_#{right}?
              allowed_to?(:#{right})
            end
          ")
        end
      end
    end
    
    module InstanceMethods
      def self.included(base)
        base.send :before_save, :set_role_to_default_value
      end
      
      def role
        return self.class.dar_da_da_config.options[:default_role] if read_role_attribute.blank?
        read_role_attribute.to_sym
      end
      
      def role=(new_role)
        write_role_attribute(new_role) if self.class.dar_da_da_config[new_role]
      end
      
      def allowed_to?(name)
        (self.class.dar_da_da_config[role] || []).include?(name.to_sym)
      end
      
      private
      
      def read_role_attribute
        read_attribute(self.class.dar_da_da_config.options[:role_attribute])
      end
      
      def write_role_attribute(new_role)
        write_attribute(self.class.dar_da_da_config.options[:role_attribute], new_role.to_s)
      end
      
      def set_role_to_default_value
        unless self.class.dar_da_da_config[read_role_attribute]
          write_role_attribute(self.class.dar_da_da_config.options[:default_role])
        end
      end
    end
  end
end