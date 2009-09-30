require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DarDaDa::ActionControllerExtension, "extended Base" do
  it "should define only_if_{user}_is_allowed_to_{right} methods" do
    ApplicationController.private_instance_methods.map(&:to_s).should include("check_if_user_is_allowed_to_cancel_account")
    User.create!(:role => :user)
    lambda{ 
      ApplicationController.new.send(:check_if_user_is_allowed_to_cancel_account) 
    }.should raise_error(ActionController::ForbiddenError)
  end
  
  it "should define only_if_user_is_allowed_to class method" do
    ApplicationController.methods.map(&:to_s).should include("require_right")
    ApplicationController.should_receive(:before_filter).with(:check_if_user_read_acticles, :only => [:index])
    ApplicationController.require_right(:read_acticles, :only => [:index])
  end
end