module HTTPStatus
  
  # The Base HTTP status exception class is used as superclass for every
  # exception class that is constructed. It implements some shared functionality
  # for finding the status code and determining the template path to render.
  class Base < StandardError

    # The path from which the error documents are loaded.
    cattr_accessor :template_path
    @@template_path = 'shared/http_status'

    # The layout in which the error documents are rendered
    cattr_accessor :template_layout

    attr_reader :status, :details
    
    # Creates the exception with a message and some optional other info.
    def initialize(message = nil, details = nil)
      @status =  self.class.name.split("::").last.underscore.to_sym rescue :internal_server_error
      @details = details
      super(message)
    end
    
    # The numeric status code corresponding to this exception
    def status_code
      ActionController::StatusCodes::SYMBOL_TO_STATUS_CODE[@status]
    end
    
    # The name of the template that should be used as error page for this exception
    def template
      "#{@@template_path}/#{@status}"
    end
  end

  # Creates all the exception classes based on Rails's list of available status code and
  # registers the exception handler using the rescue_from method.
  def self.included(base)
    base.send(:rescue_from, HTTPStatus::Base, :with => :http_status_exception)
  end
  
  # Generates a HTTPStatus::Base subclass for every subclass that is found
  def self.const_missing(const)
    klass = Class.new(HTTPStatus::Base)
    const_set(const, klass)
    return const_get(const)
  end

  # The default handler for raised HTTP status exceptions. 
  # It will render a template if available, or respond with an empty response
  # with the HTTP status correspodning to the exception.
  def http_status_exception(exception)
    @exception = exception
    render_options = {:template => exception.template, :status => exception.status}
    render_options[:layout] = exception.template_layout if exception.template_layout
    render(render_options)
  rescue ActionView::MissingTemplate
    head(exception.status)
  end
end

# Include the HTTPStatus module into ActionController to enable its functionality
ActionController::Base.send(:include, HTTPStatus)