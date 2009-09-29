require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe DarDaDa do
  it "should extend ActiveRecord::Base" do
    ActiveRecord::Base.public_methods(true).map(&:to_sym).should include(:dar_da_da)
  end
  
  it "should extend ActionController::Base" do
    ActionController::Base.public_methods(true).map(&:to_sym).should include(:dar_da_da)
  end
end
