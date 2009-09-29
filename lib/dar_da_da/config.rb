module DarDaDa
  class Config < Hash
    def initialize(options={}, &block)
      @options = DarDaDa.config.merge(options)
      @all_rights, @first_added_role_name = [], nil
      reopen(&block)
    end
    
    def reopen(&block)
      instance_eval(&block) if block_given?
      finalize
    end
    
    attr_reader :options, :all_rights
    
    def role(name, options={}, &block)
      name = name.to_sym
      @options[:default_role] = name if options[:default]
      @first_added_role_name = name if empty?
      self[name] ||= DarDaDa::Role.new(name)
      self[name].instance_eval(&block) if block_given?
    end
    
    def [](role_name)
      role_name = role_name.to_sym unless role_name.blank?
      super(role_name)
    end
    
    def finalize
      # Merge rights between roles
      each do |name, role|
        role.merge_rights do |role_name|
          self[role_name]
        end
      end
      
      # Check if default_role exists
      # and delete it if it does not
      options.delete(:default_role) unless self[options[:default_role]]
      
      # Set default role to first added 
      # if not specified
      options[:default_role] = @first_added_role_name unless options[:default_role]
      
      # Finalize roles
      each{|name, role| role.finalize}
      
      # Collect and unify all_rights
      @all_rights = map do |role|
        role[1].to_a
      end
      @all_rights.flatten!
      @all_rights.uniq!
    end
  end
end