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
    element.observe('click',function(event) {

      // close any existing editors
      InlineEditor.close();

      // before_init callback
      // TODO: can return false to cancel the edit?
      observer.fire('before_init', element);

      // TODO: Configuration of the form is a FreightTrain concern; move that out of here (into before_init?)
      // TODO: In that case 'url' is not a required parameter!
      var form = element.up('.freight_train'); if(!form) return;
      form.onsubmit = function() {
        FT.xhr(url, 'put', Form.serialize(form));
        return false;
      };

      // Get properties
      //var id = element.readAttribute('id');
      
      // Create editor
      var editor = editor_writer(element); if(!editor) return;	

      // Hide the view-only element
      element.hide();
      
      // Insert the editor
      element.insert({'after':editor});
      
      // TODO: This call is important so that hitting 'enter' doesn't submit the CREATE form; resolve this differently...
      FT.submit_forms_on_enter(editor);

      // after_init callback
      observer.fire('after_init', [element, editor]);

      // Set the current row being edited
      // CURRENT_ROW_ID = id;
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
    /*
    if(CURRENT_ROW_ID) {
      var id = CURRENT_ROW_ID;
      var e;
      //e = $('extra_row'); 	if(e) e.remove();
      e = $('edit_row');  	if(e) e.remove();
      e = $(id);          	if(e) e.show();
      //e = $('edit_errors'); if(e) e.hide();
      e = $('error');       if(e) e.hide();
      CURRENT_ROW_ID = null;
    }
    */
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