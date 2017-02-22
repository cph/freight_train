var FT=FT||{};
FT.Adapters=FT.Adapters||{};
FT.Adapters.jQuery = {
  
  // Load
  loaded: function(callback) {
    jQuery(callback);
  },
  
  // Attributes
  attr: function(element, name, value) {
    if(value === undefined) {
      return jQuery(element).attr(name);
    } else {
      jQuery(element).attr(name, value);
    }
  },
  css: function(element, css) {
    for(property in css) { jQuery(element).css(property, css[property]); }
  },
  addClass: function(element, class_name) {
    jQuery(element).addClass(class_name);
  },
  hasClass: function(element, class_name) {
    return jQuery(element).hasClass(class_name);
  },
  removeClass: function(element, class_name) {
    jQuery(element).removeClass(class_name);
  },
  text: function(element) {
    return jQuery(element).text();
  },
  
  // Selection/Traversal
  find_by_id: function(id) {
    return jQuery('#' + id)[0];
  },
  find: function(parent_or_selector, selector) {
    return selector ? jQuery(parent_or_selector).find(selector) : jQuery(parent_or_selector);
  },
  match: function(element, selector) {
    return jQuery(element).is(selector);
  },
  next: function(element, selector) {
    return jQuery(element).next(selector)[0];
  },
  previous: function(element, selector) {
    return jQuery(element).prev(selector)[0];
  },
  up: function(element, selector) {
    return jQuery(element).parents(selector)[0];
  },
  
  // Manipulation
  hide: function(element) {
    jQuery(element).hide();
  },
  show: function(element) {
    jQuery(element).show();
  },
  visible: function(element) {
    return jQuery(element).is(':visible');
  },
  clone: function(element) {
    return jQuery(element).clone()[0];
    // // IE copies events bound via attachEvent when
    // // using cloneNode. Calling detachEvent on the
    // // clone will also remove the events from the orignal
    // // In order to get around this, we use innerHTML.
    // var clone;
    // if(Prototype.Browser.IE) {
    //   clone = element.clone(false);
    //   clone.innerHTML = element.innerHTML;
    //   
    //   // innerHTML still copies all kinds of custom attributes over in IE.
    //   (function(element) {
    //     var attributes = element.attributes,
    //         children = element.childNodes;
    //     if(attributes) {
    //       for(var i=0, ii=attributes.length; i<ii; i++) {
    //         if(attributes[i]) {
    //           var attr = attributes[i].nodeName;
    //           if(('_prototypeUID' == attr) ||
    //              (/^jQuery/.test(attr))) {
    //             FT.debug('removing "' + attr + '"');
    //             element.removeAttribute(attr);
    //           }
    //         }
    //       }
    //     }
    //     if(children) {
    //       for(var i=0, ii=children.length; i<ii; i++) {
    //         arguments.callee(children[i]);
    //       }
    //     }
    //   })(clone);
    // } else {
    //   clone = element.cloneNode(true);
    // }
    // return clone;
  },
  insert_after: function(reference, element) {
    return jQuery(element).insertAfter(reference)[0];
  },
  prependTo: function(reference, html) {
    return jQuery(html).prependTo(reference)[0];
  },
  replace: function(element, html) {
    return jQuery(element).html(html)[0];
  },
  
  // Forms
  serialize: function(form) {
    var o = {};
    var a = jQuery(form).serializeArray();
    $.each(a, function() {
      if(o[this.name] && (this.name.substr(-2) == '[]')) {
        if(!o[this.name].push) {
          o[this.name] = [o[this.name]];
        }
        o[this.name].push(this.value || '');
      } else {
        o[this.name] = this.value || '';
      }
    });
    return o;
  },
  activate: function(element) {
    jQuery(element).focus();
  },
  assign: function(controls, value) {
    var $controls = jQuery(controls);
    if($controls.is(':radio')) {
      $controls.filter('[value="' + value + '"]').prop('checked', true);
    } else if($controls.is(':checkbox')) {
      $controls.attr('checked', (value == 'true') ? 'checked' : null);
    } else if($controls.prop('multiple')) {
      $controls.val(value.split(',')).trigger('change');
    } else {
      $controls.val(value).trigger('change');
    }
  },
  
  // Events
  delegate: function(parent, event_name, selector, callback) {
    jQuery(parent).delegate(selector, event_name, callback);
  },
  fire: function(element, event_name, args) {
    jQuery(element).trigger(event_name, args);
  },
  on: function(element, event_name, callback) {
    jQuery(element).bind(event_name, callback);
  },
  stop: function(event) {
    event.preventDefault();
    event.stopPropagation();
  },
  target: function(event) {
    return event.target;
  },
  
  // Ajax
  xhr: function(url, method, params, args) {
    var settings = args || {};
    settings.onSuccess && (settings.success = settings.onSuccess);
    settings.onComplete && (settings.complete = settings.onComplete);
    settings.data = params || {};
    settings.type = method.toUpperCase();
    if(settings.type == 'PUT' || settings.type == 'DELETE') {
      settings.data['_method'] = settings.type;
      settings.type = 'POST';
    }
    jQuery.ajax(url, settings);
  }
}
