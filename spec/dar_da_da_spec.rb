require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe DarDaDa do
  it "should extend ActiveRecord::Base" do
    ActiveRecord::Base.public_methods(true).map(&:to_sym).should include(:define_roles)
  end
  
  it "should extend ActionController::Base" do
    ActionController::Base.public_methods(true).map(&:to_sym).should include(:define_access_control)
  end
end
