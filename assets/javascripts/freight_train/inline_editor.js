// FT.InlineEditor
// =========================================================================================================
// Replaces an element with an editable version of itself
//
// Usage:
//   new FT.InlineEditor(url, element, editor_writer)
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

var FT=window.FT||{};
FT.InlineEditor = (function() {
  var CURRENT_ELEMENT = null;
  var CURRENT_EDITOR = null;
  var observer = new Observer();
  var _$;
  
  var KEY_BACKSPACE =  8,
      KEY_TAB       =  9,
      KEY_RETURN    = 13,
      KEY_ESC       = 27,
      KEY_LEFT      = 37,
      KEY_UP        = 38,
      KEY_RIGHT     = 39,
      KEY_DOWN      = 40,
      KEY_DELETE    = 46,
      KEY_HOME      = 36,
      KEY_END       = 35,
      KEY_PAGEUP    = 33,
      KEY_PAGEDOWN  = 34,
      KEY_INSERT    = 45;
  
  var constructor = function(url, element, editor_writer) {
    if(!element) { return; }
    
    _$ = _$ || (function() {
      var a = FT.adapter();
      a.loaded(function() { // Close InlineEditors when the ESC key is pressed
        a.on(document.body, 'keydown', function(e) {
          (e.keyCode == KEY_ESC) && window.FT.InlineEditor.close();
        });
      });
      return a;
    })();
    
    if(!_$) { throw new 'FT.adapter() is not defined!' }
    
    element.edit_inline = function() {
      
      var FT=window.FT;
      
      // close any existing editors
      window.FT.InlineEditor.close();
      
      // before_init callback
      // TODO: can return false to cancel the edit?
      observer.fire('before_init', element);
      
      // Create editor
      var editor = editor_writer(element); if(!editor) {return;}
      editor.id = 'edit_row';
      
      // Hide the view-only element
      _$.addClass(element, 'in-edit');
      
      // Insert the editor
      _$.insert_after(element, editor);
      
      // Save the contents of the editor...
      editor.save = function(callback) {
        var form = _$.up(editor, 'form');
        if(form) {
          var params = _$.serialize(form);
          FT.xhr(url, 'put', params, {
            onSuccess: function() {
              (CURRENT_EDITOR == editor) && window.FT.InlineEditor.close();
            },
            onComplete: function(response) {
              (response.status != 400) && callback && callback();
            }
          });
        }
      }
      
      // ...on clicking a submit button
      var submits = _$.find(editor, 'button[name="submit"]');
      for(var i=0, ii=submits.length; i<ii; i++) {
        _$.on(submits[i], 'click', function(e) {
          _$.stop(e);
          editor.save();
        });
      }
      
      // ...or on hitting the Return key
      _$.on(editor, 'keydown', function(e) {
        var target = _$.target(e);
        if(target && _$.is_in(target, '.chosen-with-drop, .select2-container')) return;
        if(e.keyCode == KEY_RETURN) {
          _$.stop(e);
          editor.save();
        }
        if(e.keyCode == KEY_UP) {
          observer.fire('up', [e, element, editor]);
        }
        if(e.keyCode == KEY_DOWN) {
          observer.fire('down', [e, element, editor]);
        }
      });
      
      // after_init callback
      observer.fire('after_init', [element, editor]);
      
      // Finally, select the first Form element in the editor
      FT.selectFirstFieldIn(editor);
      
      // Remember the row being edited
      CURRENT_ELEMENT = element;
      CURRENT_EDITOR = editor;
    }
    
    // Edit the row when it is clicked (but not if a link or button was clicked)
    _$.on(element, 'click', function(e) {
      var target = _$.target(e);
      target && !_$.is_in(target, 'input, button, a, dd.dotWrap') && element.edit_inline();
    });
  };
  
  constructor.close = function() {
    if(CURRENT_ELEMENT || CURRENT_EDITOR) {
      observer.fire('close', [CURRENT_ELEMENT, CURRENT_EDITOR]);
      CURRENT_ELEMENT && _$.removeClass(CURRENT_ELEMENT, 'in-edit');
      CURRENT_EDITOR  && CURRENT_EDITOR.parentNode && CURRENT_EDITOR.parentNode.removeChild(CURRENT_EDITOR);
      CURRENT_ELEMENT = null;
      CURRENT_EDITOR  = null;
    }
  };
  constructor.observe = function(name,func){ observer.observe(name, func); };
  constructor.unobserve = function(name,func){ observer.unobserve(name, func); };

  return constructor;
})();
