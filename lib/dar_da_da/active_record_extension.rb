require 'active_support/core_ext/class/attribute'

module DarDaDa
  module ActiveRecordExtension
    def self.included(base)
      base.class_attribute(:dar_dar_da, :instance_reader => false, :instance_writer => false)
      base.extend(ClassMethods)
    end
    
    def self.decorate(base, config)
      base.send :include, DarDaDa::ActiveRecordExtension::InstanceMethods
      
      config.each do |name, role|
        base.class_eval("
          def #{name}?
            role_symbol == :#{name}
          end
          
          scope :#{name.to_s.pluralize}, where(\"#{base.table_name}.#{config.options[:role_attribute]} = '#{name}'\")
        ")
      end
      config.all_rights.each do |right|
        base.class_eval("
          def allowed_to_#{right}?
            allowed_to?(:#{right})
          end
        ")
      end
    end
    
    module ClassMethods
      def define_roles(options={}, &block)
        (self.dar_dar_da ||= DarDaDa::Config.new(options)).tap do |config|
          config.reopen(&block)
          DarDaDa::ActiveRecordExtension.decorate(self, config)
        end
      end
    end
    
    module InstanceMethods
      def self.included(base)
        base.send :before_save, :set_role_to_default_value
      end
      
      def role
        role_symbol.to_s
      end
      
      def role=(new_role)
        write_role_attribute(new_role) if self.class.dar_dar_da[new_role]
      end
      
      def allowed_to?(name)
        rights = self.class.dar_dar_da[role]
        !!rights && !name.blank? && rights.include?(name.to_sym)
      end
      
      private
      
      def role_symbol
        role_attribute = read_role_attribute
        return self.class.dar_dar_da.options[:default_role] if role_attribute.blank?
        role_attribute.to_sym
      end
      
      def read_role_attribute
        read_attribute(self.class.dar_dar_da.options[:role_attribute])
      end
      
      def write_role_attribute(new_role)
        write_attribute(self.class.dar_dar_da.options[:role_attribute], new_role.to_s)
      end
      
      def set_role_to_default_value
        unless self.class.dar_dar_da[read_role_attribute]
          write_role_attribute(self.class.dar_dar_da.options[:default_role])
        end
      end
    end
  end
end