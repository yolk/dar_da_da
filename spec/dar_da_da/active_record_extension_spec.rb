require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DarDaDa::ActiveRecordExtension, "extended Model" do
  before { @user = User.create! }

  it "should set role to default_role" do
    expect(@user.role).to eql("user")
    expect(User.new.role).to eql("user")
  end

  it "should add role accessor to map role_attribute" do
    @user.role = :author
    expect(@user.role).to eql("author")
    @user.role = :unknown_role
    expect(@user.role).to eql("author")
    @user.save!
    expect(@user.role).to eql("author")
    @user.update!(:role => 'user')
    expect(@user.role).to eql("user")
  end

  it "should set default_role to user" do
    expect(User.dar_dar_da.options[:default_role]).to eql :user
  end

  it "should prevent saving role_attribute with nil or empty" do
    @user.role_name = ""
    expect(@user.send(:read_role_attribute)).to be_blank
    @user.save!
    @user.reload
    expect(@user.send(:read_role_attribute)).to eql("user")
    expect(@user.role_name).to eql("user")
    expect(@user.role).to eql("user")
  end

  it "should prevent saving role_attribute with not exisiting role" do
    @user.role_name = "unknown"
    expect(@user.send(:read_role_attribute)).to eql("unknown")
    @user.save!
    @user.reload
    expect(@user.send(:read_role_attribute)).to eql("user")
    expect(@user.role_name).to eql("user")
    expect(@user.role).to eql("user")
  end

  it "should add {role}? methods" do
    expect(@user).to be_user
    @user.role = :author
    expect(@user).to be_author
    @user.role = :admin
    expect(@user).to be_admin
  end

  it "should add allowed_to? method" do
    expect(@user.allowed_to?(:read_acticles)).to be true
    expect(@user.allowed_to?("read_acticles")).to be true
    expect(@user.allowed_to?(:write_acticles)).to be false
    expect(@user.allowed_to?(:cancel_account)).to be false
    expect(@user.allowed_to?(:do_unknown_stuff)).to be false
    expect(@user.allowed_to?("")).to be false
    expect(@user.allowed_to?(nil)).to be false
  end

  it "should add allowed_to_{right}? methods" do
    expect(@user).to be_allowed_to_read_acticles
    expect(@user).to_not be_allowed_to_write_acticles
    expect(@user).to_not be_allowed_to_cancel_account
    @user.role = :author
    expect(@user).to be_allowed_to_read_acticles
    expect(@user).to be_allowed_to_write_acticles
    expect(@user).to_not be_allowed_to_cancel_account
    @user.role = :admin
    expect(@user).to be_allowed_to_read_acticles
    expect(@user).to be_allowed_to_write_acticles
    expect(@user).to be_allowed_to_cancel_account
  end

  it "should add named_scope for every role" do
    User.destroy_all
    User.create!(:role => "admin")
    2.times { User.create!(:role => :author) }
    3.times { User.create!(:role => :user) }
    expect(User.admins.map(&:role)).to eql(["admin"])
    expect(User.authors.map(&:role)).to eql(["author", "author"])
    expect(User.users.map(&:role)).to eql(["user", "user", "user"])
  end
end
