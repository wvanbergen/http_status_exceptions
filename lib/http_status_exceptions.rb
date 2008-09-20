module HTTPStatus
  
  class Base < Exception
    attr_accessor :status
    
    cattr_reader :template_path
    @@template_path = 'shared/http_status'
    
    def initialize(message)
      @status = self.class.to_s.split("::").last.underscore.to_sym
      super(message)
    end
    
    def status_code
      ActionController::StatusCodes::SYMBOL_TO_STATUS_CODE[@status]
    end
    
    def template
      "#{@@template_path}/#{@status_code}"
    end
  end
  
  def self.included(base)
    # create all the classed
    ActionController::StatusCodes::STATUS_CODES.each do |code, name|
      const_set("#{name.to_s.gsub(/[^A-z]/, '').camelize}", Class.new(HTTPStatus::Base))
    end
    
    base.send(:rescue_from, HTTPStatus::Base, :with => :http_status_exception)
  end

  # The default handler for raised HTTP status exceptions
  def http_status_exception(exception)
    @exception = exception
    begin
      render(:template => exception.template, :status => exception.status)
    rescue ActionView::MissingTemplate
      head(exception.status)
    end
  end
end

ActionController::Base.send(:include, HTTPStatus)