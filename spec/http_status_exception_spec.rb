require File.dirname(__FILE__) + '/spec_helper'

describe 'HTTPStatus#http_status_exception' do
  before(:each) { @controller = Class.new(ActionController::Base).new }
  after(:each)  { HTTPStatus::Base.template_layout = nil}
  
  it "should respond to the :http_status_exception method" do
    @controller.should respond_to(:http_status_exception)
  end
  
  ['NotFound', 'Forbidden', 'PaymentRequired'].each do |status_class|
    status_symbol = status_class.underscore.downcase.to_sym
    
    it "should create the HTTPStatus::#{status_class} class" do
      HTTPStatus.const_defined?(status_class).should be_true
    end
    
    it "should create a subclass of HTTPStatus::Base for the #{status_class.underscore.humanize.downcase} status" do
      HTTPStatus.const_get(status_class).ancestors.should include(HTTPStatus::Base)
    end
    
    it "should call render with the correct #{status_class.underscore.humanize.downcase} view and correct HTTP status" do
      @controller.should_receive(:render).with(hash_including(
            :status => status_symbol, 
            :template => "shared/http_status/#{status_symbol}"))

      @controller.http_status_exception(HTTPStatus.const_get(status_class).new('test'))
    end

    it "should not call render with a layout by default" do
      @controller.should_not_receive(:render).with(hash_including(:layout => 'testing'))
      @controller.http_status_exception(HTTPStatus.const_get(status_class).new('test'))
    end

    it "should call render with a layout set when this property is set on the exception class" do
      @controller.should_receive(:render).with(hash_including(:layout => 'testing'))
      HTTPStatus::Base.template_layout = 'testing'
      @controller.http_status_exception(HTTPStatus.const_get(status_class).new('test'))
    end    
  end
end

describe HTTPStatus::Base do
  before(:each) do
    @status_exception_class = Class.new(HTTPStatus::Base)
    @status_exception_class.stub!(:name).and_return('HTTPStatus::TestingStatus')
    @status_exception = @status_exception_class.new('Testing the base exception class')
  end
  
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

