require File.dirname(__FILE__) + '/spec_helper'

describe HTTPStatus::Base do
  before(:each) do
    @status_exception_class = Class.new(HTTPStatus::Base)
    @status_exception_class.stub!(:name).and_return('HTTPStatus::TestingStatus')
    @status_exception = @status_exception_class.new('Testing the base exception class')
  end
  
  after(:each) { HTTPStatus::Base.template_path = 'shared/http_status' }

  it "should set the status symbol bases on the class name" do
    @status_exception.status.should == :testing_status
  end
  
  it "should check ActionController's status code list for the status code based on the class name" do
    ActionController::StatusCodes::SYMBOL_TO_STATUS_CODE.should_receive(:[]).with(:testing_status)
    @status_exception.status_code
  end
  
  it "should use the HTTPStatus::Base.template_path setting to determine the error template" do
    HTTPStatus::Base.template_path = 'testing'
    @status_exception.template.should == 'testing/testing_status'
  end
end

# Run some tests for different valid subclasses.
{ 'NotFound' => 404, 'Forbidden' => 403, 'PaymentRequired' => 402, 'InternalServerError' => 500}.each do |status_class, status_code|

  describe "HTTPStatus::#{status_class}" do
    it "should generate the HTTPStatus::#{status_class} class successfully" do
      lambda { HTTPStatus.const_get(status_class) }.should_not raise_error
    end

    it "should create a subclass of HTTPStatus::Base for the #{status_class.underscore.humanize.downcase} status" do
      HTTPStatus.const_get(status_class).ancestors.should include(HTTPStatus::Base)
    end

    it "should return the correct status code (#{status_code})" do
      HTTPStatus.const_get(status_class).new.status_code.should == status_code
    end
  end
end

describe 'HTTPStatus#http_status_exception' do
  before(:each) { @controller = Class.new(ActionController::Base).new }
  after(:each)  { HTTPStatus::Base.template_layout = nil}
  
  it "should create the :http_status_exception method in ActionController" do
    @controller.should respond_to(:http_status_exception)
  end

  it "should call render with the correct view and correct HTTP status" do
    @controller.should_receive(:render).with(hash_including(
          :status => :base, :template => "shared/http_status/base"))

    @controller.http_status_exception(HTTPStatus::Base.new('test'))
  end

  it "should not call render with a layout by default" do
    @controller.should_not_receive(:render).with(hash_including(:layout => 'testing'))
    @controller.http_status_exception(HTTPStatus::Base.new('test'))
  end

  it "should call render with a layout set when this property is set on the exception class" do
    @controller.should_receive(:render).with(hash_including(:layout => 'testing'))
    HTTPStatus::Base.template_layout = 'testing'
    @controller.http_status_exception(HTTPStatus::Base.new('test'))
  end
end