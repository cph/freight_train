// FreightTrain Core
// =========================================================================================================
//
// Events raised from FT:
//   after_add_nested   raised after a nested item is created
//   after_reset_nested raised after a nested item is either created or destroyed
//   load               raised right after FreightTrain is initialized
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

  var token = '',
      enable_nested_records = true,
      save_when_navigating = false,
      observer = new Observer(),
      forms = [];
  
  
  
  function init(args) {
    readOptions(args);
    activateFreightTrainForms();
    if(enable_nested_records) {
      FT.reset_add_remove_for_all();
    }
    removeDestroyedRows();
    observer.fire('load');
  }
  
  function readOptions(args) {
    args = args || {};
    token = args.token;
    save_when_navigating = args.save_when_navigating;
  }
  
  
  
  function activateFreightTrainForms() {
    var _forms = findFreightTrainForms();
    for(var i=0, ii=_forms.length; i<ii; i++) {
      activateFreightTrainForm(_forms[i]);
    }
  }
  
  function findFreightTrainForms() {
    return $$('form.freight_train');
  }
  
  
  
  function activateFreightTrainForm(form) {
    hasFormBeenInitialized(form) ? reinitializeForm(form) : initializeForm(form);
  }
  
  function hasFormBeenInitialized(form) {
    for(var i=0, ii=forms.length; i<ii; i++) {
      if(forms[i] == form) {
        return true;
      }
    }
    return false;
  }
  
  function reinitializeForm() {
    // Do nothing
  }
  
  function initializeForm(form) {
    configureFormSubmission(form);
    extendFormModel(form);
    initializeRowsInForm(form);
  }
  
  
  
  function configureFormSubmission(form) {
    form.observe('submit', function(e) {
      Event.stop(e);
      InlineEditor.close(); // Don't let values in inline editor override values in creator
      submitFormRemotely(form);
    })
  }
  
  function submitFormRemotely(form) {
    FT.xhr(form.action, 'post', form.serialize());
  }
  
  
  
  function extendFormModel(form) {
    var model = getModelFromForm(form)
    if(model) {
      if(model.hookup_row) {
        model.hookup_rows = function(rows) {
          if(!rows) {rows = findRowsWithin(form);}
          for(var i=0, ii=rows.length; i<ii; i++) {
            model.hookup_row(rows[i]);
          }
        }
      }
    }
  }
  
  function getModelFromForm(form) {
    var model_name = form.readAttribute('data-model'), 
        model = FT[model_name];
    if(!model) {
      FT.debug('[ft] FT.' + model_name + ' was not found.');
    }
    return model;
  }
  
  function findRowsWithin(form) {
    return form.select('.row');
  }
  
  
  
  function initializeRowsInForm(form) {
    var model = getModelFromForm(form)
    if(model && model.hookup_rows) {
      model.hookup_rows();
    }
  }
  
  
  
  function removeDestroyedRows() {
    // need to wrap document.body in $() so that it works on IE
    $(document.body).observe('ft:destroy', function(event) {
      InlineEditor.close();
      var e = event.element();
      if(e && e.parentNode) {
        e.parentNode.removeChild(e);
      }
      FT.restripe_rows();
    });
  }
  
  
  
  
  
  
  var render_deleted = function(id) {
    var e=$(id);
    if(e) {
      e.addClassName('deleted');
      e.removeClassName('editable');
      e.select('input').each(function(i) {
        i.disabled = true;
      });
    }
  };
  
  
  // !nb: not FreightTrain's concern?
  // InlineEditor.observe('before_init', function(tr) {
  //   var e=$('error');
  //   if(e) e.hide();
  // });
  
  
  
  return {
    
    debug: function(o) {
      if(window.console && window.console.log) {
        window.console.log(o);
      }
    },
    
    init: init,
    
    observe: function(name, func) { observer.observe(name, func); },
    
    unobserve: function(name, func) { observer.unobserve(name, func); },
    
    // !nb: moved to FT[model_name].hookup_row
    // hookup_row: function(model_name, row) {
    //   if(!model_name) throw new Error('model_name must not be null');
    //   if(!row) throw new Error('row must not be null');
    //   var model = FT[model_name];
    //   if(model && model.hookup_row)
    //     _hookup_row(model, row);
    // },
    
    destroy: function(msg, id, path) {
      if(!msg || confirm(msg)) {
        render_deleted(id);
        FT.xhr(path,'delete');
        return true;
      }
      return false;
    },
    
    xhr: function(url, method, params, args) {
      args = args || {};
      args.asynchronous = true;
      args.evalScripts = true;
      args.method = method;
      args.parameters = token || "";
      if(params) args.parameters += '&' + params + '&freight_train=true';
      new Ajax.Request(url, args);
    },
    
    restripe_rows: function() {
      var rows = $$('.row'),
          alt = false;
      for(var i=0, ii=rows.length; i<ii; i++) {
        if(alt != rows[i].hasClassName('alt')) {
          if(alt) {
            rows[i].addClassName('alt');
          } else {
            rows[i].removeClassName('alt');
          }
        }
        alt = !alt;
      }
    },
    
    // !nb: not a FreightTrain concern?
    hover_row: function(row) {
      if(!row) throw new Error('row must not be null');
      row.observe('mouseover', function() {
        observer.fire('hover', [row]);
        row.addClassName('hovered');
      });
      row.observe('mouseout', function() {
        row.removeClassName('hovered');
      });
    },
    
    edit_row_inline: function(row, url_root, editor_writer, before_edit, after_edit) {
      var id = row.readAttribute("id");
      var idn = id.match(/\d+/);
      var url = url_root + '/' + idn;
      new InlineEditor(url, row, editor_writer, before_edit, after_edit);
    },
    
    enable_keyboard_navigation: function() {
      InlineEditor.observe('up', function(e, row, editor) {
        var previous_row = row.previous('.editable');
        if(previous_row) {
          Event.stop(e);
          if(save_when_navigating) { editor.save(); }
          previous_row.edit_inline();
        }
      });
      InlineEditor.observe('down', function(e, row, editor) {
        var next_row = editor.next('.editable');
        if(next_row) {
          Event.stop(e);
          if(save_when_navigating) { editor.save(); }
          next_row.edit_inline();
        }
      });
    },
    
    edit_row: function(row, url_root) {
      row.observe("click", function(event) {
        var id = row.readAttribute("id");
        var idn = id.match(/\d+/);
        var url = url_root + '/' + idn; // + "/edit"
        window.location = url;
      });
    }, 
    
    edit_row_fn: function(row, fn) {
      row.observe("click", function() { fn(row); });
    },
    
    // !todo: move to Select or HTMLSelectElement?
    select_value: function(selector,value) {
      if(!selector) {
        FT.debug("selector not found");
        return;
      }
      if(!value) {
        //FT.debug("value not found");
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
    
    create_options: function(options, selectedItem) {
      var html = '';
      for(var i=0, ii=options.length; i<ii; i++) {
        var option = options[i],
            isArray = (option instanceof Array),
            name = isArray ? option[0] : option,
            value = isArray ? option[1] : option,
            selected = (value == selectedItem);
        html += '<option value="' + value + '"' + (selected ? 'selected="selected"' : '') + '>' + name + '</option>';
      }
      return html;
    },
    
    /* ARE THESE NEXT TWO STRICTLY FREIGHT TRAIN? */
    copy_selected_value: function(tr,tr_edit,method) {
      var attr_name = tr.readAttribute('name')+'['+method+']';
      var e=tr.down('*[attr="'+attr_name+'"]');
      var sel=tr_edit.down('select[name="'+attr_name+'"]');
      if(e && sel)
        FT.select_value(sel, e.readAttribute('value')||e.innerHTML);
      else {
        if(!e) FT.debug(attr_name+' not found');
        if(!sel) FT.debug('selector "'+method+'" ('+attr_name+') not found');
      }
    },
    
    check_selected_values: function(tr,tr_edit,attr_name) {
      var e=tr.down('*[attr="'+attr_name+'"]');
      if(e) {
        var values=e.readAttribute('value').split('|');
        for(var i=0; i<values.length; i++)
        {
          e=tr_edit.down('*[value="'+values[i]+'"]');
          if(!e) FT.debug('"'+values[i]+'" not found');
          else e.writeAttribute('checked','checked');
        }
      }
      else
        FT.debug(attr_name+' not found');
    },
    
    reset_form_fields_in: function(parent, options) {
      options = options || {};
      if(options.only) {options.only = $A(options.only);}
      if(options.except) {options.except = $A(options.except);}
      parent.select('input[type="text"], input[type="tel"], input[type="email"], textarea').each(function(input) {
        if(!(options.only && !options.only.include(input.id)) &&
           !(options.except && options.except.include(input.id))) {
           input.value = '';
         }
      });
      parent.select('select').each(function(input) {
        if(!(options.only && !options.only.include(input.id)) &&
           !(options.except && options.except.include(input.id))) {
           input.selectedIndex = 0;
         }
      });
      parent.select('.nested.editor').each(function(table) {
        FT.reset_nested(table);
      });
    },
    
    select_first_field_in: function(parent) {
      var first_input = parent.select('input, select, textarea').find(function(input) {
        return input.visible() && (input.type != 'hidden');
      });
      if(first_input) {
        first_input.select();
      }
    },
    
    add_nested_object: function(sender) {
      var tr = $(sender).up('.nested-row'); if(!tr) { FT.debug('FT.add_nested_object: .nested-row not found'); return; }
      var table = tr.parentNode; if(!table) { FT.debug('FT.add_nested_object .nested not found'); return; }
      var n = table.childNodes.length;
      
      var new_tr = FT.clone_node(tr);
      new_tr.id = tr.id.replace(/(\d+)$/, function(fullMatch, n) { return (Number(n)+1); });
      new_tr.writeAttribute('name', new_tr.readAttribute('name').gsub(/[(\d+)]/, n));
      table.appendChild(new_tr);
      
      var _destroy = new_tr.down('[data-attr="_destroy"]');
      if(_destroy) _destroy.value = 0;
      
      var id = new_tr.down('[data-attr="id"]');
      if(id) id.value = '';
      
      FT.reset_form_fields_in(new_tr);
      FT.select_first_field_in(new_tr);
            
      observer.fire('after_add_nested', [table,new_tr]);
      FT.reset_add_remove_for(table);
    },
    
    clone_node: function(element) {
      // IE copies events bound via attachEvent when
      // using cloneNode. Calling detachEvent on the
      // clone will also remove the events from the orignal
      // In order to get around this, we use innerHTML.
      var clone;
      if(Prototype.Browser.IE) {
        clone = element.clone(false);
        clone.innerHTML = element.innerHTML;
        
        // innerHTML still copies all kinds of custom attributes over in IE.
        FT.reset_after_clone(clone);
      } else {
        clone = element.cloneNode(true);
      }
      return clone;
    },
    
    reset_after_clone: function(element) {
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
          FT.reset_after_clone(children[i]);
        }
      }
    },
    
    delete_nested_object: function(sender) {
      var tr = $(sender).up('.nested-row'); if(!tr) return;
      var table = tr.up('.nested'); if(!table) return;
      var name = tr.readAttribute('name');
      
      // How many undeleted records are left? Only 1? Create a new empty record.
      var rows=table.select('.nested-row').reject(function(row) {
        var _destroy = row.down('[data-attr="_destroy"]');
        return (_destroy.value=='1');
      });
      if(rows.length == 1) {
        FT.add_nested_object(sender);
      }
      
      var id = tr.down('[data-attr="id"]');
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
      table = $(table);
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
      var selector = function(x){ return parent ? $(parent).select(x) : $$(x); };
      selector('.nested.editor').each(FT.reset_add_remove_for);
    },
    
    reset_add_remove_for: function(table) {
      function renumber_row(row, i) {
        row.select('input, textarea, select').each(function(e) {
          e.writeAttribute('name', e.readAttribute('name').gsub(/[(\d+)]/, i));
        });
      }
      
      function set_add_visibility(row, add_visibility) {
        var add_link = row.down('.add-link');
        add_link && add_link.setStyle({visibility:add_visibility});
      }
      
      var object_name=table.readAttribute('name');
      var rows=table.select('.nested-row');
      for(var i=0; i<rows.length; i++) {
        renumber_row(rows[i], i);
      }
      
      rows=rows.reject(function(row) {
        var _destroy = row.down('[data-attr="_destroy"]');
        return (_destroy.value=='1');
      });
      
      var ii = rows.length - 1;
      for(var i=0; i<ii; i++) { set_add_visibility(rows[i],  'hidden'); }
      if(ii >= 0)             { set_add_visibility(rows[ii], 'visible'); }
      
      observer.fire('after_reset_nested',table);
      //if(window.after_reset_nested) window.after_reset_nested(table);
    },
    
    /* SHOULD THIS GET A BETTER NAME OR BE PUT IN A SUB-NAMESPACE? */     
    for_each_row: function(root_tr, root_tr_edit, selector, fn) {
      var nested_rows=root_tr.select(selector);
      var nested_editor_rows=root_tr_edit.select(selector);
      //FT.debugger;
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
          fn(tr,tr_edit,tr_edit.readAttribute('name'));
        }
      //}
    }
  };
})();