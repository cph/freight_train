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
var InlineEditor = (function(){
  var CURRENT_ELEMENT = null;
  var CURRENT_EDITOR = null;
  var observer = new Observer();

  var constructor = function(url, element, editor_writer) {
    element = $(element); if(!element) return;

    // if you click a row, switch to its editor
    // TODO: add selection of rows using up and down arrows and toggling of row with space or enter
    element.observe('click', function(event) {
      
      // Ignore if a link or button was clicked
      var tag = Event.findElement(event).tagName.toLowerCase();
      if($A(['input', 'button', 'a']).member(tag))
        return;

      // close any existing editors
      InlineEditor.close();

      // before_init callback
      // TODO: can return false to cancel the edit?
      observer.fire('before_init', element);

      // Create editor
      var editor = editor_writer(element); if(!editor) return;	

      // Hide the view-only element
      element.hide();
      
      // Insert the editor
      element.insert({'after':editor});
      
      // Save the contents of the editor...
      function save() {
        var params = Form.serialize(editor);
        FT.xhr(url, 'put', params);
      }

      // ...on clicking a submit button
      var submit = editor.down('*[type="submit"]');
      if(submit) {
        submit.observe('click', function(event) {
          Event.stop(event);
          save();
        });
      }
      
      // ...or on hitting the Return key
      editor.observe('keydown', function(event) {
        // window.console.log('kd: ' + event.which);
        if(event.keyCode == Event.KEY_RETURN) {
          Event.stop(event);
          save();
        }
      });
      
      // Finally, select the first Form element in the editor
      var first_input = editor.down('input, select, textarea');
      if(first_input) {
        first_input.focus();
      }

      // after_init callback
      observer.fire('after_init', [element, editor]);

      // Set the current row being edited
      CURRENT_ELEMENT = element;
      CURRENT_EDITOR = editor;
    });
  };

  // Class methods
  constructor.close = function() {
    if(CURRENT_ELEMENT || CURRENT_EDITOR) {
      observer.fire('close', [CURRENT_ELEMENT, CURRENT_EDITOR]);
      if(CURRENT_ELEMENT) CURRENT_ELEMENT.show();
      if(CURRENT_EDITOR)  CURRENT_EDITOR.remove();
      CURRENT_ELEMENT =   null;
      CURRENT_EDITOR =    null;
    }
  };
  constructor.observe = function(name,func){observer.observe(name,func);};
  constructor.unobserve = function(name,func){observer.unobserve(name,func);};

  // Listen for the escape key
  document.observe('dom:loaded', function() {
    document.observe('keyup', function(event) {
      //if(CURRENT_ROW_ID && (event.keyCode==Event.KEY_ESC))
      if(event.keyCode==Event.KEY_ESC)
        InlineEditor.close();
    });
  });

  return constructor;  
})();