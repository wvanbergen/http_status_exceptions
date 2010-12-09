require 'spec_helper'

describe HTTPStatus::Base, 'class inheritance' do

  before do
    Rack::Utils::SYMBOL_TO_STATUS_CODE[:testing_status] = 9000 #.stub(:has_key?).with(:testing_status).and_return(true)
    @status_exception_class = HTTPStatus::TestingStatus
  end

  after do
    HTTPStatus::Base.template_path = 'shared/http_status'
    HTTPStatus.send :remove_const, 'TestingStatus'
  end

  it "should set the status symbol based on the class name" do
    @status_exception_class.status.should == :testing_status
  end

  it "should use 'shared/http_status' as default view path" do
    @status_exception_class.template.should == 'shared/http_status/testing_status'
  end

  it "should check ActionController's status code list for the status code based on the class name" do
    Rack::Utils::SYMBOL_TO_STATUS_CODE.should_receive(:[]).with(:testing_status)
    @status_exception_class.status_code
  end

  it "should use the HTTPStatus::Base.template_path setting to determine the error template" do
    HTTPStatus::Base.template_path = 'testing'
    @status_exception_class.template.should == 'testing/testing_status'
  end

  it "should raise an exception when the class name does not correspond to a HTTP status code" do
    lambda { HTTPStatus::Nonsense }.should raise_error
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

    it "should return the correct status code (#{status_code}) when using the class" do
      HTTPStatus.const_get(status_class).status_code.should == status_code
    end

    it "should return the correct status code (#{status_code}) when using the instance" do
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

  it "should call :http_status_exception when an exception is raised when handling the action" do
    
    ### TODO: fix this spec
    
    # Rescue from is now not handled by ActionController itself anymore, but by a piece of middleware
    # called ActionDispatch::Rescue
    # https://github.com/rails/rails/blob/master/actionpack/lib/action_dispatch/middleware/rescue.rb
    
    exception = HTTPStatus::Base.new('test')
    @controller.stub(:process_action, :test).and_raise(exception)
    @controller.should_receive(:http_status_exception).with(exception)
    @controller.send(:process_action, :test)
  end

  it "should call render with the correct view and correct HTTP status" do
    @controller.should_receive(:render).with(hash_including(
          :status => :internal_server_error, :template => "shared/http_status/internal_server_error"))

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

  it "should call head with the correct status code if render cannot found a template" do
    @controller.stub!(:render).and_raise(ActionView::MissingTemplate.new([], 'template.html.erb', {}, false))
    @controller.should_receive(:head).with(:internal_server_error)
    @controller.http_status_exception(HTTPStatus::Base.new('test'))
  end
end
