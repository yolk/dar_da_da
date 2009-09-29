module DarDaDa
  class Role < Array
    def initialize(name)
      super()
      @name = name.to_sym
      @merge_rights_from = []
    end
    
    attr_reader :name, :merge_rights_from
    
    def <<(right)
      super(right.to_sym)
    end
    
    def include?(right)
      super(right.to_sym)
    end
    alias_method :member?, :include?
    
    def is_allowed_to(*names)
      concat(names.map(&:to_sym))
    end
    
    def based_on(*roles)
      roles.each do |role|
        merge_rights_from << role.to_sym
      end
    end
    
    def merge_rights(stack=[], &block)
      raise "You defined a circular reference when configuring DarDaDa with 'based_on'." if stack.include?(name)
      stack << name
      merge_rights_from.uniq.each do |role_name|
        next if role_name == name
        from = yield(role_name)
        is_allowed_to(*from.merge_rights(stack, &block)) if from
      end
      self
    end
    
    def finalize
      self.uniq!
    end
  end
end