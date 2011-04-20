FT.Adapters.jQuery = {
  attr: function(element, name, value) {
    return jQuery(element).attr(name, value);
  },
  find: function(parent_or_selector, selector) {
    return selector ? jQuery(parent_or_selector).find(selector) : jQuery(parent_or_selector);
  },
  serialize: function(form) {
    return jQuery(form).serialize();
  }
}
