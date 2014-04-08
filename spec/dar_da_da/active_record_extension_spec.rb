require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DarDaDa::ActiveRecordExtension, "extended Model" do
  before { @user = User.create! }

  it "should set role to default_role" do
    @user.role.should eql("user")
    User.new.role.should eql("user")
  end

  it "should add role accessor to map role_attribute" do
    @user.role = :author
    @user.role.should eql("author")
    @user.role = :unknown_role
    @user.role.should eql("author")
    @user.save!
    @user.role.should eql("author")
    @user.update_attributes!(:role => 'user')
    @user.role.should eql("user")
  end

  it "should set default_role to user" do
    User.dar_dar_da.options[:default_role].should == (:"user")
  end

  it "should prevent saving role_attribute with nil or empty" do
    @user.role_name = ""
    @user.send(:read_role_attribute).should be_blank
    @user.save!
    @user.reload
    @user.send(:read_role_attribute).should eql("user")
    @user.role_name.should eql("user")
    @user.role.should eql("user")
  end

  it "should prevent saving role_attribute with not exisiting role" do
    @user.role_name = "unknown"
    @user.send(:read_role_attribute).should eql("unknown")
    @user.save!
    @user.reload
    @user.send(:read_role_attribute).should eql("user")
    @user.role_name.should eql("user")
    @user.role.should eql("user")
  end

  it "should add {role}? methods" do
    @user.should be_user
    @user.role = :author
    @user.should be_author
    @user.role = :admin
    @user.should be_admin
  end

  it "should add allowed_to? method" do
    @user.allowed_to?(:read_acticles).should be_true
    @user.allowed_to?("read_acticles").should be_true
    @user.allowed_to?(:write_acticles).should be_false
    @user.allowed_to?(:cancel_account).should be_false
    @user.allowed_to?(:do_unknown_stuff).should be_false
    @user.allowed_to?("").should be_false
    @user.allowed_to?(nil).should be_false
  end

  it "should add allowed_to_{right}? methods" do
    @user.should be_allowed_to_read_acticles
    @user.should_not be_allowed_to_write_acticles
    @user.should_not be_allowed_to_cancel_account
    @user.role = :author
    @user.should be_allowed_to_read_acticles
    @user.should be_allowed_to_write_acticles
    @user.should_not be_allowed_to_cancel_account
    @user.role = :admin
    @user.should be_allowed_to_read_acticles
    @user.should be_allowed_to_write_acticles
    @user.should be_allowed_to_cancel_account
  end

  it "should add named_scope for every role" do
    User.destroy_all
    User.create!(:role => "admin")
    2.times { User.create!(:role => :author) }
    3.times { User.create!(:role => :user) }
    User.admins.map(&:role).should eql(["admin"])
    User.authors.map(&:role).should eql(["author", "author"])
    User.users.map(&:role).should eql(["user", "user", "user"])
  end
end