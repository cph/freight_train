// InlineEditor
// =========================================================================================================
// Replaces an element with an editable version of itself
//
// Usage:
//   new InlineEditor(url, element, editor_writer)
//     url            the URL where edited materials will be posted to using the HTTP verb PUT
//     element        the HTML element which contains the information to be replaced with an inline editor
//     editor_writer  a function that creates an inline editor from the element
//
// Events:
//   after_init       passes the element to observers before the editor is created
//   before_init      passes the element and the editor to observers after the editor is created and added to the DOM
//   close            passes the element and the editor to observers just before the editor is hidden and the element restored
//
//
var InlineEditor = (function() {
  var CURRENT_ELEMENT = null;
  var CURRENT_EDITOR = null;
  var observer = new Observer();
  
  var constructor = function(url, element, editor_writer) {
    element = $(element); if(!element) return;
    
    element.edit_inline = function() {
      
      // close any existing editors
      InlineEditor.close();
      
      // before_init callback
      // TODO: can return false to cancel the edit?
      observer.fire('before_init', element);
      
      // Create editor
      var editor = editor_writer(element); if(!editor) {return}
      
      // Hide the view-only element
      // element.hide();
      element.addClassName('in-edit');
      
      // Insert the editor
      element.insert({'after':editor});
      
      // Save the contents of the editor...
      editor.save = function(callback) {
        // var params = Form.serialize(editor);
        var params = editor.up('form').serialize();
        FT.xhr(url, 'put', params, {
          onSuccess: function() {
            if(CURRENT_EDITOR == editor) { InlineEditor.close(); }
          },
          onComplete: function(response) {
            if((response.status != 400) && callback) {
              callback();
            }
          }
        });
      }
      
      // ...on clicking a submit button
      var submit = editor.down('*[type="submit"]');
      if(submit) {
        submit.observe('click', function(event) {
          Event.stop(event);
          editor.save();
        });
      }
      
      // ...or on hitting the Return key
      editor.observe('keydown', function(e) {
        // window.console.log('kd: ' + e.which);
        if(e.keyCode == Event.KEY_RETURN) {
          Event.stop(e);
          editor.save();
        }
        if(e.keyCode == Event.KEY_UP) {
          observer.fire('up', [e, element, editor]);
        }
        if(e.keyCode == Event.KEY_DOWN) {
          observer.fire('down', [e, element, editor]);
        }
      });
      
      // after_init callback
      observer.fire('after_init', [element, editor]);
      
      // Finally, select the first Form element in the editor
      var first_input = editor.down('input, select, textarea');
      try { if(first_input) { first_input.activate(); } } catch(e) {}
      
      // Remember the row being edited
      CURRENT_ELEMENT = element;
      CURRENT_EDITOR = editor;
    }
    
    // Edit the row when it is clicked
    element.observe('click', function(event) {
      
      // Ignore if a link or button was clicked
      if(!Event.findElement(event, 'input, button, a')) {
        element.edit_inline();
      }
    });
  };
  
  constructor.close = function() {
    if(CURRENT_ELEMENT || CURRENT_EDITOR) {
      observer.fire('close', [CURRENT_ELEMENT, CURRENT_EDITOR]);
      if(CURRENT_ELEMENT) CURRENT_ELEMENT.removeClassName('in-edit');
      if(CURRENT_EDITOR)  CURRENT_EDITOR.remove();
      CURRENT_ELEMENT     = null;
      CURRENT_EDITOR      = null;
    }
  };
  constructor.observe = function(name,func){ observer.observe(name, func); };
  constructor.unobserve = function(name,func){ observer.unobserve(name, func); };
  
  // Close InlineEditors when the ESC key is pressed
  document.observe('dom:loaded', function() {
    $(document.body).observe('keyup', function(event) {
      if(event.keyCode==Event.KEY_ESC) {
        InlineEditor.close();
      }
    });
  });
  
  return constructor;  
})();