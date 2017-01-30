require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DarDaDa::Role do

  before do
    @role = DarDaDa::Role.new(:role1)
  end

  it "should require name as attribute" do
    expect { DarDaDa::Role.new }.to raise_error(ArgumentError)
    expect(DarDaDa::Role.new(:role1).name).to eql(:role1)
  end

  it "should store name as symbol" do
    expect(DarDaDa::Role.new("role1").name).to eql(:role1)
  end

  it "should be empty array" do
    expect(@role).to eql([])
  end

  it "should convert strings to symbols when adding" do
    @role << :r1
    expect(@role).to eql([:r1])
    @role << "r2"
    expect(@role).to eql([:r1, :r2])
  end

  it "should have include?/memeber? methods that convert strings to symbols" do
    @role << :manage_projects
    expect(@role.include?(:manage_projects)).to be true
    expect(@role.include?("manage_projects")).to be true
    expect(@role.include?("manage_users")).to be false
    expect(@role.member?(:manage_projects)).to be true
    expect(@role.member?("manage_projects")).to be true
    expect(@role.member?("manage_users")).to be false
  end

  describe "is_allowed_to" do
    it "should add new instance to rights" do
      @role.is_allowed_to :manage_projects
      expect(@role).to eql([:manage_projects])
    end

    it "should convert strings to symbols" do
      @role.is_allowed_to "manage_projects"
      expect(@role).to eql([:manage_projects])
    end

    it "should allow adding multiple rights at once" do
      @role.is_allowed_to :manage_projects, :cancel_account
      expect(@role).to eql([:manage_projects, :cancel_account])
    end
  end

  describe "based_on" do
    it "should add new instance to merge_rights_from" do
      role = DarDaDa::Role.new(:admin)
      role.based_on "author"
      expect(role.merge_rights_from).to eql([:author])
    end

    it "should allow adding multiple roles at once" do
      role = DarDaDa::Role.new(:role1)
      role.based_on :author, "user"
      expect(role.merge_rights_from).to eql([:author, :user])
    end
  end
end
