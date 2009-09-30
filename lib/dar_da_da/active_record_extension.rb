module DarDaDa
  module ActiveRecordExtension
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    def self.decorate(base, config)
      base.send :include, DarDaDa::ActiveRecordExtension::InstanceMethods
      
      config.each do |name, role|
        base.class_eval("
          def #{name}?
            role == :#{name}
          end
          
          named_scope :#{name.to_s.pluralize}, 
                      :conditions => \"#{base.table_name}.#{config.options[:role_attribute]} = '#{name}'\"
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
        returning(self.dar_dar_da ||= DarDaDa::Config.new(options)) do |config|
          config.reopen(&block)
          DarDaDa::ActiveRecordExtension.decorate(self, config)
        end
      end
      
      def dar_dar_da=(config)
        write_inheritable_attribute(:dar_dar_da, config)
      end
      
      def dar_dar_da
        read_inheritable_attribute(:dar_dar_da)
      end
    end
    
    module InstanceMethods
      def self.included(base)
        base.send :before_save, :set_role_to_default_value
      end
      
      def role
        return self.class.dar_dar_da.options[:default_role] if read_role_attribute.blank?
        read_role_attribute.to_sym
      end
      
      def role=(new_role)
        write_role_attribute(new_role) if self.class.dar_dar_da[new_role]
      end
      
      def allowed_to?(name)
        rights = self.class.dar_dar_da[role]
        !!rights && !name.blank? && rights.include?(name.to_sym)
      end
      
      private
      
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