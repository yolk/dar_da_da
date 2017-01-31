require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DarDaDa::ActionControllerExtension, "extended Base" do
  it "should define only_if_{user}_is_allowed_to_{right} methods" do
    expect(ApplicationController.private_instance_methods.map(&:to_s)).to include("check_if_user_is_allowed_to_cancel_account")
    User.create!(:role => :user)
    expect {
      ApplicationController.new.send(:check_if_user_is_allowed_to_cancel_account)
    }.to raise_error(ActionController::ForbiddenError)
  end

  it "should define only_if_user_is_allowed_to class method" do
    expect(ApplicationController.methods.map(&:to_s)).to include("require_right")
    expect(ApplicationController).to receive(:before_action).with(:check_if_user_is_allowed_to_read_acticles, :only => [:index])
    ApplicationController.require_right(:read_acticles, :only => [:index])
  end
end
