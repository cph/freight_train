// FreightTrain Core
// =========================================================================================================
//
// Events raised from FT:
//   after_add_nested   raised after a nested item is created
//   after_reset_nested raised after a nested item is either created or destroyed
//   hookup             raised after FreightTrain forms are initialized (or reinitialized)
//   hookup_form        passed a form being initialized as a FreightTrain form
//   load               raised right after FreightTrain is initialized on dom:loaded
//
//
// Events raised from elements
//   ft:create          raised by an element that's just been created by FreightTrain
//   ft:delete          raised by an element that's just been deleted by FreightTrain
//   ft:update          raised by an element that's just been updated by FreightTrain
//
//
// For every FreightTrain instance created in a page, a namespace will be added to FT that is named after the model.
//
//   e.g. FT.Tag
//
//
// This namespace has one event that can be observed:
//   hookup_row         passes each row to observers: both when the page is loaded and when new rows are added dynamically
//
//
var FT = (function(){

  /* PRIVATE VARIABLES */
  var token = '';
  var enable_nested_records = true;
  var observer = new Observer();
  
  /* PRIVATE METHODS */
  var render_deleted = function(id) {
    // make the item non-responsive to clicks and remove its background color
    var e=$(id);
    if(e) {
      e.addClassName('deleted');
      e.removeClassName('editable');
      e.stopObserving('mouseover');
      
      // TODO: These next two lines exhibit too much knowledge of an implementation of 360's color selector
      e.select('.tag-color').each(function(tag) { tag.setStyle({'backgroundColor': ''}); });
      e.select('.tag-bubble').each(function(tag) { tag.setStyle({'backgroundColor': ''}); });
      e.select('input').each(function(i) {
        i.disabled = true;
      });
    }
  };
  var _hookup_row = function(model, row) {
    if(row.hasClassName('interactive')) FT.hover_row(row);
    model.hookup_row(row);
  };
  var set_add_command_on_click = function(form, add_row) {
    if(!form) throw new Error('form must not be null');
    add_row = add_row || form.down('#add_row');           if(!add_row) return;
    add_row.observe('click', function(click_event) {
      var element = click_event.element();
      if(element && (element.match('input[type="submit"]') || element.match('input[type="image"]'))) {
        //alert('submitting remotely; check');
        InlineEditor.close(); // Don't let values in inline editor override values in creator
        form.onsubmit = function(submit_event) {
          FT.xhr(form.action,'post',form.serialize());
          return false;
        };
      }
    });
  };
  
  /* */
  InlineEditor.observe('before_init',function(tr) {
    var e=$('error');
    if(e) e.hide();
  });
  
  document.observe('dom:loaded', function() {
    // need to wrap document.body in $() so that it works on IE
    $(document.body).observe('ft:destroy', function(event) {
      InlineEditor.close();
      var e = event.element();
      if(e) e.remove();
      FT.restripe_rows();
    });
  });

  
  /* PUBLIC METHODS */
  return {
    init: function(args) {
      document.observe('dom:loaded', function() {
        FT.init_now(args);
      });
    },
    init_now: function(args) {
      args = args || {};
      if(args.token) token = args.token;
      //if(args.enable_nested_records) enable_nested_records = true;
      FT.hookup();
      observer.fire('load');
    },
    
    observe: function(name, func) { observer.observe(name, func); },
    unobserve: function(name, func) { observer.unobserve(name, func); },
    
    hookup_form: function(form) {
      if(!form) throw new Error('form must not be null');
      var add_row=form.down('#add_row');
      if(add_row) {
        set_add_command_on_click(form,add_row);
        FT.hookup_editor(add_row);
      //}else{
        //alert('\"add_row\" not found');
      }
    },
    hookup_editor: function(editor) {
      if(!editor) throw new Error('editor must not be null');
      FT.submit_forms_on_enter(editor);
      //if(enable_nested_records)
      //  FT.reset_add_remove_for_all(editor);
      observer.fire('hookup_form',editor);
    },
    hookup: function() {
      $$('.freight_train').each(function(train) {
        FT.hookup_form(train);
        var model_name = train.readAttribute('data-model')
        var model = FT[model_name];
        if(model && model.hookup_row)
          train.select('.row').each(function(row){_hookup_row(model,row);});
      });
      if(enable_nested_records)
        FT.reset_add_remove_for_all();
      observer.fire('hookup');
    },
    hookup_row: function(model_name, row) {
      if(!model_name) throw new Error('model_name must not be null');
      if(!row) throw new Error('row must not be null');
      var model = FT[model_name];
      if(model && model.hookup_row)
        _hookup_row(model, row);
    },
    destroy: function(msg,id,path) {
      if(!msg || confirm(msg)) {
        render_deleted(id);
        FT.xhr(path,'delete');
        return true;
      }
      return false;
    },
    xhr: function(url,method,params,args) {
      args = args || {};
      args.asynchronous = true;
      args.evalScripts = true;
      args.method = method;
      args.parameters = token || "";
      if(params) args.parameters += '&' + params;
      new Ajax.Request(url, args);
    },
    restripe_rows: function() {
      var rows = $$('.row');
      //alert(rows[0].readAttribute('style'));
      var alt = false;
      for(var i=0; i<rows.length; i++)
      {
        if(alt != rows[i].hasClassName('alt'))
        {
          if(alt)
            rows[i].addClassName('alt');
          else    
            rows[i].removeClassName('alt');
        }
        alt = !alt;
      }
    },    
    hover_row: function(row) {
      if(!row) throw new Error('row must not be null');
      // 2009.03.27 - Both of the following methods fail to add the
      // 'hovered' class to a row that has just been edited or created.
      //$$('.row.interactive').each( function(e) {
      row.observe('mouseover', function() {
        //var e2 = $(e.readAttribute('id') + '_commands'); if(e2) e2.setStyle({visibility:'visible'});
        row.addClassName('hovered');
      });
      row.observe('mouseout', function() {
        //var e2 = $(e.readAttribute('id') + '_commands'); if(e2) e2.setStyle({visibility:'hidden'});
        row.removeClassName('hovered');
      });
      //});
      /*	
      e.hover(function()
      {
        // Show commands (if FTlicable)		
        var e2 = $(e.readAttribute('id') + '_commands'); if(e2) e2.show();
 
        // Add hovered style
        e.addClassName('hovered');
      }, function()
      {
        // Hide commands (if FTlicable)
        var e2 = $(e.readAttribute('id') + '_commands'); if(e2) e2.hide();
 
        // Remove hovered style
        e.removeClassName('hovered');
      }) });
      */
    },
    edit_row_inline: function(row, url_root, editor_writer, before_edit, after_edit) {
      var id = row.readAttribute("id");
      var idn = id.match(/\d+/);
      var url = url_root + '/' + idn;
      new InlineEditor(url, row, editor_writer, before_edit, after_edit);
    }, 
    edit_row: function(row, url_root) {
      row.observe(
        "click",
        function(event) {
          var id = row.readAttribute("id");
          var idn = id.match(/\d+/);
          var url = url_root + '/' + idn; // + "/edit"
          window.location = url;
        });
    }, 
    edit_row_fn: function(row, fn) {
      row.observe("click", function() { fn(row); });
    }, 
    submit_forms_on_enter: function(parent) {
      // Create the handler only once, no matter how often this method is called
      if(!FT.submit_forms_on_enter.keypress)
        FT.submit_forms_on_enter.keypress = function(event) {
          if(event.keyCode == Event.KEY_RETURN) {
            //debugger;
            Event.stop(event);
            var e = Event.element(event);
            if(!e) return;
            var tr = e.up(".row.editor");
            if(!tr) return;
            var submit = tr.down("*[type='submit']");
            if(!submit) return;
            submit.click(); // Works in Chrome 2, IE 7, Firefox 3
          }
        };
 
      var selector = function(x){ return parent ? parent.select(x) : $$(x); };
      selector('input, select').each(function(e) {
        // Register the event handler only once per input element, no matter how often this method is called
        e.stopObserving("keypress", FT.submit_forms_on_enter.keypress);
        e.observe("keypress", FT.submit_forms_on_enter.keypress);
      });
    },
    
    // todo: move to Select or HTMLSelectElement?
    select_value: function(selector,value) {
      if(!selector) {
        alert("selector not found");
        return;
      }
      if(!value) {
        //alert("value not found");
        return;
      }
      var options = selector.options;
      var option;
      for(var i=0;i<options.length;i++) {
        option = options[i];
        if(option.value == value) {
          option.selected = true;
          return;
        }
      }
    },
    
    create_options: function(options) {
      var html = '';
      for(var i=0; i<options.length; i++) {
        html += '<option value=\"' + options[i][0] + '\">' + options[i][1] + '</option>'
      }
      return html;
    },
    
    /* ARE THESE NEXT TWO STRICTLY FREIGHT TRAIN? */
    copy_selected_value: function(tr,tr_edit,method) {
      var attr_name = tr.readAttribute('name')+'['+method+']';
      var e=tr.down('*[attr="'+attr_name+'"]');
      var sel=tr_edit.down('#'+method);
      if(e && sel)
        FT.select_value(sel,e.readAttribute('value'));
      else {
        if(!e) alert(attr_name+' not found');
        if(!sel) alert('selector "'+method+'" ('+attr_name+') not found');
      }
    },
    check_selected_values: function(tr,tr_edit,attr_name) {
      var e=tr.down('*[attr="'+attr_name+'"]');
      if(e) {
        var values=e.readAttribute('value').split('|');
        for(var i=0; i<values.length; i++)
        {
          e=tr_edit.down('*[value="'+values[i]+'"]');
          if(!e) alert('"'+values[i]+'" not found');
          else e.writeAttribute('checked','checked');
        }
      }
      else
        alert(attr_name+' not found');
    },
    add_nested_object: function(sender) {
      var tr = $(sender).up('.nested-row'); if(!tr) { alert('FT.add_nested_object: .nested-row not found'); return; }
      var table = tr.parentNode; if(!table) { alert('FT.add_nested_object .nested not found'); return; }
      var n = table.childNodes.length;
      
      var new_tr = tr.cloneNode(true);
      new_tr.id = tr.id.replace(/(\d+)$/, function(fullMatch, n) { return (Number(n)+1); });
      new_tr.writeAttribute('name', new_tr.readAttribute('name').gsub(/[(\d+)]/, n));
      table.appendChild(new_tr);
         
      var name = new_tr.readAttribute('name');
      var _destroy = new_tr.down('[name="'+name+'[_destroy]"]');
      if(_destroy) _destroy.value = 0;
      var id = new_tr.down('[name="'+name+'[id]"]');
      if(id) id.value = '';
      
      observer.fire('after_add_nested', [table,new_tr]);
      FT.reset_add_remove_for(table);
    },
    delete_nested_object: function(sender) {
      var tr = $(sender).up('.nested-row'); if(!tr) return;
      var table = tr.up('.nested'); if(!table) return;      
      var name = tr.readAttribute('name');
      
      var id = tr.down('[name="'+name+'[id]"]');
      if(id && (id.value == '')) {
        tr.remove();
      }
      else {
        var _destroy = tr.down('[data-attr="_destroy"]');
        _destroy.value = 1;
        tr.hide();
      }
      FT.reset_add_remove_for(table);
    }, 
    reset_nested: function(table) {
      if(table) {
        var nested = table.select('.nested-row');
        for(var i=1;i<nested.length;i++) {
          nested[i].remove();
          FT.reset_add_remove_for(table); // !todo: I think this is wrong. Either 'table' should be 'nested[i]'
                                          //        or this should occur outside the for loop.
        }
      }
    },
    reset_add_remove_for_all: function(parent) {
      var selector = function(x){ return parent ? parent.select(x) : $$(x); };
      selector('.nested.editor').each(FT.reset_add_remove_for);
    },
    reset_add_remove_for: function(table) {
      var reset_nested_row = function(row,i,delete_visibility,add_visibility) {
        row.select('input, textarea, select').each(function(e) {
          //e.writeAttribute('name',object_name+'['+i+']['+e.id+']');
          e.writeAttribute('name', e.readAttribute('name').gsub(/[(\d+)]/, i));
        });
        var delete_link = row.down('.delete-link');
        if(delete_link) delete_link.setStyle({visibility:delete_visibility});
        var add_link = row.down('.add-link');
        if(add_link) add_link.setStyle({visibility:add_visibility});
      };
 
      var object_name=table.readAttribute('name');
      var rows=table.select('.nested-row').reject(function(tr) {
        var _destroy = tr.down('[data-attr="_destroy"]');
        return (_destroy.value=='1');
      });
      var n=rows.length-1;
      if(n>0) {
        for(var i=0; i<n; i++) {
          reset_nested_row(rows[i],i,'visible','hidden');
        }
        reset_nested_row(rows[n],n,'visible','visible');
      }
      else if(n==0) {
        reset_nested_row(rows[0],0,'hidden','visible');
      }
 
      observer.fire('after_reset_nested',table);
      //if(window.after_reset_nested) window.after_reset_nested(table);
    },
    
    /* SHOULD THIS GET A BETTER NAME OR BE PUT IN A SUB-NAMESPACE? */     
    for_each_row: function(root_tr,root_tr_edit,root_tr_selector,root_tr_edit_selector,fn) {
      var nested_rows=root_tr.select(root_tr_selector);
      var nested_editor_rows=root_tr_edit.select(root_tr_edit_selector);
      //debugger;
      //if(nested_rows.length == 0) {
      
        // We need to have at least one row with default values
        // or we have no way of adding/editing new values
      //  var tr=nested_rows[i];
      //  var tr_edit=nested_editor_rows[i];
      //  fn(tr,tr_edit);
      //}
      //else {
        for(var i=0; i<nested_rows.length; i++)
        {
          var tr=nested_rows[i];
          var tr_edit=nested_editor_rows[i];
          fn(tr,tr_edit);
        }
      //}
    }
  };
})();