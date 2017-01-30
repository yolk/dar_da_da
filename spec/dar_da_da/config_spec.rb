require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DarDaDa::Config do

  it "should require nothing as attribute" do
    expect { DarDaDa::Config.new }.not_to raise_error
  end

  it "should be empty " do
    expect(DarDaDa::Config.new).to be_empty
  end

  it "should allow accessing role by string" do
    config = DarDaDa::Config.new do
      role :admin
    end
    expect(config["admin"]).to eql(config[:admin])
    config[nil]
    config[""]
  end

  describe "options" do
    it "should have role_attribute set to role_name default" do
      expect(DarDaDa::Config.new.options[:role_attribute]).to eql(:role_name)
    end

    it "should allow setting role_attribute via options" do
      expect(DarDaDa::Config.new(:role_attribute => :role).options[:role_attribute]).to eql(:role)
    end
  end

  it "should eval block inside instance" do
    expect { DarDaDa::Config.new do
      raise "config_error"
    end }.to raise_error("config_error")
  end

  describe "role" do

    it "should add new instance to roles" do
      config = DarDaDa::Config.new do
        role :admin
      end
      expect(config.keys).to eql([:admin])
    end

    it "should eval role-block inside role-instance" do
      expect { DarDaDa::Config.new do
        role :admin do
          raise name.to_s + "_deep_error"
        end
      end }.to raise_error("admin_deep_error")

      config = DarDaDa::Config.new do
        role :admin do
          is_allowed_to :manage_users
        end
      end

      expect(config).to eql ({:admin => [:manage_users]})
    end

    it "should eval role-block inside of exisiting role-instance" do
      config = DarDaDa::Config.new do
        role :admin do
          is_allowed_to :manage_users
        end

        role :admin do
          is_allowed_to :manage_projects
        end
      end

      expect(config).to eql ({:admin => [:manage_users, :manage_projects]})
    end

    it "should reopen existing config and eval block" do
      config = DarDaDa::Config.new
      config.reopen do
        role :admin
      end
      expect(config.keys).to eql([:admin])
    end

  end

  describe "default_role" do
    it "should have empty default_role" do
      expect(DarDaDa::Config.new.options[:default_role]).to be_nil
    end

    it "should set first added role to default_role by default" do
      config = DarDaDa::Config.new do
        role :admin
        role :author
      end
      expect(config.options[:default_role]).to eql(:admin)
    end

    it "should allow setting default_role while initalizing" do
      config = DarDaDa::Config.new :default_role => :admin do
        role :author
        role :admin
      end
      expect(config.options[:default_role]).to eql(:admin)
    end

    it "should remove nonexisiting roles after initalizing" do
      config = DarDaDa::Config.new :default_role => :admin do
      end
      expect(config.options[:default_role]).to be_nil
      config = DarDaDa::Config.new :default_role => :admin
      expect(config.options[:default_role]).to be_nil
    end

    it "should take first added role even when invalid other specified" do
      config = DarDaDa::Config.new :default_role => :admin do
        role :author
      end
      expect(config.options[:default_role]).to eql(:author)
    end

    it "should allow setting role to default_role when given" do
      config = DarDaDa::Config.new do
        role :admin
        role :author, :default => true
      end
      expect(config.options[:default_role]).to eql(:author)
    end
  end

  describe "all_rights" do
    it "should be empty by default" do
      expect(DarDaDa::Config.new.all_rights).to eql([])
    end

    it "should collect all rights" do
      config = DarDaDa::Config.new do
        role :admin do
          is_allowed_to :b, :a, :c
        end
        role :author do
          is_allowed_to :e
          is_allowed_to :d
        end
      end
      expect(config.all_rights).to include(:a, :b, :c, :d, :e)
      expect(config.all_rights.size).to eql([:a, :b, :c, :d, :e].size)
    end

    it "should remove duplicates" do
      config = DarDaDa::Config.new do
        role :admin do
          is_allowed_to :a, :b
        end
        role :author do
          is_allowed_to :b
          is_allowed_to :a
          is_allowed_to :c
        end
      end

      expect(config.all_rights).to include(:a, :b, :c)
      expect(config.all_rights.size).to eql([:a, :b, :c].size)
    end
  end

  describe "based_on" do
    it "should copy rights between roles" do
      config = DarDaDa::Config.new do

        role :author do
          based_on :user
          is_allowed_to :write_articles
        end

        role :user do
          is_allowed_to :read_articles
        end

        role :admin do
          based_on :author
          is_allowed_to :cancel_accounts
        end
      end

      expect(config[:admin]).to eql ([:cancel_accounts, :write_articles, :read_articles])
      expect(config[:author]).to eql ([:write_articles, :read_articles])
      expect(config[:user]).to eql ([:read_articles])
    end

    it "should throw error on circular references" do
      expect { config = DarDaDa::Config.new do

        role :author do
          based_on :user
          is_allowed_to :write_articles
        end

        role :user do
          based_on :admin
          is_allowed_to :read_articles
        end

        role :admin do
          based_on :author
          is_allowed_to :cancel_accounts
        end
      end }.to raise_error("You defined a circular reference when configuring DarDaDa with 'based_on'.")
    end
  end
end
