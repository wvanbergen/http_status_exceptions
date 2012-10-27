require 'rack/utils'
require 'action_controller'

# The HTTPStatus module is the core of the http_status_exceptions gem and
# contains all functionality.
#
# The module contains <tt>HTTPStatus::Base</tt> class, which is used as a
# superclass for every HTTPStatus exception. Subclasses, like
# <tt>HTTPStatus::Forbidden</tt> or <tt>HTTPStatus::NotFound</tt> will be
# generated on demand by the <tt>HTTPStatus.const_missing</tt> method.
#
# Moreover, it contains methods to handle these exceptions and integrate this
# functionality into <tt>ActionController::Base</tt>. When this module is in
# included in the <tt>ActionController::Base</tt> class, it will call
# <tt>rescue_from</tt> on it to handle all <tt>HTTPStatus::Base</tt>
# exceptions with the <tt>HTTPStatus#http_status_exceptions</tt> method.
#
# The exception handler will try to render a response with the correct
# HTTPStatus. When no suitable template is found to render the exception with,
# it will simply respond with an empty HTTP status code.
module HTTPStatus

  # The current gem release version. Do not set this value by hand, it will
  # be done automatically by them gem release script.
  VERSION = "0.3.0"

  # The Base HTTP status exception class is used as superclass for every
  # exception class that is constructed. It implements some shared
  # functionality for finding the status code and determining the template
  # path to render.
  #
  # Subclasses of this class will be generated on demand when a non-exisiting
  # constant of the <tt>HTTPStatus</tt> module is requested. This is
  # implemented in the <tt>HTTPStatus.const_missing</tt> method.
  class Base < StandardError

    # The path from which the error documents are loaded.
    cattr_accessor :template_path
    @@template_path = 'shared/http_status'

    # The layout in which the error documents are rendered
    cattr_accessor :template_layout
    @@template_layout = nil # Use the standard layout template setting by default.

    attr_reader :details

    # Initializes the exception instance.
    # <tt>message</tt>:: The exception message.
    # <tt>details</tt>:: An object with details about the exception.
    def initialize(message = nil, details = nil)
      @details = details
      super(message)
    end

    # Returns the HTTP status symbol corresponding to this class. This is one
    # of the symbols that can be found in the map that can be found in
    # <tt>ActionController::StatusCodes</tt>.
    #
    # This method should be overridden by subclasses, as it returns
    # <tt>:internal_server_error</tt> by default. This is done automatically
    # when a new exception class is being generated by
    # <tt>HTTPStatus.const_missing</tt>.
    def self.status
      :internal_server_error
    end

    # Returns the HTTP status symbol (as defined by Rails) corresponding to
    # this instance. By default, it calls the class method of the same name.
    def status
      self.class.status
    end

    # The numeric status code corresponding to this exception class. Uses the
    # status symbol to code map in <tt>ActionController::StatusCodes</tt>.
    def self.status_code
      Rack::Utils::SYMBOL_TO_STATUS_CODE[self.status]
    end

    # The numeric status code corresponding to this exception. By default, it
    # calls the class method of the same name.
    def status_code
      self.class.status_code
    end

    # The name of the template that should be used as error page for this
    # exception class.
    def self.template
      "#{template_path}/#{status}"
    end

    # The name of the template that should be used as error page for this
    # exception. By default, it calls the class method of the same name.
    def template
      self.class.template
    end
  end

  # Generates a <tt>HTTPStatus::Base</tt> subclass on demand based on the
  # constant name. The constant name should correspond to one of the status
  # symbols defined in <tt>ActionController::StatusCodes</tt>. The function
  # will raise an exception if the constant name cannot be mapped onto one of
  # the status symbols.
  #
  # This method will create a new subclass of <tt>HTTPStatus::Base</tt> and
  # overrides the status class method of the class to return the correct
  # status symbol.
  #
  # <tt>const</tt>:: The name of the missing constant, for which an exception
  # class should be generated.
  def self.const_missing(const)
    status_symbol = const.to_s.underscore.to_sym
    raise "Unrecognized HTTP Status name!" unless Rack::Utils::SYMBOL_TO_STATUS_CODE.has_key?(status_symbol)
    klass = Class.new(HTTPStatus::Base)
    klass.cattr_accessor(:status)
    klass.status = status_symbol
    const_set(const, klass)
    return const_get(const)
  end

  module ControllerAddition
    # This function will install a rescue_from handler for HTTPStatus::Base
    # exceptions in the class in which this module is included.
    #
    # <tt>base</tt>:: The class in which the module is included. Should be
    # <tt>ActionController::Base</tt> during the initialization of the gem.
    def self.included(base)
      base.send(:rescue_from, HTTPStatus::Base, :with => :http_status_exception)
    end

    # The default handler for raised HTTP status exceptions. It will render a
    # template if available, or respond with an empty response with the HTTP
    # status corresponding to the exception.
    #
    # You can override this method in your <tt>ApplicationController</tt> to
    # handle the exceptions yourself.
    #
    # <tt>exception</tt>:: The HTTP status exception to handle.
    def http_status_exception(exception)
      @exception = exception
      render_options = {:template => exception.template, :status => exception.status}
      render_options[:layout] = exception.template_layout if exception.template_layout
      render(render_options)
    rescue ActionView::MissingTemplate
      head(exception.status)
    end
  end
end

# Include the HTTPStatus module into <tt>ActionController::Base</tt> to enable
# the <tt>http_status_exception</tt> exception handler.
ActionController::Base.send(:include, HTTPStatus::ControllerAddition)
