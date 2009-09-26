require File.dirname(__FILE__) + '/spec_helper'

describe 'HTTPStatus#http_status_exception' do
  before(:each) do
    @controller_class = Class.new(ActionController::Base)
    @controller       = @controller_class.new
  end
  
  it "should respond to the :http_status_exception method" do
    @controller.should respond_to(:http_status_exception)
  end
  
  ['NotFound', 'Forbidden', 'PaymentRequired'].each do |status_class|
    it "should create the HTTPStatus::#{status_class} class" do
      HTTPStatus.const_defined?(status_class).should be_true
    end
    
    it "should create a subclass of HTTPStatus::Base for the #{status_class.underscore.humanize.downcase} status" do
      HTTPStatus.const_get(status_class).ancestors.should include(HTTPStatus::Base)
    end
  end
end

describe HTTPStatus::Base do
  before(:each) { @status = HTTPStatus::Base.new }
  
  it "should set the status symbol bases on the class name" do
    @status.status.should == :base
  end
  
  it "should check ActionController's status code list for the status code based on the class name" do
    ActionController::StatusCodes::SYMBOL_TO_STATUS_CODE.should_receive(:[]).with(:base)
    @status.status_code
  end
  
  it "should use the HTTPStatus::Base.template_path setting to determine the error template" do
    HTTPStatus::Base.template_path = 'testing'
    @status.template.should == 'testing/base'
  end
end

