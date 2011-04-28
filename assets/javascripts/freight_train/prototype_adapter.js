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
  up: function(element, selector) {
    return $(element).up(selector);
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
  live: function(event_name, selector, callback) {
    $(document.body).observe(event_name, function(e) {
      e.element().match(selector) && callback(e);
    });
  },
  on: function(element, event_name, callback) {
    $(element).observe(event_name, callback);
  },
  stop: function(event) {
    Event.stop(event);
  },
  target: function(event) {
    return event.element();
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
  
  // Forms
  assign: function(control, value) {
    switch(control.nodeName.toUpperCase()) {
      case 'INPUT':
      case 'TEXTAREA':
        $(control).setValue(value);
        break;
        
      case 'SELECT':
        var options = control.options;
        var option;
        for(var i=0;i<options.length;i++) {
          option = options[i];
          if(option.value == value) {
            option.selected = true;
            return;
          }
        }
        break;
    }
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
