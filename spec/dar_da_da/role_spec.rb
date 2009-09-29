require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DarDaDa::Role do
  
  before do
    @role = DarDaDa::Role.new(:role1)
  end
  
  it "should require name as attribute" do
    lambda { DarDaDa::Role.new }.should raise_error(ArgumentError)
    DarDaDa::Role.new(:role1).name.should eql(:role1)
  end
  
  it "should store name as symbol" do
    DarDaDa::Role.new("role1").name.should eql(:role1)
  end
  
  it "should be empty array" do
    @role.should eql([])
  end
  
  it "should convert strings to symbols when adding" do
    @role << :r1
    @role.should eql([:r1])
    @role << "r2"
    @role.should eql([:r1, :r2])
  end
  
  it "should have include?/memeber? methods that convert strings to symbols" do
    @role << :manage_projects
    @role.include?(:manage_projects).should be_true
    @role.include?("manage_projects").should be_true
    @role.include?("manage_users").should be_false
    @role.member?(:manage_projects).should be_true
    @role.member?("manage_projects").should be_true
    @role.member?("manage_users").should be_false
  end
  
  describe "is_allowed_to" do
    it "should add new instance to rights" do
      @role.is_allowed_to :manage_projects
      @role.should eql([:manage_projects])
    end
    
    it "should convert strings to symbols" do
      @role.is_allowed_to "manage_projects"
      @role.should eql([:manage_projects])
    end
  
    it "should allow adding multiple rights at once" do
      @role.is_allowed_to :manage_projects, :cancel_account
      @role.should eql([:manage_projects, :cancel_account])
    end
  end
  
  describe "based_on" do
    it "should add new instance to merge_rights_from" do
      role = DarDaDa::Role.new(:admin)
      role.based_on "author"
      role.merge_rights_from.should eql([:author])
    end
    
    it "should allow adding multiple roles at once" do
      role = DarDaDa::Role.new(:role1)
      role.based_on :author, "user"
      role.merge_rights_from.should == ([:author, :user])
    end
  end
end