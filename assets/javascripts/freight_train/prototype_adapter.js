FT.Adapters.Prototype = {
  
  // Traversal
  find: function(parent_or_selector, selector) {
    return selector ? $(parent_or_selector).select(selector) : $$(parent_or_selector);
  },
  next: function(element, selector) {
    return $(element).next(selector);
  },
  previous: function(element, selector) {
    return $(element).previous(selector);
  },
  
  // Attributes
  attr: function(element, name, value) {
    if(value) {
      $(element).writeAttribute(name, value);
    } else {  
      return $(element).readAttribute(name);
    }
  },
  serialize: function(form) {
    return $(form).serialize();
  },
  
  // Events
  on: function(element, event_name, callback) {
    $(element).observe(event_name, callback);
  },
  stop: function(event) {
    Event.stop(event);
  },
  
  // CSS
  addClass: function(element, class_name) {
    $(element).addClassName(class_name);
  },
  hasClass: function(element, class_name) {
    return $(element).hasClassName(class_name);
  },
  removeClass: function(element, class_name) {
    $(element).removeClassName(class_name);
  },
  
  // Ajax
  xhr: function(url, method, params, args) {
    args = args || {};
    args.asynchronous = true;
    args.evalScripts = true;
    args.method = method;
    args.parameters = params;
    new Ajax.Request(url, args);
  }
}
