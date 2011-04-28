var FT=FT||{};
FT.Adapters=FT.Adapters||{};
FT.Adapters.Prototype = {
  
  // Traversal
  find: function(parent_or_selector, selector) {
    return (selector ? $(parent_or_selector).select(selector) : $$(parent_or_selector))||[];
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
  activate: function(element) {
    $(element).select();
  },
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
  visible: function(element) {
    return $(element).visible();
  },
  
  // Manipulation
  clone: function(element) {
    // IE copies events bound via attachEvent when
    // using cloneNode. Calling detachEvent on the
    // clone will also remove the events from the orignal
    // In order to get around this, we use innerHTML.
    var clone;
    if(Prototype.Browser.IE) {
      clone = element.clone(false);
      clone.innerHTML = element.innerHTML;
      
      // innerHTML still copies all kinds of custom attributes over in IE.
      (function(element) {
        var attributes = element.attributes,
            children = element.childNodes;
        if(attributes) {
          for(var i=0, ii=attributes.length; i<ii; i++) {
            if(attributes[i]) {
              var attr = attributes[i].nodeName;
              if(('_prototypeUID' == attr) ||
                 (/^jQuery/.test(attr))) {
                App.debug('removing "' + attr + '"');
                element.removeAttribute(attr);
              }
            }
          }
        }
        if(children) {
          for(var i=0, ii=children.length; i<ii; i++) {
            arguments.callee(children[i]);
          }
        }
      })(clone);
    } else {
      clone = element.cloneNode(true);
    }
    return clone;
  },
  
  // Events
  delegate: function(parent, event_name, selector, callback) {
    $(parent).observe(event_name, function(e) {
      if(e.element().match(selector)) {
        window.console.log([event_name, e.element(), selector]);
        callback(e);
      }
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
  hide: function(element) {
    $(element).hide();
  },
  show: function(element) {
    $(element).show();
  },
  css: function(element, css) {
    $(element).setStyle(css);
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
