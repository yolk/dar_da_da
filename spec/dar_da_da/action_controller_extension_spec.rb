require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DarDaDa::ActionControllerExtension, "extended Base" do
  it "should define only_if_{user}_is_allowed_to_{right} methods" do
    ApplicationController.private_instance_methods.map(&:to_s).should include("only_if_user_is_allowed_to_read_acticles")
    User.create!(:role => :user)
    lambda{ 
      ApplicationController.new.send(:only_if_user_is_allowed_to_cancel_account) 
    }.should raise_error(ActionController::ForbiddenError)
  end
  
  it "should define only_if_user_is_allowed_to class method" do
    ApplicationController.methods.map(&:to_s).should include("only_if_user_is_allowed_to")
    ApplicationController.should_receive(:before_filter).with(:only_if_user_is_allowed_to_read_acticles)
    ApplicationController.only_if_user_is_allowed_to(:only_if_user_is_allowed_to_read_acticles)
  end
end