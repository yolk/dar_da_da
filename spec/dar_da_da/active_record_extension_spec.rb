require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DarDaDa::ActiveRecordExtension, "extended Model" do
  before { @user = User.create! }
  
  it "should set role to default_role" do
    @user.role.should eql(:user)
    User.new.role.should eql(:user)
  end
  
  it "should add role accessor to map role_attribute" do
    @user.role = :author
    @user.role.should eql(:author)
    @user.role = :unknown_role
    @user.role.should eql(:author)
    @user.save!
    @user.role.should eql(:author)
    @user.update_attributes!(:role => 'user')
    @user.role.should eql(:user)
  end
  
  it "should set default_role to user" do
    User.dar_da_da_config.options[:default_role].should == (:"user")
  end
  
  it "should prevent saving role_attribute with nil or empty" do
    @user.role_name = ""
    @user.send(:read_role_attribute).should be_blank
    @user.save!
    @user.reload
    @user.send(:read_role_attribute).should eql("user")
    @user.role_name.should eql("user")
    @user.role.should eql(:user)
  end
  
  it "should prevent saving role_attribute with not exisiting role" do
    @user.role_name = "unknown"
    @user.send(:read_role_attribute).should eql("unknown")
    @user.save!
    @user.reload
    @user.send(:read_role_attribute).should eql("user")
    @user.role_name.should eql("user")
    @user.role.should eql(:user)
  end
  
  it "should add is_{role}? methods" do
    @user.should be_is_user
    @user.role = :author
    @user.should be_is_author
    @user.role = :admin
    @user.should be_is_admin
  end
  
  it "should add allowed_to? method" do
    @user.allowed_to?(:read_acticles).should be_true
    @user.allowed_to?(:write_acticles).should be_false
    @user.allowed_to?(:cancel_account).should be_false
    @user.allowed_to?(:do_unknown_stuff).should be_false
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
end