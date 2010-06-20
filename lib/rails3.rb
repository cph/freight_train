# FreightTrain was written to take advantage of the new features of Rails 3.
# However it can also be used with other versions of Rails. This file contains
# the adapters and backports that create that compatibility.


# If Rails 3's Responder is not defined use a backport:
# in this case, git://github.com/boblail/rails3_responder.git
require 'mime_responds' unless defined?(ActionController::Responder)


module SafeHtmlHelper
  def raw(html)
    html
  end
  def raw_or_concat(html)
    concat html
  end
end


# What is a reasonable way of checking to see if this needs to be included?
ActionView::Base.send :include, SafeHtmlHelper if Rails::VERSION::STRING.match /^[12]/